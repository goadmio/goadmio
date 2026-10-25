#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

Version=$1

OS=$(</usr/local/goadmio/linux/os.db)
TimeStamp=$(date +'%s')

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
    sudo rm -f $LockFile
    exit 1
fi

if [[ ! $Version =~ ^[0-9]\.[0-9]$ ]]; then
    echo "Invalid PHP Version"
    sudo rm -f $LockFile
    exit 1
fi

if [[ ! "$@" = *"--force"* ]]; then

    if [ "$Version" = "8.5" ]; then
        echo "PHP 8.5 Required"
        sudo rm -f $LockFile
        exit 1
    fi

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Keep Numbers Only
    Version=$(echo "$Version" | sed 's/[^0-9]*//g')

    ProgressBar "Removing PHP $1" "$@"
    sudo /usr/bin/dnf -y remove php$Version

    ProgressBar "Removing PHP $1 FPM" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-fpm

    ProgressBar "Removing PHP $1 MEMCACHED" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-memcached

    ProgressBar "Removing PHP $1 MYSQL" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-mysql

    ProgressBar "Removing PHP $1 MYSQLND" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-mysqlnd

    ProgressBar "Removing PHP $1 PGSQL" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-pgsql

    ProgressBar "Removing PHP $1 DBA" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-dba

    ProgressBar "Removing PHP $1 DEVEL" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-devel

    ProgressBar "Removing PHP $1 EMBEDDED" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-embedded

    ProgressBar "Removing PHP $1 GD" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-gd

    ProgressBar "Removing PHP $1 IMAP" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-imap

    ProgressBar "Removing PHP $1 INTERBASE" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-interbase

    PROGRESSBAR "REMOVING PHP $1 INTL" "$@"
    sudo /usr/bin/dnf -y REMOVE PHP$VERSION-PHP-INTL

    PROGRESSBAR "REMOVING PHP $1 LDAP" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-ldap

    ProgressBar "Removing PHP $1 ZIP" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-zip

    ProgressBar "Removing PHP $1 MBSTRING" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-mbstring

    ProgressBar "Removing PHP $1 MCRYPT" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-mcrypt

    ProgressBar "Removing PHP $1 ODBC" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-odbc

    ProgressBar "Removing PHP $1 OPCACHE" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-opcache

    ProgressBar "Removing PHP $1 PEAR" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-pear

    ProgressBar "Removing PHP $1 BCMATH" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-bcmath

    ProgressBar "Removing PHP $1 SOAP" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-soap

    ProgressBar "Removing PHP $1 PROCESS" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-process

    ProgressBar "Removing PHP $1 PSPELL" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-pspell

    ProgressBar "Removing PHP $1 RECODE" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-recode

    ProgressBar "Removing PHP $1 XML" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-xml

    ProgressBar "Removing PHP $1 SIMPLEXML" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-simplexml

    ProgressBar "Removing PHP $1 XMLRPC" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-xmlrpc

    ProgressBar "Removing PHP $1 SSH2" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-ssh2

    ProgressBar "Removing PHP $1 PECL-SSH2" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-pecl-ssh2

    ProgressBar "Removing PHP $1 CTYPE" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-ctype

    ProgressBar "Removing PHP $1 FILEINFO" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-fileinfo

    ProgressBar "Removing PHP $1 JSON" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-json

    ProgressBar "Removing PHP $1 OPENSSL" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-openssl

    ProgressBar "Removing PHP $1 PDO" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-pdo

    ProgressBar "Removing PHP $1 TOKENIZER" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-tokenizer

    ProgressBar "Removing PHP $1 IMAGICK" "$@"
    sudo /usr/bin/dnf -y remove php$Version-php-imagick

    sudo /usr/bin/dnf -y remove php$Version-*

    sudo rm -rf /etc/opt/remi/php$Version
    sudo rm -rf /var/lib/php$Version

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    dpkg --configure -a

    ProgressBar "Removing PHP $1 LIBAPACHE2-MOD" "$@"
    sudo apt -y remove apt -y remove libapache2-mod-php$Version

    ProgressBar "Removing PHP $1" "$@"
    sudo apt -y remove php$Version

    ProgressBar "Removing PHP $1 FPM" "$@"
    sudo apt -y remove php$Version-fpm
    a2enconf php$Version-fpm

    ProgressBar "Removing PHP $1 MEMCACHED" "$@"
    sudo apt -y remove php$Version-memcached

    ProgressBar "Removing PHP $1 MYSQL" "$@"
    sudo apt -y remove php$Version-mysql

    ProgressBar "Removing PHP $1 MYSQLND" "$@"
    sudo apt -y remove php$Version-mysqlnd

    ProgressBar "Removing PHP $1 PGSQL" "$@"
    sudo apt -y remove php$Version-pgsql

    ProgressBar "Removing PHP $1 DBA" "$@"
    sudo apt -y remove php$Version-dba

    ProgressBar "Removing PHP $1 CURL" "$@"
    sudo apt -y remove php$Version-curl

    ProgressBar "Removing PHP $1 GD" "$@"
    sudo apt -y remove php$Version-gd

    ProgressBar "Removing PHP $1 IMAP" "$@"
    sudo apt -y remove php$Version-imap

    ProgressBar "Removing PHP $1 INTERBASE" "$@"
    sudo apt -y remove php$Version-interbase

    ProgressBar "Removing PHP $1 INTL" "$@"
    sudo apt -y remove php$Version-intl

    ProgressBar "Removing PHP $1 LDAP" "$@"
    sudo apt -y remove php$Version-ldap

    ProgressBar "Removing PHP $1 ZIP" "$@"
    sudo apt -y remove php$Version-zip

    ProgressBar "Removing PHP $1 MBSTRING" "$@"
    sudo apt -y remove php$Version-mbstring

    ProgressBar "Removing PHP $1 ODBC" "$@"
    sudo apt -y remove php$Version-odbc

    ProgressBar "Removing PHP $1 OPCACHE" "$@"
    sudo apt -y remove php$Version-opcache

    ProgressBar "Removing PHP $1 PEAR" "$@"
    sudo apt -y remove php$Version-pear

    ProgressBar "Removing PHP $1 BCMATH" "$@"
    sudo apt -y remove php$Version-bcmath

    ProgressBar "Removing PHP $1 SOAP" "$@"
    sudo apt -y remove php$Version-soap

    ProgressBar "Removing PHP $1 PSPELL" "$@"
    sudo apt -y remove php$Version-pspell

    ProgressBar "Removing PHP $1 XML" "$@"
    sudo apt -y remove php$Version-xml

    ProgressBar "Removing PHP $1 SIMPLEXML" "$@"
    sudo apt -y remove php$Version-simplexml

    ProgressBar "Removing PHP $1 XMLRPC" "$@"
    sudo apt -y remove php$Version-xmlrpc

    ProgressBar "Removing PHP $1 SSH2" "$@"
    sudo apt -y remove php$Version-ssh2

    ProgressBar "Removing PHP $1 CTYPE" "$@"
    sudo apt -y remove php$Version-ctype

    ProgressBar "Removing PHP $1 FILEINFO" "$@"
    sudo apt -y remove php$Version-fileinfo

    ProgressBar "Removing PHP $1 JSON" "$@"
    sudo apt -y remove php$Version-json

    ProgressBar "Removing PHP $1 OPENSSL" "$@"
    sudo apt -y remove php$Version-openssl

    ProgressBar "Removing PHP $1 PDO" "$@"
    sudo apt -y remove php$Version-pdo

    ProgressBar "Removing PHP $1 TOKENIZER" "$@"
    sudo apt -y remove php$Version-tokenizer

    ProgressBar "Removing PHP $1 IMAGICK" "$@"
    sudo apt -y remove php$Version-imagick

    sudo apt -y remove php$Version-*
    sudo rm -rf /etc/php/$Version

fi

# Keep Numbers Only
SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

# Sock Folders
sudo rm -rf /run/sock/$SockFolder

if [[ "$@" = *"--progress"* ]]; then
    ProgressBar "Removing PHP $1 completed successfully" "$@"
    echo "100"
fi

sudo rm -f $LockFile
