#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # https://computingforgeeks.com/how-to-install-asterisk-16-centos-7-linux/

    # The other packages that you need to install are:
    sudo yum -y install libedit-devel sqlite-devel psmisc gmime-devel ncurses-devel libtermcap-devel sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel uuid-devel libtool libuuid-devel subversion kernel-devel kernel-devel-$(uname -r) git subversion kernel-devel crontabs cronie cronie-anacron wget vim

    # Download and Install Jansson
    cd /usr/src/
    git clone https://github.com/akheron/jansson.git
    cd jansson
    autoreconf -i
    ./configure --prefix=/usr/
    sudo make && make install

    # Download and Install PJSIP
    cd /usr/src/
    git clone https://github.com/pjsip/pjproject.git
    cd pjproject
    ./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-video --disable-sound --disable-opencore-amr
    sudo make dep
    sudo make
    sudo make install
    ldconfig

    cd /usr/src/
    sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
    sudo tar xvfz asterisk-16-current.tar.gz
    sudo rm -f asterisk-16-current.tar.gz
    cd asterisk-*
    ./configure --libdir=/usr/lib64

    sudo make menuselect

    # Now run the following command to download the mp3 decoder library into the source tree.
    sudo contrib/scripts/get_mp3_source.sh

    # To start building and installation of Asterisk with selected modules, run the commands.
    sudo make
    sudo make install
    sudo make samples
    sudo make config
    ldconfig

    sudo systemctl restart asterisk
    sudo systemctl enable asterisk

    # https://www.voip-info.org/asterisk-auto-dial-out-deliver-message/

    # /var/spool/asterisk/outgoing/

    sudo mkdir /var/lib/asterisk/sounds/outboundmsgs
    sudo chown asterisk_user:asterisk_user /var/lib/asterisk/sounds/outboundmsgs

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # https://techviewleo.com/install-asterisk-with-freepbx-on-debian/

    sudo apt -y install git vim curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev

    cd /usr/src/
    sudo wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
    sudo tar xvf asterisk-18-current.tar.gz
    cd asterisk-18*/
    sudo contrib/scripts/get_mp3_source.sh
    sudo contrib/scripts/install_prereq install
    sudo ./configure

    sudo make menuselect
    sudo make
    sudo make install
    sudo make progdocs
    sudo make samples
    sudo make config
    sudo ldconfig

    sudo groupadd asterisk
    sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
    sudo usermod -aG audio,dialout asterisk
    sudo chown -R asterisk.asterisk /etc/asterisk
    sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
    sudo chown -R asterisk.asterisk /usr/lib/asterisk

    sudo ufw allow proto tcp from any to any port 5060,5061

    cd /usr/src
    sudo wget http://mirror.freepbx.org/modules/packages/freepbx/7.4/freepbx-16.0-latest.tgz
    sudo tar xfz freepbx-16.0-latest.tgz
    sudo rm -f freepbx-16.0-latest.tgz
    freepbx
    sudo systemctl restart asterisk

    sudo fwconsole ma disablerepo commercial
    sudo fwconsole ma installall
    sudo fwconsole ma delete firewall
    sudo fwconsole reload
    sudo fwconsole restart

fi
