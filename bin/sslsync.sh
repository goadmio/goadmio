#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Port=$3

sudo mkdir -p /usr/local/goadmio/tmp/serversync

if [ "$Port" = "" ]; then
    Port="22222"
fi

echo "Copying SSL to $RemoteServer..."

sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /etc/letsencrypt/ root@$RemoteServer:/etc/letsencrypt/

echo "1" | sudo tee /usr/local/goadmio/tmp/serversync/SSL >/dev/null
