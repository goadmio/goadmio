#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    cd /etc/opt/remi
    for Version in *; do

        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            if ! grep -q "/usr/local/goadmio/includes" /etc/opt/remi/$Version/php.ini; then

                sudo sed -i "/^include_path/d" /etc/opt/remi/$Version/php.ini
                echo "include_path = /usr/local/goadmio/includes" | sudo tee -a /etc/opt/remi/$Version/php.ini >/dev/null

            fi

        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php
    for Version in *; do

        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            if ! grep -q "/usr/local/goadmio/includes" /etc/php/$Version/fpm/php.ini; then

                sudo sed -i "/^include_path/d" /etc/php/$Version/fpm/php.ini
                echo "include_path = /usr/local/goadmio/includes" | sudo tee -a /etc/php/$Version/fpm/php.ini >/dev/null

            fi

        fi

    done

fi