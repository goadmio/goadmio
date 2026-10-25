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
        sudo firewall-cmd --zone=public --add-service=ssh --permanent >/dev/null 2>&1
    fi

    if [ "$PORT" = "80" ]; then
        sudo firewall-cmd --zone=public --add-service=http --permanent >/dev/null 2>&1
    fi

    if [ "$PORT" = "3306" ]; then
        sudo firewall-cmd --zone=public --add-service=mysql --permanent >/dev/null 2>&1
    fi

    sudo firewall-cmd --zone=public --add-port=$PORT/tcp --permanent >/dev/null 2>&1
    sudo firewall-cmd --reload >/dev/null 2>&1

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$PORT" = "22" ]; then
        sudo ufw allow ssh >/dev/null 2>&1
    fi

    if [ "$PORT" = "80" ]; then
        sudo ufw allow http >/dev/null 2>&1
    fi

    if [ "$PORT" = "3306" ]; then
        sudo ufw allow mysql >/dev/null 2>&1
    fi

    sudo ufw allow $PORT/tcp >/dev/null 2>&1
    
    sudo ufw reload >/dev/null 2>&1

fi
