#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Port=$3

if [ "$Port" = "" ]; then
    Port="22"
fi

echo "Copying WA to $RemoteServer..."

sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /usr/local/goadmio/wa/ root@$RemoteServer:/usr/local/goadmio/wa/
