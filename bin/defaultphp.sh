#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Version=$1

source /go/function

if [ $# -eq 0 ]; then

    CurrentPHP=$(php -v | sed -n 1p | awk '{print $1 $2}')

    echo "$CurrentPHP"

    exit 1
fi

LockFile="/usr/local/goadmio/lock/installphp.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        ProgressBar "Instance ($InstanceFile) already running. Try again later" "$@"
        exit 1
    fi
fi
echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
# Run When Click Ctrl+C
trap 'sudo rm -f "$LockFile"' EXIT

if [[ ! $Version = "5.6" ]] && [[ ! $Version = "7.0" ]] && [[ ! $Version = "7.1" ]] && [[ ! $Version = "7.2" ]] && [[ ! $Version = "7.3" ]] && [[ ! $Version = "7.4" ]] && [[ ! $Version = "8.0" ]] && [[ ! $Version = "8.1" ]] && [[ ! $Version = "8.2" ]] && [[ ! $Version = "8.3" ]] && [[ ! $Version = "8.4" ]] && [[ ! $Version = "8.5" ]] && [[ ! $Version = "8.6" ]]; then
    echo "Invalid PHP Version"
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    ProgressBar "Deleting Default PHP (CLI)" "$@"
    sudo dnf remove -y php-*

    ProgressBar "Installing REMI 8" "$@"
    sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

    sudo yum-config-manager --disable remi-php56
    sudo yum-config-manager --disable remi-php70
    sudo yum-config-manager --disable remi-php71
    sudo yum-config-manager --disable remi-php72
    sudo yum-config-manager --disable remi-php73
    sudo yum-config-manager --disable remi-php74
    sudo yum-config-manager --disable remi-php80
    sudo yum-config-manager --disable remi-php81
    sudo yum-config-manager --disable remi-php82
    sudo yum-config-manager --disable remi-php83
    sudo yum-config-manager --disable remi-php84
    sudo yum-config-manager --disable remi-php85
    sudo yum-config-manager --disable remi-php86
    sudo yum-config-manager --disable remi-php87
    sudo yum-config-manager --disable remi-php88

    ProgressBar "Installing PHP $Version" "$@"

    if [ "$Version" = "5.6" ]; then

        sudo yum-config-manager --enable remi-php56
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-5.6

    elif [ "$Version" = "7.0" ]; then

        sudo yum-config-manager --enable remi-php70
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-7.0

    elif [ "$Version" = "7.1" ]; then

        sudo yum-config-manager --enable remi-php71
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-7.1

    elif [ "$Version" = "7.2" ]; then

        sudo yum-config-manager --enable remi-php72
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-7.2

    elif [ "$Version" = "7.3" ]; then

        sudo yum-config-manager --enable remi-php73
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-7.3

    elif [ "$Version" = "7.4" ]; then

        sudo yum-config-manager --enable remi-php74
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-7.4

    elif [ "$Version" = "8.0" ]; then

        sudo yum-config-manager --enable remi-php80
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.0

    elif [ "$Version" = "8.1" ]; then

        sudo yum-config-manager --enable remi-php81
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.1

    elif [ "$Version" = "8.2" ]; then

        sudo yum-config-manager --enable remi-php82
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.2

    elif [ "$Version" = "8.3" ]; then

        sudo yum-config-manager --enable remi-php83
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.3

    elif [ "$Version" = "8.4" ]; then

        sudo yum-config-manager --enable remi-php84
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.4

    elif [ "$Version" = "8.5" ]; then

        sudo yum-config-manager --enable remi-php85
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.5

    elif [ "$Version" = "8.6" ]; then

        sudo yum-config-manager --enable remi-php86
        sudo dnf -y install php
        sudo dnf module reset -y php
        sudo dnf module install -y php:remi-8.6

    fi

    ProgressBar "Installing PHP Packages" "$@"
    sudo dnf -y install --skip-broken php-memcached php-mysqlnd php-pgsql php-dba php-devel php-embedded php-fpm php-gd php-imap php-interbase php-intl php-ldap php-zip php-mbstring php-mcrypt php-odbc php-opcache php-pear php-bcmath php-soap php-process php-pspell php-recode php-xml php-xmlrpc php-ssh2 php-pecl-ssh2 php-gmp
    sudo systemctl enable php-fpm

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if sudo test ! -f "/etc/php/$Version/fpm/php.ini" ; then

        echo "PHP $Version not installed. To install PHP $Version, run the following command as root:"
        echo "/go/installphp $Version"

        exit 1

    fi

    a2dismod php5.6
    a2dismod php7.0
    a2dismod php7.1
    a2dismod php7.2
    a2dismod php7.3
    a2dismod php7.4
    a2dismod php8.0
    a2dismod php8.1
    a2dismod php8.2
    a2dismod php8.3
    a2dismod php8.4
    a2dismod php8.5
    a2dismod php8.6
    a2dismod php8.7
    a2dismod php8.8

    a2enmod php$Version
    update-alternatives --set php /usr/bin/php$Version

    sudo systemctl restart apache2

fi

sudo /go/composer
sudo /go/session
sudo /go/so
sudo /go/fpm

sudo rm -rf /usr/local/goadmio/db/lock.db

if [[ "$@" = *"--progress"* ]]; then
    ProgressBar "Change Default PHP Version Completed Successfully" "$@"
    echo "100"
fi

sudo rm -f $LockFile
