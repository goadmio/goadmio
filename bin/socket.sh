#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1

cd /etc/httpd/vhost
for File in *; do

    Proxy=$(sudo grep -i "unix:" $File)

    if [[ "$Proxy" = *"unix:"* ]]; then

        IFS=':' read -r -a Array <<<"$Proxy"

        ProxyTwo="${Array[1]}"

        IFS='|' read -r -a ArrayTwo <<<"$ProxyTwo"

        P="${ArrayTwo[0]}"

        if [ ! -S "$P" ]; then
            echo "FPM Socket Missing $P in File /etc/httpd/vhost/$File"

            if [ "$Action" = "delete" ]; then
                echo "Deleting /etc/httpd/vhost/$File ..."
                sudo rm -rf /etc/httpd/vhost/$File
            fi

        fi

    fi

done
