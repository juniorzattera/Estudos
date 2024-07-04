#SysVinit

O /sbin/init manda chamar os scripts pertencentes ao nivel de execução configurado como padrão em /etc/inittab.
Mas a execução de fato destes scripts é feito pelo /etc/init.d/rc. Recebendo como parametro os valores de 0 a 6 e buscará dentroo dos diretórios
inicializadores (/etc/rcX.d (onde X representa o runlevel em questão)) pelos scripts de inicialização. 

Os scripts contidos nestes diretórios, na verdade são links simbólicos para o diretório /etc/init.d. Em algumas distros, o diretório é o /etc/rc.d/init.d

Dentro deste diretórios, podemos ter scripts iniciados com K ou S.
 - K: finaliza o serviço naquele runlevel
 - S: inicia o serviço naquele runlevel

Além disso, os scritps possuem ordem determinada. Onde o script /etc/rcX.d/S1xxx será executado primeiro que /etc/rcX.d/S2xxx. 
Durante a inicialização, o último script a ser executado é o /etc/rc.local. 

Principais campos contidos no arquivo /etc/inittab

cat /etc/inittab 

# Este é o runlevel configurado como padrão no sistema.
id:2:initdefault:

# indica o primeiro runlevel executado durante o boot, exceto no modo de emergência.
si::sysinit:/etc/init.d/rcS

# Localização de cada dos serviços e scripts a serem iniciados para cada nível de #execução

# Runlevel 0 => desligamento.
# Runlevel 1 => monousuário.
# Runlevels 2-5 => multiusuário.
# Runlevel 6 => reinicialização.

l0:0:wait:/etc/init.d/rc 0
l1:1:wait:/etc/init.d/rc 1
l2:2:wait:/etc/init.d/rc 2
l3:3:wait:/etc/init.d/rc 3
l4:4:wait:/etc/init.d/rc 4
l5:5:wait:/etc/init.d/rc 5
l6:6:wait:/etc/init.d/rc 6

# O que fazer quando as teclas CTRL-ALT-DEL forem pressionadas.
ca::ctrlaltdel:/sbin/shutdown -t3 -r now

# O que deverá ser feito quando ocorrer falta de energia e quando a mesma retornar.
pf::powerwait:/etc/init.d/powerfail start
pn::powerfailnow:/etc/init.d/powerfail now
po::powerokwait:/etc/init.d/powerfail stop

# Terminais virtuais disponíveis para os runlevels em execução
1:2345:respawn:/sbin/getty 38400 tty1
2:23:respawn:/sbin/getty 38400 tty2
3:23:respawn:/sbin/getty 38400 tty3
4:23:respawn:/sbin/getty 38400 tty4
5:23:respawn:/sbin/getty 38400 tty5
6:23:respawn:/sbin/getty 38400 tty6

Além da ação initdefault, existem outras:
    - respawn: o processo é reinicializado caso seja parado ou finalizado
    - wait: o processo é iniciado e o init espera pela sua finalização
    - once: o processo é iniciado no moment em que o runlevel também é iniciado.
    - boot: o processo é iniciado no boot do sistema. O run level é desnecessário e ignorado.
    - bootwait: o processo é iniciado noo boot do sistema enquanto o init aguarda a sua finalização. O também é desnecessário e ignorado.
    - off: não realiza nenhuma ação
    - sysinit: o processo é iniciado durante o boot, porém antes das ações boot/bootawait. O run level é desnecessário e ignorado.
    - powerwait: o processo é iniciado em casos de queda de energia. O processo init aguarda a sua finalização.
    - powerfail: o processo também é iniciado em casos de queda de energia, mas o init não aguarda a sua finalização.
    - powerfailnow: o processo é executado em casos em que a bateria do nobreak esta quase acabando.
    - powerokwait: no momento em que a energia é restabelecida, o processo relacionado a essa ação é executado.
    - ctraltdel: ação a ser tomada no momento em que forem pressionadas as teclas Ctrl + Alt + Del. 
    - kbrequest: Executa determina ação quando alguma combinação de teclas especial é pressionada.

