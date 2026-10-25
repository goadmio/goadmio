#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 $3 '********' >>/var/log/go/$(basename "$0").log

Domain=$1
RemoteServer=$2
RemotePassword=$3
Port=$4

if [ "$Port" = "" ]; then
    Port="22222"
fi

if [ $# -ge 3 ]; then

    /go/mailconf $Domain
    
    sudo sshpass -p "$RemotePassword" rsync -azlh --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/mail/ root@$RemoteServer:/home/$Domain/mail/

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/fix $Domain"

else

    echo "Invalid Parameters"

fi