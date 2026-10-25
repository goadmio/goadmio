#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
Hostname=$(</etc/hostname)

Reload=0

if [ "$WS" = "Apache" ]; then

    apachectl configtest >/usr/local/goadmio/tmp/checkapache.db 2>&1

    sudo grep -oP '/live/\K[^/]+' /usr/local/goadmio/tmp/checkapache.db | sort | uniq >/usr/local/goadmio/tmp/apache.db

    Line="/usr/local/goadmio/tmp/apache.db"
    while IFS= read Domain; do

        if sudo test -d "/home/$Domain/www" ; then

            Reload=1

            echo "Deleting $Domain Configuration"

            sudo rm -rf /etc/httpd/vbost/$Domain-le-ssl.conf
            sudo rm -rf /etc/apache2/vbost/$Domain-le-ssl.conf

        fi

    done <"$Line"

fi

if [ "$Reload" = "1" ]; then

    sudo /go/conf

fi
