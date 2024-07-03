#Firmware, Bootloader e Kernel

Sequencia de inicialização (boot) em sistema que utilizam firmwares BIOS e UEFI

#FASE DO FIRMWARE

BIOS: após rodar o programa POST, o firmware busca a área MBR (Master Boot Record), localizada nos primeiros 512 bytes do disco;

UEFI: a partição ESP (EFI System Partition) será procurada para localizar o carregador de boot especifico a ser utilizado;

#FASE DO CARREGADOR DE BOOT (Bootloader)

BIOS: é divida em duas etapas:
    - Primeira: Nesta etapa temos o bootstrap code, carregador de boot de primeiro estágio. Localizado nos primeiros 446 bytes da área MBR, e este
    realiza a busca pela partição considerada como "ativa" na tabela de particições MBR nos próximos 64 bytes.
    Esta partição contém o carregador de boot de segundo estágio. Quando o bootstrap encontra essa partição, carrega as instruções contidas na memória, para prosseguir para segunda etapa.
    - Segunda: Quando o carregador de boot de segundo estágio é acionado, ele busca o arquivo referente ao carregador de boot principal e definido para ser utilizado no sistema, como o GRUB.
    A partir dai, este assume o controle doo processo de inicialização.

UEFI: Após ser encontrada a particição ESP, o bootloader é carregado na memória.

#FASE KERNEL

Após o kernel ter assumido o controle, ele precisará carregar um sistema de arquivos raiz temporário na memória, de forma a conseguir acessar os discos fisicos e partições. Além disso o kernel
também precisará carregar quaisquer outros drivers necessários para o seguimento na inicialização. Tudo isso para ser utilizado temporariamente, até que o sistema de arquivos raiz verdadeiro seja criado.

Para isso, pode-se utilizar dois métodos:
    - initrd(Initial RAM Disk) 
    - initramfs(Initial ram filesystem)
A lógica em ambos é a mesma, criar um sistema de arquivos inicial, para carregar os módulos necessários, até que o verdadeiro sistema de arquivos seja montado. Como age somente como uma ponte, seu ciclo de vida 
é curto. Uma vez finalziado esta etapa do kernel para o controle ao processo init.

O processo init é responsável por inicializar os diferentes serviços a estarem disponiveis no sistema. Sua forma de inicialização varia em 3 métodos, sendo eles:

#SysVinit

É o sistema tradicional de inicialização dos serviços. Após iniciar o processo /sbin/init, o SysV lê o arquivo /etc/inittab para determinar qual serão o nivel de execução padrão do sistema e iniciar os demais serviços.
Niveis de execução referem-se a quais serviços deverão ser executados ou finalizados no sistema em um determinado nivel, sendo eles:
    - 0: Desliga o sistema
    - 1,s ou S: Nível monousuario. Utilizado plo superusuario para realizar atividades basicas para manutenção do sistema.
    - 2,3,4 e 5: Multiusuario.
    - 6: Reboot do sistema
Baseado no nivel de execução configurado, são executados scripts presentes nos diretórios /etc/rcx.d/ (ex: rc5.d, rc3.d, etc.), que contém diversos links simbólicos para arquivos contidos no diretório /etc/init.d/
Apesar de robusto, como os serviços são executados em sequencia, faz a inicialização do sistema ser mais demorada.

#UPSTART

Desenvolvido pela distro Ubuntu

O upstart oferece uma solução de inicialização paralela de serviços, reduzindo assim o tempo de inicialização do sistema. Suas operações são baseadas na utilização de eventos, que podem ser disparados em resposta a algum 
acontecimento especifico ou também serem executados no momento do boot.

#SYSTEMD

Lançado em 2010, é um sistema de inicialização e gerenciamento de serviços substituto dos esquemas de SysVinit e Upstart. Possiu compatibilidade com scripts do SysVinit
O systemd introduziu o processamento paralelo de scripts, tratamento aprimorado das dependencias dos serviços e ativação dos serviços sob demanda (o sistema consegue adiar a inicialização de certos serviços até que sejam
realmente necessarios)
Ao contrário do SysV, o systemd não trabalha diretamente com runlevel, e sim com Unidades, sendo as principais:
    - .service: Unidade do tipo serviço, send possivel parar, iniciar ou reiniciar o serviço desejado.
    - .target: representa um grupo de unidades.

#Passagens de comandos ao Bootloader e ao Kernel

Caso houver necessidade de passar informações para o carregador de boot e ao kernel durante a inicialização, o adm esqueceu a senha root por exemplo, é poossivel faze-la.
Para passarmos comandos precionamos a tecla "e", para editar os comandos de inicialização

Dentre as linhas, temos uma importante, a linux, nela temos algumas infoormações:
    - /boot/vmlinuz-6.8.0-36-generic: representa o kernel que será utilizado.
    - root=UUID=38e56b88-993d-43a6-b23e-4460488851cb: representa o UUID (Identificador unico universal) do disco que a particição raiz deverá ser montada.
    - ro: o kernel montará o sistema de arquivos raiz inicialmente somente como leitura. Isso se deve ao fato de programas como o FSCK possam validar a integridade dos discos.
    - initrd/boot/initrd.img-6.8.0-36: representa a imagem de inicialização dos módulos do kernel (initrd ou initramfs)
    - quiet: modo silencioso.
Após o sistema ser carregado, estas strings de inicialização estarão disponiveis no arquivo /proc/cmdline

#Visualização das mensagens de boot

O principal arquivo de logs do sistema fica em /var/log/messages.

Entretanto pode ser utilizado o dmesg, que é responsável por examinar e controlar o anel de buffer do kernel.
O dmesg costuma gravar as mensagens no /var/log/dmesg.

Outro comando que pode ser utilizado é o journalctl, que é responsável por consultar os conteudos do journal do systemd, registrados pelo serviço systemd-journald.

