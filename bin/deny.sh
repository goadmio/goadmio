#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

PORT=$1

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Invalid PORT"
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [ "$PORT" = "22" ]; then
        sudo firewall-cmd --zone=public --remove-service=ssh --permanent | sed '/success/d'
    fi

    if [ "$PORT" = "3306" ]; then
        sudo firewall-cmd --zone=public --remove-service=mysql --permanent | sed '/success/d'
    fi

    sudo firewall-cmd --zone=public --remove-port=$PORT/tcp --permanent | sed '/success/d'

    sudo firewall-cmd --reload >/dev/null 2>&1

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$PORT" = "22" ]; then
        sudo ufw delete allow ssh
    fi

    if [ "$PORT" = "3306" ]; then
        sudo ufw delete allow mysql
    fi

    sudo ufw delete allow $PORT/tcp
    sudo ufw reload >/dev/null 2>&1

fi
