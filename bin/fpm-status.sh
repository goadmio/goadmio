#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    cd /etc/opt/remi
    for Version in *; do
        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            FMPStatus=$(systemctl status $Version-php-fpm)
            if [[ "$FMPStatus" = *"(dead)"* ]]; then

                echo "Restarting $Version-php-fpm..."
                sudo systemctl restart $Version-php-fpm

            fi

        fi
    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php
    for Version in *; do
        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            FMPStatus=$(systemctl status php$Version-fpm)
            if [[ "$FMPStatus" = *"(dead)"* ]]; then

                echo "Restarting php$Version-fpm..."
                sudo systemctl restart php$Version-fpm

            fi

        fi
    done

fi
