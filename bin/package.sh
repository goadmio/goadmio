#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

Hostname=$(</etc/hostname)

ProgressBar "Installing Packages"

cd /tmp

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y upgrade

    if ! rpm -q yum-utils &>/dev/null; then
        ProgressBar "Installing YUM-UTILS"
        sudo dnf -y install yum-utils
    fi

    if ! rpm -q screen &>/dev/null; then
        ProgressBar "Installing Screen"
        sudo dnf -y install screen
    fi

    if ! rpm -q openssh-clients &>/dev/null; then
        ProgressBar "Installing SCP"
        sudo dnf -y install openssh-clients
    fi

    if ! rpm -q s-nail &>/dev/null; then
        ProgressBar "Installing S-NAIL"
        sudo dnf -y install s-nail
    fi

    if ! rpm -q swaks &>/dev/null; then
        ProgressBar "Installing SWAKS"
        sudo dnf -y install swaks
    fi

    if ! rpm -q sshpass &>/dev/null; then
        ProgressBar "Installing SSHPASS"
        sudo dnf -y install sshpass
    fi

    if ! rpm -q bind &>/dev/null; then
        ProgressBar "Installing BIND & NAMED"
        sudo dnf -y install bind
        sudo systemctl enable named
    fi

    if ! rpm -q cronie &>/dev/null; then
        ProgressBar "Installing CRONTAB"
        sudo dnf -y install cronie
    fi

    if ! rpm -q whois &>/dev/null; then
        ProgressBar "Installing WHOIS"
        sudo dnf -y install whois
    fi

    if ! rpm -q telnet &>/dev/null; then
        ProgressBar "Installing TELNET"
        sudo dnf -y install telnet
    fi

    if ! rpm -q net-tools &>/dev/null; then
        ProgressBar "Installing NET TOOLS"
        sudo dnf -y install net-tools
    fi

    if ! dnf group list --installed 2>/dev/null | grep -q "Development Tools"; then
        ProgressBar "Installing Development Tools"
        sudo dnf -y groupinstall "Development Tools"
    fi

    if ! rpm -q nmap &>/dev/null; then
        ProgressBar "Installing NMAP"
        sudo dnf -y install nmap
    fi

    if ! rpm -q microcode_ctl &>/dev/null; then
        ProgressBar "Installing Microcode"
        sudo dnf -y install microcode_ctl
    fi

    if ! rpm -q psmisc &>/dev/null; then
        ProgressBar "Installing PSMISC"
        sudo dnf -y install psmisc
    fi

    if ! rpm -q bind-utils &>/dev/null; then
        ProgressBar "Installing BIND-UTILS"
        sudo dnf -y install bind-utils
    fi

    if ! rpm -q inxi &>/dev/null; then
        ProgressBar "Installing INXI"
        sudo dnf -y install inxi
    fi

    if ! rpm -q pv &>/dev/null; then
        ProgressBar "Installing PV"
        sudo dnf -y install pv
    fi

    if ! command -v 7z &>/dev/null; then
        ProgressBar "Installing 7Z"
        sudo dnf -y install p7zip
        sudo cp /usr/bin/7za /usr/bin/7z
    fi

    if ! command -v nano &>/dev/null; then
        ProgressBar "Installing NANO & VIM"
        sudo dnf -y install nano
        sudo dnf -y install vim
        export VISUAL=nano
        export EDITOR="$VISUAL"
        sudo cp /bin/nano /bin/edit
        sudo cp /bin/nano /bin/vi
    fi

    if ! rpm -q ImageMagick &>/dev/null; then
        ProgressBar "Installing ImageMagick"
        sudo dnf -y install ImageMagick
    fi

    if ! rpm -q sqlite &>/dev/null; then
        ProgressBar "Installing SQLite"
        sudo dnf -y install sqlite
    fi

    if ! rpm -q libsodium-devel &>/dev/null; then
        ProgressBar "Installing SODIUM"
        sudo dnf -y install libsodium-devel
    fi

    if ! rpm -q libsodium &>/dev/null; then
        ProgressBar "Installing LIBSODIUM"
        sudo dnf -y install libsodium
    fi

    if ! command -v python3 &>/dev/null; then
        ProgressBar "Installing PYTHON"
        sudo dnf -y install python39
    fi

    if ! rpm -q jq &>/dev/null; then
        ProgressBar "Installing JQ"
        sudo dnf -y install jq
    fi

    if ! rpm -q s3fs-fuse &>/dev/null; then
        ProgressBar "Installing S3FS"
        sudo dnf -y install s3fs-fuse
    fi

    if ! rpm -q cifs-utils &>/dev/null; then
        ProgressBar "Installing CIFS"
        sudo dnf -y install cifs-utils
    fi

    if ! rpm -q fuse3 &>/dev/null; then
        ProgressBar "Installing FUSE3"
        sudo dnf -y install fuse3
    fi

    if [ -n "$(dnf repoquery redis 2>/dev/null)" ]; then

        # REDIS is AVAILABLE

        if ! rpm -q redis &>/dev/null; then
            ProgressBar "Installing REDIS"
            sudo dnf -y install redis
            sudo systemctl enable redis
            sudo systemctl restart redis
        fi

    else

        # REDIS is NOT available (Install VALKEY)

        if ! rpm -q valkey &>/dev/null; then
            ProgressBar "Installing VALKEY"
            sudo dnf -y install valkey
            sudo systemctl enable valkey
            sudo systemctl restart valkey
        fi

    fi

    if ! rpm -q dropbear &>/dev/null; then
        ProgressBar "Installing DROPBEAR"
        sudo dnf -y install dropbear
        sudo systemctl enable dropbear
        sudo systemctl restart dropbear
    fi

    if ! rpm -q quota &>/dev/null; then
        ProgressBar "Installing QUOTA"
        sudo dnf -y install quota
    fi

    if ! rpm -q gdisk &>/dev/null; then
        ProgressBar "Installing GDISK"
        sudo dnf -y install gdisk
    fi

    if ! command -v geoiplookup &>/dev/null; then
        ProgressBar "Installing GEOIP"
        sudo dnf -y install geoip
    fi

    if ! rpm -q at &>/dev/null; then
        ProgressBar "Installing AT"
        sudo dnf -y install at
        sudo systemctl enable atd
        sudo systemctl restart atd
    fi

    if ! rpm -q restic &>/dev/null; then
        ProgressBar "Installing RESTIC"
        sudo dnf -y install restic
    fi

    if ! rpm -q qpress &>/dev/null; then
        ProgressBar "Installing QPRESS"
        sudo dnf -y install qpress
    fi

    if ! rpm -q ghostscript &>/dev/null; then
        ProgressBar "Installing GHOST SCRIPT"
        sudo dnf -y install ghostscript
    fi

    if ! rpm -q xmlstarlet &>/dev/null; then
        ProgressBar "Installing XMLSTARLET"
        sudo dnf -y install xmlstarlet
    fi

    if ! rpm -q git &>/dev/null; then
        ProgressBar "Installing GIT"
        sudo dnf -y install git
    fi

    if ! command -v npm &>/dev/null; then
        ProgressBar "Installing NPM (Node Package Manager)"
        sudo dnf -y install npm
    fi

    if ! rpm -q zip &>/dev/null; then
        ProgressBar "Installing ZIP"
        sudo dnf -y install zip
    fi

    if ! rpm -q unzip &>/dev/null; then
        ProgressBar "Installing UNZIP"
        sudo dnf -y install unzip
    fi

    if ! rpm -q NetworkManager &>/dev/null; then
        ProgressBar "Installing NETWORK-MANAGER"
        sudo dnf -y install NetworkManager
    fi

    if ! rpm -q bc &>/dev/null; then
        ProgressBar "Installing BC"
        sudo dnf -y install bc
    fi

    if ! command -v nc &>/dev/null; then
        ProgressBar "Installing NC"
        sudo dnf -y install nc
    fi

    if ! rpm -q rsyslog &>/dev/null; then
        ProgressBar "Installing RSYSLOG"
        sudo dnf -y install rsyslog
        sudo systemctl enable rsyslog
        sudo systemctl restart rsyslog
    fi

    if ! rpm -q gawk &>/dev/null; then
        ProgressBar "Installing GAWK"
        sudo dnf -y install gawk
    fi

    if ! rpm -q python3-pip &>/dev/null; then
        ProgressBar "Installing PIP"
        sudo dnf -y install python3-pip
        python3 -m pip install --upgrade pip
    fi

    if ! command -v rclone &>/dev/null; then
        ProgressBar "Installing RCLONE"
        sudo curl -s https://rclone.org/install.sh | bash
    fi

    if ! command -v rar &>/dev/null; then
        ProgressBar "Installing RAR & UnRAR"
        sudo wget https://www.rarlab.com/rar/rarlinux-x64-5.6.0.tar.gz
        sudo tar -zxvf rarlinux-x64-5.6.0.tar.gz
        cd rar
        sudo cp -v rar unrar /usr/local/bin/
        cd /tmp
    fi

    if ! command -v ttyd &>/dev/null; then
        ProgressBar "Installing TTYD"
        sudo wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
        sudo chmod +x ttyd.x86_64
        sudo mv ttyd.x86_64 /usr/local/bin/ttyd
    fi

    if sudo test ! -f /usr/local/goadmio/db/lite.db ; then

        if ! rpm -q tesseract &>/dev/null; then
            ProgressBar "Installing OCR"
            sudo dnf -y install tesseract
        fi

        if ! rpm -q jpegoptim &>/dev/null; then
            ProgressBar "Installing JPEGOPTIM"
            sudo dnf -y install jpegoptim
        fi

        if ! rpm -q wkhtmltox &>/dev/null; then
            ProgressBar "Installing WKHTMLTOPDF"
            sudo dnf -y install compat-openssl11
            sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos8.x86_64.rpm
            sudo dnf -y install ./wkhtmltox-0.12.6-1.centos8.x86_64.rpm
        fi

        if ! rpm -q apachetop &>/dev/null; then
            ProgressBar "Installing APACHETOP"
            sudo dnf -y install apachetop
        fi

        if ! command -v borg &>/dev/null; then
            ProgressBar "Installing BORG"
            sudo curl -L https://github.com/borgbackup/borg/releases/download/1.2.4/borg-linux64 -o /usr/local/bin/borg && sudo chmod +x /usr/local/bin/borg
        fi

        if ! command -v shfmt &>/dev/null; then
            ProgressBar "Installing SHFMT"
            sudo curl -Lo shfmt https://github.com/mvdan/sh/releases/download/v3.13.1/shfmt_v3.13.1_linux_amd64
            sudo chmod +x shfmt
            sudo mv shfmt /usr/local/bin/
        fi

        if ! rpm -q lftp &>/dev/null; then
            ProgressBar "Installing LFTP"
            sudo dnf -y install lftp
        fi

    fi

    if ! rpm -q vsftpd &>/dev/null; then
        sudo /go/vsftpd
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$OS" = "Debian" ]; then
        APT="apt -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install"
    elif [ "$OS" = "Ubuntu" ]; then
        export DEBIAN_FRONTEND='noninteractive'
        APT="apt -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install"
    fi

    # Ubuntu-specific Postfix configuration for mailutils
    if [ "$OS" = "Ubuntu" ]; then
        debconf-set-selections <<<"postfix postfix/mailname string $Hostname"
        debconf-set-selections <<<"postfix postfix/main_mailer_type string 'Internet Site'"
    fi

    sudo apt -y update
    sudo apt -y autoremove

    # Install all packages
    if ! dpkg -s screen >/dev/null 2>&1; then
        ProgressBar "Installing Screen"
        eval $APT screen
    fi

    if ! dpkg -s mailutils >/dev/null 2>&1; then
        ProgressBar "Installing Mail Utils"
        eval $APT mailutils
    fi

    if ! dpkg -s swaks >/dev/null 2>&1; then
        ProgressBar "Installing SWAKS"
        eval $APT swaks
    fi

    if ! dpkg -s sshpass >/dev/null 2>&1; then
        ProgressBar "Installing SSHPASS"
        eval $APT sshpass
    fi

    if ! dpkg -s bind9 >/dev/null 2>&1; then
        ProgressBar "Installing BIND9"
        eval $APT bind9
        sudo systemctl enable bind9

        if sudo test -f /etc/bind/named.conf.options  && sudo test ! -f /etc/bind/named.conf.options.bak ; then
            sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak
        fi

    fi

    if ! dpkg -s cron >/dev/null 2>&1; then
        ProgressBar "Installing CRONTAB"
        eval $APT cron
    fi

    if ! dpkg -s whois >/dev/null 2>&1; then
        ProgressBar "Installing Whois"
        eval $APT whois
    fi

    if ! dpkg -s telnet >/dev/null 2>&1; then
        ProgressBar "Installing TELNET"
        eval $APT telnet
    fi

    if ! dpkg -s net-tools >/dev/null 2>&1; then
        ProgressBar "Installing NET TOOLS"
        eval $APT net-tools
    fi

    if ! dpkg -s build-essential >/dev/null 2>&1; then
        ProgressBar "Installing Development Tools"
        eval $APT build-essential
    fi

    if ! dpkg -s nmap >/dev/null 2>&1; then
        ProgressBar "Installing NMAP"
        eval $APT nmap
    fi

    if ! dpkg -s psmisc >/dev/null 2>&1; then
        ProgressBar "Installing PSMISC"
        eval $APT psmisc
    fi

    if ! dpkg -s dnsutils >/dev/null 2>&1; then
        ProgressBar "Installing DIG & HOST"
        eval $APT dnsutils
    fi

    if ! dpkg -s inxi >/dev/null 2>&1; then
        ProgressBar "Installing INXI"
        eval $APT inxi
    fi

    if ! dpkg -s pv >/dev/null 2>&1; then
        ProgressBar "Installing PV"
        eval $APT pv
    fi

    if ! dpkg -s zip >/dev/null 2>&1; then
        ProgressBar "Installing ZIP"
        eval $APT zip
    fi

    if ! dpkg -s unzip >/dev/null 2>&1; then
        ProgressBar "Installing UNZIP"
        eval $APT unzip
    fi

    if ! dpkg -s rar >/dev/null 2>&1; then
        ProgressBar "Installing RAR"
        eval $APT rar
    fi

    if ! dpkg -s unrar >/dev/null 2>&1; then
        ProgressBar "Installing UnRAR"
        eval $APT unrar
    fi

    if ! dpkg -s p7zip-full >/dev/null 2>&1; then
        ProgressBar "Installing 7Z"
        eval $APT p7zip-full
    fi

    if ! dpkg -s nano >/dev/null 2>&1; then
        ProgressBar "Installing NANO & VIM"
        eval $APT nano
        eval $APT vim
        sudo cp /bin/nano /bin/edit
        sudo cp /bin/nano /bin/vi
        export VISUAL=nano
        export EDITOR="$VISUAL"
    fi

    if ! dpkg -s imagemagick >/dev/null 2>&1; then
        ProgressBar "Installing ImageMagick"
        eval $APT imagemagick
    fi

    if ! dpkg -s network-manager >/dev/null 2>&1; then
        ProgressBar "Installing NETWORK-MANAGER"
        eval $APT network-manager
    fi

    if ! dpkg -s sqlite3 >/dev/null 2>&1; then
        ProgressBar "Installing SQLite"
        eval $APT sqlite3
    fi

    if ! dpkg -s jq >/dev/null 2>&1; then
        ProgressBar "Installing JQ"
        eval $APT jq
    fi

    if ! dpkg -s s3fs >/dev/null 2>&1; then
        ProgressBar "Installing S3FS"
        eval $APT s3fs
    fi

    if ! dpkg -s cifs-utils >/dev/null 2>&1; then
        ProgressBar "Installing CIFS"
        eval $APT cifs-utils
    fi

    if ! command -v rclone >/dev/null 2>&1; then
        ProgressBar "Installing RCLONE"
        sudo curl -s https://rclone.org/install.sh | bash
    fi

    if ! dpkg -s fuse3 >/dev/null 2>&1; then
        ProgressBar "Installing FUSE3"
        eval $APT fuse3
    fi

    if ! dpkg -s bc >/dev/null 2>&1; then
        ProgressBar "Installing BC"
        eval $APT bc
    fi

    if ! dpkg -s netcat-traditional >/dev/null 2>&1; then
        ProgressBar "Installing NC"
        eval $APT netcat-traditional
    fi

    if ! dpkg -s redis >/dev/null 2>&1; then
        ProgressBar "Installing REDIS"
        eval $APT redis
        sudo systemctl enable redis
        sudo systemctl restart redis
    fi

    if ! dpkg -s dropbear >/dev/null 2>&1; then
        ProgressBar "Installing DROPBEAR"
        eval $APT dropbear
        sudo systemctl enable dropbear
        sudo systemctl restart dropbear
    fi

    if ! dpkg -s quota >/dev/null 2>&1; then
        ProgressBar "Installing QUOTA"
        eval $APT quota
    fi

    if ! dpkg -s gdisk >/dev/null 2>&1; then
        ProgressBar "Installing GDISK"
        eval $APT gdisk
    fi

    if ! command -v ttyd >/dev/null 2>&1; then
        ProgressBar "Installing TTYD"
        sudo wget -q https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 -O /usr/local/bin/ttyd
        sudo chmod +x /usr/local/bin/ttyd
    fi

    if ! dpkg -s geoip-bin >/dev/null 2>&1; then
        ProgressBar "Installing GEOIP"
        eval $APT geoip-bin
    fi

    if ! dpkg -s at >/dev/null 2>&1; then
        ProgressBar "Installing AT"
        eval $APT at
        sudo systemctl enable atd
        sudo systemctl restart atd
    fi

    if ! dpkg -s restic >/dev/null 2>&1; then
        ProgressBar "Installing RESTIC"
        eval $APT restic
    fi

    if ! dpkg -s ghostscript >/dev/null 2>&1; then
        ProgressBar "Installing GHOST SCRIPT"
        eval $APT ghostscript
    fi

    if ! dpkg -s xmlstarlet >/dev/null 2>&1; then
        ProgressBar "Installing XMLSTARLET"
        eval $APT xmlstarlet
    fi

    if ! dpkg -s rsyslog >/dev/null 2>&1; then
        ProgressBar "Installing RSYSLOG"
        eval $APT rsyslog
        sudo systemctl enable rsyslog
        sudo systemctl restart rsyslog
    fi

    if ! dpkg -s git >/dev/null 2>&1; then
        ProgressBar "Installing GIT"
        eval $APT git
    fi

    if ! dpkg -s npm >/dev/null 2>&1; then
        ProgressBar "Installing NPM (Node Package Manager)"
        eval $APT npm
    fi

    if ! dpkg -s libsodium-dev >/dev/null 2>&1; then
        ProgressBar "Installing SODIUM"
        eval $APT libsodium-dev
    fi

    if ! dpkg -s libsodium23 >/dev/null 2>&1; then
        ProgressBar "Installing LIBSODIUM"
        eval $APT libsodium23
    fi

    if ! dpkg -s gawk >/dev/null 2>&1; then
        ProgressBar "Installing GAWK"
        eval $APT gawk
    fi

    if sudo test ! -f /usr/local/goadmio/db/lite.db ; then

        if ! dpkg -s tesseract-ocr >/dev/null 2>&1; then
            ProgressBar "Installing OCR"
            eval $APT tesseract-ocr
        fi

        if ! dpkg -s jpegoptim >/dev/null 2>&1; then
            ProgressBar "Installing JPEGOPTIM"
            eval $APT jpegoptim
        fi

        if ! dpkg -s wkhtmltopdf >/dev/null 2>&1; then
            ProgressBar "Installing WKHTMLTOPDF"
            eval $APT wkhtmltopdf
        fi

        if ! dpkg -s apachetop >/dev/null 2>&1; then
            ProgressBar "Installing APACHETOP"
            eval $APT apachetop
        fi

        if ! command -v borg >/dev/null 2>&1; then
            ProgressBar "Installing BORG"
            sudo curl -L https://github.com/borgbackup/borg/releases/download/1.2.4/borg-linux64 -o /usr/local/bin/borg
            sudo chmod +x /usr/local/bin/borg
        fi

        if ! command -v shfmt &>/dev/null; then
            ProgressBar "Installing SHFMT"
            sudo curl -Lo shfmt https://github.com/mvdan/sh/releases/download/v3.13.1/shfmt_v3.13.1_linux_amd64
            sudo chmod +x shfmt
            sudo mv shfmt /usr/local/bin/
        fi

        if ! dpkg -s >/dev/null 2>&1; then
            ProgressBar "Installing LIBDBD-MariaDB-PERL"
            eval $APT libdbd-mariadb-perl
        fi

        if ! dpkg -s lftp >/dev/null 2>&1; then
            ProgressBar "Installing LFTP"
            eval $APT lftp
        fi

    fi

    if ! dpkg -s vsftpd >/dev/null 2>&1; then
        sudo /go/vsftpd
    fi   

fi

if ! command -v shc &>/dev/null; then
    sudo /go/shc
fi

if ! command -v cwebp &>/dev/null; then
    sudo /go/installwebp
fi
