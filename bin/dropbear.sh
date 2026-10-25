#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

Port=$1

if [ "$1" = "port" ] || [ "$1" = "PORT" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo cat /etc/sysconfig/dropbear | grep "\-p" | sed "s/[^0-9]//g"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo cat /etc/default/dropbear | grep "DROPBEAR_PORT" | sed "s/[^0-9]//g"

    fi

    exit 1
fi

if [ "$Port" = "" ]; then
    Port=22222
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! rpm -q dropbear &>/dev/null; then
        sudo dnf -y install dropbear
    fi

    echo "OPTIONS=\"-p $Port\"" | sudo tee /etc/sysconfig/dropbear >/dev/null

    sudo firewall-cmd --zone=public --add-port=$Port/tcp --permanent
    sudo firewall-cmd --reload

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if ! dpkg -s dropbear >/dev/null 2>&1; then
        sudo apt -y install dropbear
    fi
    
    echo "DROPBEAR_PORT=$Port" | sudo tee /etc/default/dropbear >/dev/null
    echo "DROPBEAR_EXTRA_ARGS=\"\"" | sudo tee -a /etc/default/dropbear >/dev/null

    sudo ufw allow $Port/tcp
    sudo ufw reload

else
    echo "Unknown operating system."
    exit 1
fi

if [[ ! "$@" = *"--install"* ]]; then
    sudo /go/config --force
fi

sudo systemctl enable dropbear
sudo systemctl restart dropbear