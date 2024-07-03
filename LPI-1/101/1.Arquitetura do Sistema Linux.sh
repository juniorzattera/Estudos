#Dispositivos de Armazenamento em Massa

IDE,SATA,SAS,USB;

IDE: 
Transferencias de dados em paralelo.
Cada canal IDE suporta no máximo dois dispositivos - podendo atuar como master e slave.
    /dev/hda: Conectado ao canal primário e configurado como master. As particições do disco são reconhecidas como /dev/hda1/, /dev/hda2, ...
    /dev/hdb: Conectado ao canal primário e configurado como slave. Suas partições são reconhecidas da mesma forma que os anteriores.
    /dev/hdc: Conectado ao canal secundário e configurado como master. Suas partições são reconhecidas da mesma forma que os anteriores.
    /dev/hdd: Conectado ao canal secundário e configurado como slave. Suas partições são reconhecidas da mesma forma que os anteriores.

SATA:
Transferencias de dados em séries
Dispositivos SATAs podem ser trocados com o computador ligado - recurso conhecido como hot-swap.
Discos SATA - SCSI, SAS, USB, SDD
    /dev/sda: Representa o primeiro dispositivo. Suas particições são reconhecidas como /dev/sda/, /dev/sdb, ...
    dev/sdb: Representa o segundo dispositivo. Suas partições são reconhecidas da mesma forma que os anteriores.
    /dev/sdc: Representa o terceiro dispositivo. Suas partições são reconhecidas da mesma forma que os anteriores.
    /dev/sdd: Representa o quarto dispositivo. Suas partições são reconhecidas da mesma forma que os anteriores.

DISQUETES: 
/dev/fd0: Primeira unidade de disquetes.
/dev/fd1: Segunda unidade de disquetes.

CD-ROM:
/dev/sr0 - Primeiro CD-ROM SCSI.
/dev/sr1 - Segundo CD-ROM SCSI.

Dependendo do tipo de SCSI, é possivel conectar de 7 a 15 dispositivos em um único barramento.

Sysfs

O sistema de arquivos sysfs, montado no diretório /sys/, por ser mantido em memória, é também conhecido como pseudo-sistema de arquivos.
Isso quer dizer que seus arquivos não encontram-se fisicamente presentes em disco
Sua responsabilidade é oferecer uma interface ás estruturas de dados do kernel. Os arquivos presentes no diretório oferecem informações sobre
os dispositivos, sistemas de arquivos, módulos do kernel e outros componentes.
Estrutura do /sys

ls -l /sys/
drwxr-xr-x   2 root root 0 jul  1 16:18 block
drwxr-xr-x  49 root root 0 jul  1 16:18 bus
drwxr-xr-x  76 root root 0 jul  1 16:18 class
drwxr-xr-x   4 root root 0 jul  1 16:18 dev
drwxr-xr-x  20 root root 0 jul  1 16:18 devices
drwxr-xr-x   6 root root 0 jul  1 16:18 firmware
drwxr-xr-x  11 root root 0 jul  1 16:18 fs
drwxr-xr-x   2 root root 0 jul  1 16:18 hypervisor
drwxr-xr-x  16 root root 0 jul  1 16:18 kernel
drwxr-xr-x 232 root root 0 jul  1 16:18 module
drwxr-xr-x   3 root root 0 jul  1 16:18 power

Udev

Já o gerenciamento dinâmico de dispositivos é posto em prática pelo udev - a partir de seu daemon(udev ou systemd-udevd.service)
Sendo assim, este último recebe informações sobre dispositivos adicionados ou removidos do sistema e cria ou remove entradas correspondentes no /dev/
Seu comportamento é ditado a partir das regras contidas no /etc/dev/rules.d/
Desta forma, podemos afirmar que o udev é o grande "guardião" do /dev

Dbus

O dbus é um sistema de comunicação inter-processos (IPC), oferecendo um mecanismo eficiente para permitir que aplicações "conversem" umas com as outras e 
realizem requisições de serviços.
Seu daemon, dbus-daemon, lê informações do udev sobre os dispositivos que foram conectados ao sistema e emite sinais aos programas e ao sistema operacional
Por exemplo, quando conectamos um pendrive no sistema e logo em seguida ele abre o seu conteúdo, temos um exemplo da atuação do dbus.

