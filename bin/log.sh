#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $# -eq 0 ]; then

    # Log Files
    sudo find /var/log/go -maxdepth 1 -type f -name "*.log" ! -name "*-2*" -exec bash -c 'mv "$0" "${0%.log}-$(date +"%Y%m%d").log"' {} \;
    sudo find /var/log/go -maxdepth 1 -type f -name "*-2*.log" -mtime +6 -exec gzip {} \;
    sudo find /var/log/go -type f -mtime +49 -delete

    exit 1

fi

Message=$1
File=$2
Type=$3

sudo mkdir -p /var/log/go/$File

if [ "$Type" = "" ]; then
    Type="$File"
fi

echo $(date +"%Y-%m-%d %H:%M:%S") "$Message" | sudo tee -a /var/log/go/$File/$Type-$(date +"%Y-%m-%d").log >/dev/null
