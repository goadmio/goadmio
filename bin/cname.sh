#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$3" = "" ]; then
    sudo /go/cloudflare --domain $1 --type cname --value $2
else
    sudo /go/cloudflare --domain $1 --type cname --name $2 --value $3
fi