#Comunicação entre CPU e Dispositivos e Manipulação de Módulos

Para uma comunicação efetiva entre dispositivos e CPU, é necessário que haja a devida alocação de recursos para cada um deles. Para isso temos alguns conceitos como IRQ, Endereço de I/O e DMA

IRQ (Requisições de interrupção)

São sinais enviados pelos dispositivos ao processador que requerem a sua atenção em um certo momento. Por exemplo, quando digitamos uma tecla, uma requisição IRQ é enviada a CPU, solicitando processamento.

cat /proc/interrupts 
CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       CPU8       CPU9       CPU10      CPU11      CPU12      CPU13      CPU14      CPU15      
0:        132          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0  IR-IO-APIC    2-edge      timer
7:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0  IR-IO-APIC    7-fasteoi   pinctrl_amd

O Conteúdo é distribuido em 4 colunas:
    1 - Representa o número da interrupção
    2 - Quantidade de vezes que o endereço IRQ foi utilizado pela CPU.
    3 - Tipo de IRQ
    4 - Nome da IRQ
As IRQs podem ser compartilhadas entre diversos tipos de dispositivos.

O diretório /proc contém as informações sobre processos em atividades no sistema - podendo ser lido por qualquer usuario.
Caso algum processo seja finalizado ou iniciado, o kernel comunica-se imediatamente com este diretório, para assim sempre mante-lo atualizado.
O sistema de arquivos montados em seu interior é conhecido como procfs.

ls -l /proc
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 1
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 10
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 100
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 101
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 102
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 104
dr-xr-xr-x  9 root                 root                               0 jul  1 16:18 105

Portas de Entrada e Saida I/O

São endereços de memórias reservados na CPU, utilizados para entrada e saida de dados por parte dos dispositivos, onde cada dispositivo possui o seu endereço. 
Esse endereço é uma localicação da memória utilizada para a troca de dados entre o computador e os dispositivos.
Um dispositivo por ter mais de uma porta de I/O ou uma faixa de endereços. 
Por exemplo:
    - Uma placa de som padrão usa as portas 0x220, 0x330 e 0x388, respectivamente audio digital, midi e opl3.
O tamanho da faixa de endereço pode variar de acordo com o tipo do dispositivo.
Um detalhe é que os endereços das portas de I/O não podem ser compartilhadas, ou seja, não podemos ter dois dispositivos utilizando o mesmo endereço de porta I/O

O armazenamento das informações sobre as portas de entrada e saida estão no local /proc/ioports

cat /proc/ioports 
0000-0000 : PCI Bus 0000:00
  0000-0000 : dma1
  0000-0000 : pic1
  0000-0000 : timer0
  0000-0000 : timer1
  0000-0000 : keyboard
  0000-0000 : PNP0800:00
  0000-0000 : keyboard

A primeira coluna mostra endereços de portas de I/O em hexadecimal. Já a segunda mostra os os nomes dos dispositivos que estão associados a cada endereço.

DMA

Canais Direct Memory Access permitem aos dispositivos ignorar a CPU ao precisar escrever ou ler informações de outros dispositivos. A ideia é reduzir a carga de trabaho sobre a CPU.
Grande parte dos computadores possuem dois controladores de DMA. 
    - 1 Controlador: Responsável pelos canais 0,1,2,3 (Canais baixos - movimentam 1 byte por transferencia)
    - 2 Controlador: Resposável pelos canais 4,5,6,7
        - Canal 4: Utilizado como ligação entre os dois controladores.
        - Canais 5,6,7: Canais altos, permitem a movimentação de 2 bytes por transferencia.
Um canal DMA não pode ser compartilhado entre dispositivos. Mas existem exceções, desde que dois dispositivos não usem o mesmo canal no mesmo intervalo de tempo.

O arquivo /proc/dma permite que sejam visualizados os canais DMA em uso no sistema:
cat /proc/dma 
 4: cascade

#O sistema básico de entrada e saida (BIOS)