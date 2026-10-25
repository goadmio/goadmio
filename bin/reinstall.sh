#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo /go/os

if sudo test ! -f "/usr/local/goadmio/linux/ws.db" ; then
    echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null
fi

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    VersionPath="/etc/opt/remi"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    VersionPath="/etc/php"
fi

sudo mkdir -p /run/sock

sudo /go/server

# Install Default PHP
sudo /go/installphp 8.4

if sudo test -d "/etc/opt/remi/php81"  || sudo test -d "/etc/php/8.1" ; then
    sudo /go/installphp 8.1
fi

if sudo test -d "/etc/opt/remi/php80"  || sudo test -d "/etc/php/8.0" ; then
    sudo /go/installphp 8.0
fi

if sudo test -d "/etc/opt/remi/php74"  || sudo test -d "/etc/php/7.4" ; then
    sudo /go/installphp 7.4
fi

if sudo test -d "/etc/opt/remi/php73"  || sudo test -d "/etc/php/7.3" ; then
    sudo /go/installphp 7.3
fi

if sudo test -d "/etc/opt/remi/php72"  || sudo test -d "/etc/php/7.2" ; then
    sudo /go/installphp 7.2
fi

if sudo test -d "/etc/opt/remi/php71"  || sudo test -d "/etc/php/7.1" ; then
    sudo /go/installphp 7.1
fi

if sudo test -d "/etc/opt/remi/php70"  || sudo test -d "/etc/php/7.0" ; then
    sudo /go/installphp 7.0
fi

if sudo test -d "/etc/opt/remi/php56"  || sudo test -d "/etc/php/5.6" ; then
    sudo /go/installphp 5.6
fi

sudo /go/installmail
sudo /go/conf

cd $VersionPath
for Version in *; do

    SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')
    sudo mkdir -p /run/sock/$SockFolder
    sudo chmod 777 /run/sock/$SockFolder

done

sudo /go/fix
sudo /go/resolver

sudo mariadb -e "truncate table Httplog"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Fix SSL Problems
    sudo yum -y install ca-certificates

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # Fix SSL Problems
    sudo apt -y install ca-certificates

fi

sudo /go/fpm "| Executed by $(basename "$0")"