Como validar o runlevel atual

runlevel
N 5
N = nivel anterior é mostrado, se houver.
1..6 = nivel atual.

Trocar de runlevel

init 1
telinit 1

Alterando algo no arquivo inittab

Caso seja necessário alterar algo no arquivo inittab, é necessário informar um dos seguintes (equivalentes) comandos (para que não haja a necessidade de reiniciar o sistema)

init q
telinit q
kill -HUP 1

Os serviços poderão também ser administrados atraves de comandos como:

/etc/init.d/cups stop start reload status

service cups stop

#UpStart

Comando administrativo initctl

initctl list #Exemplo

Para iniciar um serviço, o Upstart utiliza scripts de inicialização (arquivos .conf) encontrados no diretório /etc/init.

O exemplo a seguir inicia o job Control-Alt-Delete: 

initctl start control-alt-delete

Para finalizar o serviço: 

initctl stop control-alt-delete

Para visualizar o status do serviço, utilizamos o subcomando status: 

initctl status control-alt-delete

Podemos utilizar a pção de reload para que os arquivos de configuração do UpStart sejam devidamente carregados:

initctl reload

#Systemd

Os arquivos de configuração das unidades encontram-se em /lib/systemd/system ou /usr/lib/systemd/system

Já em /etc/systemd estão contidos os diferentes arquivos de configuração do systemd, incluindo links simbólicos que são responsáveis por aportar para os arquivos /lib/systemd/system

root@zattera:/lib/systemd/system# ls -l | grep runlevel
lrwxrwxrwx 1 root root    15 mai 17 05:47 runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root    13 mai 17 05:47 runlevel1.target -> rescue.target
lrwxrwxrwx 1 root root    17 mai 17 05:47 runlevel2.target -> multi-user.target
lrwxrwxrwx 1 root root    17 mai 17 05:47 runlevel3.target -> multi-user.target
lrwxrwxrwx 1 root root    17 mai 17 05:47 runlevel4.target -> multi-user.target
lrwxrwxrwx 1 root root    16 mai 17 05:47 runlevel5.target -> graphical.target
lrwxrwxrwx 1 root root    13 mai 17 05:47 runlevel6.target -> reboot.target
-rw-r--r-- 1 root root   849 mai 17 05:47 systemd-update-utmp-runlevel.service

Podemos notar que o systemd realiza a associação enter os niveis de execuçao com targets por ele gerenciados. 
Por exemplo, o nivel 6 é manipulado pelo runlevel6.target, responsavel por apontar para o arquivo reboot.target.

O target de execução padrão do sistema é aquele indicado pelo arquivo default.target

root@zattera:/lib/systemd/system# ls -l default.target 
lrwxrwxrwx 1 root root 16 mai 17 05:47 default.target -> graphical.target

Pode-se utilizar o comando abaixo para obter o mesmo resultado.

systemctl get-default 

Para alterar o target padrão

systemctl set-default -f multi.user.target

Outros subcomandos

systemctl status stop start reload restart status enable disable cron

Para validar se o serviço é inicializado no boot

systemctl is-enabled cron

Para exibir unidades do tipo target disponiveis:

systemctl list-units --type target

Para exibir unidades do tipo service disponiveis:

systemctl list-units --type service

Para listar ambas

systermctl

Para listar todas as units com falha

systemctl --failed

Para colocar o sistema em monousuario

systemctl isolate rescue.target

#Dependencias entre Unidades

Uma unidade pode possuir relacionamentos de dependencias com outras unidades. Por exemplo:

root@zattera:/lib/systemd/system# cat /lib/systemd/system/rsyslog.service 
[Unit]
Description=System Logging Service
Requires=syslog.socket
Documentation=man:rsyslogd(8)
Documentation=man:rsyslog.conf(5)
Documentation=https://www.rsyslog.com/doc/

