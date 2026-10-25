#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Directory=$1
RemoteServer=$2
RemotePassword=$3
Port=$4

if [ "$Port" = "" ]; then
    Port="22222"
fi

echo "Copying $Directory to $RemoteServer..."

if sudo test ! -d "$Directory" ; then

    "Folder $Directory not exists."

    exit 1

fi

if [[ ! "$Directory" = *"/" ]]; then

    Directory="$Directory/"

fi

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mkdir -p $Directory"
sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" $Directory root@$RemoteServer:$Directory
