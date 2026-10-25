#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)
V=$((${VERSION%.*}))

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    ProgressBar "Installing REMI Repository"

    # Install PHP On AlmaLinux 9 & 10
    sudo dnf config-manager --set-enabled crb
    sudo dnf -y install dnf-utils
    sudo dnf -y install https://rpms.remirepo.net/enterprise/remi-release-$V.rpm

    ProgressBar "Updating Repository Packages"
    sudo dnf -y upgrade

    LatestStable=$(/go/listphp | tail -1)

    if [[ ! $LatestStable = *"."* ]]; then
        LatestStable="8.5"
    fi

    ProgressBar "Installing PHP${LatestStable} (CLI)"
    # Default Version $LatestStable
    sudo dnf -y module enable php:remi-$LatestStable
    sudo dnf -y install php
    sudo dnf -y install php-fpm

    for Ext in apcu bcmath bz2 ctype curl dba devel embedded fileinfo fpm gd gmp imap imagick interbase intl json ldap mbstring mcrypt memcached mysql mysqlnd odbc openssl opcache pdo pear pgsql process pspell rar recode redis soap sodium ssh2 simplexml tokenizer xml xmlrpc zip zlib; do
        ProgressBar "Installing PHP${LatestStable} ${Ext^^} (CLI)"
        sudo /usr/bin/dnf -y install "php-${Ext}"
    done

    sudo systemctl enable php-fpm

    sudo /go/installphp $LatestStable --install

    # Install SSH2
    sudo dnf -y install gcc libssh2 libssh2-devel

elif [ "$OS" = "Debian" ]; then

    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y install software-properties-common

    # Install PHP (On Debian)
    sudo apt -y install libapache2-mod-fcgid
    sudo apt -y install software-properties-common
    sudo apt -y install gnupg2
    sudo apt -y install lsb-release
    sudo apt -y install apt-transport-https
    sudo wget https://packages.sury.org/php/apt.gpg
    sudo apt-key add apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list

    ProgressBar "Updating Repository Packages"
    sudo apt -y update
    ProgressBar "Updating Repository Packages"
    sudo apt -y upgrade
    a2enmod actions alias proxy_fcgi fcgid

    # change default PHP version
    # update-alternatives --config php

    LatestStable=$(/go/listphp | tail -1)

    if [[ ! $LatestStable = *"."* ]]; then
        LatestStable="8.5"
    fi

    sudo /go/installphp $LatestStable --install

    # Default PHP Version ($LatestStable)
    a2dismod php$LatestStable
    a2dismod php8.4
    a2dismod php8.3
    a2dismod php8.2
    a2dismod php8.1
    a2dismod php8.0
    a2dismod php7.4
    a2dismod php7.3
    a2dismod php8.1
    a2dismod php7.1
    a2dismod php7.0
    a2dismod php5.6

    # Enable HTTP2
    a2dismod mpm_prefork
    a2enmod mpm_event
    a2enmod ssl
    a2enmod http2

    a2enmod php$LatestStable
    update-alternatives --set php /usr/bin/php$LatestStable

    # Enable Rewrite Mode
    a2enmod rewrite

elif [ "$OS" = "Ubuntu" ]; then

    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y install software-properties-common

    DEBIAN_FRONTEND='noninteractive' apt -y install libapache2-mod-fcgid
    add-apt-repository ppa:ondrej/php -y

    ProgressBar "Updating Repository Packages"
    DEBIAN_FRONTEND='noninteractive' apt -y update
    ProgressBar "Updating Repository Packages"
    DEBIAN_FRONTEND='noninteractive' apt -y upgrade

    a2enmod actions alias proxy_fcgi fcgid

    # change default PHP version
    # update-alternatives --config php

    LatestStable=$(/go/listphp | tail -1)

    if [[ ! $LatestStable = *"."* ]]; then
        LatestStable="8.5"
    fi

    sudo /go/installphp $LatestStable --install

    # Default PHP Version ($LatestStable)
    a2dismod php$LatestStable
    a2dismod php8.4
    a2dismod php8.3
    a2dismod php8.2
    a2dismod php8.1
    a2dismod php8.0
    a2dismod php7.4
    a2dismod php7.3
    a2dismod php7.2
    a2dismod php7.1
    a2dismod php7.0
    a2dismod php5.6

    # Enable HTTP2
    a2dismod mpm_prefork
    a2enmod mpm_event
    a2enmod ssl
    a2enmod http2

    a2enmod php$LatestStable
    update-alternatives --set php /usr/bin/php$LatestStable

    # Enable Rewrite Mode
    a2enmod rewrite

fi

if ! command -v php &>/dev/null; then

    echo "Installing PHP Failed"
    ProgressBar "Installing PHP Failed"
    exit 1

fi

# Enable php session
sudo mkdir -p /var/lib/php/session
sudo chmod 777 /var/lib/php/session
sudo chmod -R 777 /var/lib/php

# php.ini default values
sudo /go/phpini

# Backup Default Configuration
sudo /go/phpini backup
