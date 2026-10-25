#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
Hostname=$(</etc/hostname)

Reload=0

if [ "$WS" = "NGINX" ]; then

    nginx -t >/usr/local/goadmio/tmp/checknginx.db 2>&1

    sudo grep -oP '/live/\K[^/]+' /usr/local/goadmio/tmp/checknginx.db | sort | uniq >/usr/local/goadmio/tmp/nginx.db

    Line="/usr/local/goadmio/tmp/nginx.db"
    while IFS= read Domain; do

        if sudo test -d "/home/$Domain/www" ; then

            Reload=1

            echo "Deleting $Domain Configuration"

            sudo rm -rf /etc/nginx/vbost/$Domain.conf

        fi

    done <"$Line"

fi

if [ "$Reload" = "1" ]; then

    sudo /go/conf

fi
