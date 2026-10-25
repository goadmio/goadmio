#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Version=$1

# Keep Numbers Only
SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

source /go/function

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

if [ $# -eq 0 ]; then
    echo "Usage: removephp <Version>"
    exit 1
fi

if [[ ! $Version =~ ^[0-9]\.[0-9]$ ]]; then
    echo "Invalid PHP Version"
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Keep Numbers Only
    Version=$(echo "$Version" | sed 's/[^0-9]*//g')

    sudo /usr/bin/dnf -y install php$Version

    for Ext in apcu bcmath bz2 ctype curl dba devel embedded fileinfo fpm gd gmp imap imagick intl json ldap mbstring memcached mysql mysqlnd odbc openssl opcache pdo pear pgsql process pspell rar redis soap sodium sqlite3 ssh2 simplexml tokenizer xml zip zlib; do
        ProgressBar "Installing PHP $1 ${Ext^^}" "$@"
        sudo /usr/bin/dnf -y install "php${Version}-php-${Ext}"
    done

    # Multi PHP-FPM Change Default PORT 9000
    sudo sed -i "s/:9000/:90${Version}/" /etc/opt/remi/php$Version/php-fpm.d/www.conf

    # Sock Folders
    sudo mkdir /etc/opt/remi/php${Version}/php-fpm

    sudo mkdir /var/lib/php${Version}
    sudo mkdir /var/lib/php${Version}/session
    sudo mkdir /var/lib/php${Version}/wsdlcache

    sudo chmod -R 777 /var/lib/php${Version}

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$OS" = "Ubuntu" ]; then
        APT="DEBIAN_FRONTEND='noninteractive' apt"
    else
        APT="apt"
    fi

    dpkg --configure -a

    eval $APT -y purge php${Version}*
    eval $APT -y purge php${Version}-*

    eval $APT -y install libapache2-mod-php${Version}

    eval $APT -y install php${Version}

    for Ext in apcu bcmath bz2 ctype curl dba dev fileinfo fpm gd gmp imap imagick intl ldap mbstring memcached mysql odbc pdo pgsql pspell redis soap sqlite3 ssh2 tokenizer xml zip; do
        ProgressBar "Installing PHP $1 ${Ext^^}" "$@"
        eval $APT -y install "php${Version}-${Ext}"
    done

    a2enconf php${Version}-fpm

    # Remove line starts with
    sudo sed -i "/^listen =/d" /etc/php/${Version}/fpm/pool.d/www.conf

    SockPort=$(echo "$Version" | sed 's/[^0-9]*//g')
    echo "listen = 127.0.0.1:90${SockPort}" | sudo tee -a /etc/php/${Version}/fpm/pool.d/www.conf >/dev/null

fi

# Sock Folders
sudo mkdir -p /run/sock
sudo mkdir -p /run/sock/${SockFolder}
sudo chmod 777 /run/sock/${SockFolder}

# Do not run php default value many times if this file run while install go
if [[ ! "$@" = *"--install"* ]]; then

    sudo /go/phpini
    sudo /go/session
    sudo /go/web
    sudo /go/fpm enable

else

    sudo /go/web
    sudo /go/fpm enable

fi

sudo rm -rf /usr/local/goadmio/tmp/lock.db

if [[ "$@" = *"--progress"* ]]; then
    ProgressBar "Installing PHP $1 completed successfully" "$@"
    echo "100"
fi

sudo rm -f $LockFile
