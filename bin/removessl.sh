#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [ "$WS" = "Apache" ]; then

        sudo dnf -y remove certbot python3-certbot-apache

    else

        sudo dnf -y remove certbot python3-certbot-nginx

    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$WS" = "Apache" ]; then

        sudo apt -y remove certbot python3-certbot-apache

    else

        sudo apt -y remove certbot python3-certbot-nginx

    fi

fi
