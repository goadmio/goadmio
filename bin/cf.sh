#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

From=$1
To=$2
RemoteServer=$3
RemotePassword=$4
Port=$5

if [ "$Port" = "" ]; then
    Port="22222"
fi

if [ $# -eq 4 ]; then

    if sudo test ! -d "$From" ; then

        echo "$From Folder not exists."
        exit 1

    fi

    if [[ ! "$From" = *"/" ]]; then

        From="$From/"

    fi

    if [[ ! "$To" = *"/" ]]; then

        To="$To/"

    fi

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mkdir -P $To"

    echo "Transferring files from $From to $To..."
    sudo sshpass -p "$RemotePassword" rsync -azlh -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" $From $RemoteServer:$To

    exit 1

fi

if [[ "$1" = *"/"* ]] && [[ "$2" = *"/"* ]]; then

    if sudo test ! -d "$From" ; then

        echo "$From Folder not exists."
        exit 1

    fi

    if sudo test ! -d "$To" ; then

        echo "$To Folder not exists."
        exit 1

    fi

    if [[ ! "$From" = *"/" ]]; then

        From="$From/"

    fi

    if [[ ! "$To" = *"/" ]]; then

        To="$To/"

    fi

    rsync -azlh $From $To

fi