[Service]
Type=notify
ExecStartPre=/usr/lib/rsyslog/reload-apparmor-profile
ExecStart=/usr/sbin/rsyslogd -n -iNONE
StandardOutput=null
StandardError=journal
Restart=on-failure

# Increase the default a bit in order to allow many simultaneous
# files to be monitored, we might need a lot of fds.
LimitNOFILE=16384

CapabilityBoundingSet=CAP_BLOCK_SUSPEND CAP_CHOWN CAP_DAC_OVERRIDE CAP_LEASE CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_ADMIN CAP_SYS_RESOURCE CAP_SYSLOG CAP_MAC_ADMIN CAP_SETGID CAP_SETUID
SystemCallFilter=@system-service
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
NoNewPrivileges=yes
ProtectHome=no
ProtectClock=yes
ProtectHostname=yes

[Install]
WantedBy=multi-user.target
Alias=syslog.service

Requires: Aponta a dependencia de uma unidade para outra. Por exemplo, o rsyslog.service somente consegue realizar suas operações se a unidade syslog.socket estiver funcionando
Wants: Uma unidade X pode querer a presença da unidade Y, mas caso a ultima na puder ser rodada, a unidade X continuara rodar normalmente.
ExecStart: Comando a ser executado na inicialização do serviço.
After: Se uma unidade X tiver o campo after configurado com a unidade Y, a X deve aguardar a execução da Y até o fim, para que em seguida seja executada.
Before: Oposto da After.
WantedBy: A diretiva WantedBy=multi-user.target cria um link simbólico em /etc/systemd/system/multi-user.target.wants/rsyslog.service para o serviço rsyslog.service. 
          Sendo assim, este arquivo de unidade (rsyslog.service) será carregado sempre que a unidade multi-user.target for iniciada.

Para visualizar todas as dependencias de uma unidade:

systemctl list-dependencies rsyslog.service

#Desligamento e Reinicialização do Sistema pelo Shell

shutdown reinicia ou desliga a maquina de forma segura

# Desliga a máquina dentro de 1 minuto
# O sistema é finalizado (halt) e a energia elétrica é cortada (poweroff)

shutdown

# A máquina será desligada em 10 minutos e uma mensagem será exibida aos usuários
# conectados ao sistema

shutdown +10 "Desligando"

# Cancela o desligamento

shutdown -c

# Sistema será reiniciado dentro de um minuto

shutdown -r

# Sistema entrará em halt
# De forma direta, o Linux será desligado – mas a máquina não (dependerá do hardware).

shutdown -h

# Agenda a reinicialização para daqui a 20 minutos

shutdown -r +20

#Desligue a máquina às 19:30

shutdown 19:30

Outros comandos auxiliares:
    - reboot: reinicia a maquina
    - half: sistema operacional é finalizado (mas não a maquina)
    - poweroff: sistema e maquina são desligados

O ACPI (Advenced Configuration and Power Interface) pode ser utilizado para exibir o estado da bateria da maquina. além de outras informações como "cooling", temperatura, etc.

acpi
Battery 0: Full, 100%

Ao utilizar o comando -V, todas as informações possiveis sao exibidas

acpi –V
Battery 0: Full, 100%
Battery 0: design capacity 5000 mAh, last full capacity 5000 mAh = 100%
Adapter 0: on-line
Cooling 0: Processor 0 of 0
Cooling 1: intel_powerclamp no state information available

Ja o daemon acpid é responsavel por notificar programas em execução no espaço do usuario para eventos relacionados a ACPI, além de tomar decisões baseadas em regras associadas
a cada um dos eventos que ele recebe. Regras estas dispostas no arquivo /etc/acpi/events

#Wall

Comando utilizado para enviar mensagens a todos os usuarios que estão conectados no sistema

wall "Vamos desligar está maquina em 10 minutos"

#Finalização de processos

Os processos podem ser inicializados de diversas maneiras, sendo elas:

- SystemD -> systemctl stop cron
- SysVinit -> /etc/init.d/cron stop
- Upstart -> initctl stop scron
