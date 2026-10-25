#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

sleep 1

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo systemctl reload php-fpm

    cd /etc/opt/remi
    for Version in *; do
        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then
            sudo systemctl reload $Version-php-fpm
        fi
    done

    if [ "$WS" = "NGINX" ]; then
        sudo systemctl reload nginx
    else
        sudo systemctl reload httpd
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php
    for Version in *; do

        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then
            sudo systemctl reload php$Version-fpm
        fi

    done

    if [ "$WS" = "NGINX" ]; then
        sudo systemctl reload nginx
    else
        sudo systemctl reload apache2
    fi

fi
