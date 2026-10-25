#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$2" = "" ]; then
    sudo /go/cloudflare --domain $1 --type dmarc
else
    sudo /go/cloudflare --domain $1 --type dmarc --value $2
fi
