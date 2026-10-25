#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [ "$WS" = "NGINX" ]; then

    echo "PHP-FPM Required By NGINX"
    exit 1

fi

if [ "$OS" = "Debian" ] || [ "$OS" = "Ubuntu" ]; then

    echo "PHP-FPM Required By Debian & Ubuntu"
    exit 1

else

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FPM=0;"
    sudo /go/conf

    # Delete All Pool Files except www.conf
    sudo find /etc/opt/remi/*/php-fpm.d -type f -not -name "www.conf" -print0 | xargs -0 -I {} rm {}

    sudo /go/go
    sudo /go/fpm "| Executed by $(basename "$0")"
fi
