#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

File=$1
RemoteServer=$2
RemotePassword=$3

if [ "$File" = "all" ]; then

    cd /backup
    for File in *; do

        if [[ "$File" = *".tar.gz" ]]; then

            sudo /go/scp $File $RemoteServer $RemotePassword

        fi

    done

    exit 1

fi

if [ "$File" = "" ]; then
    read -p "File Name: " -e File
fi

if [ "$RemoteServer" = "" ]; then
    read -p "Remote Server: " -e RemoteServer
fi

if [ "$RemotePassword" = "" ]; then
    read -p "Remote Password: " -e RemotePassword
fi

if [[ ! $File = *"."* ]]; then
    echo "Invalid file name or domain name"
    exit 1
fi

if [[ "$File" = *"/"* ]]; then
    echo "Do not enter file path $File, Just file name or domain name."
    exit 1
fi

if [[ ! $RemoteServer = *"."* ]]; then
    echo "Invalid Remote Server $RemoteServer."
    exit 1
fi

# get newer file backup
LocalFile=$(sudo find /backup -type f -name "*$File*" -printf "%T+ %p\n" | sort -r | head -n 1 | cut -d ' ' -f2)

if [[ ! $LocalFile = *".tar.gz" ]]; then

    if sudo test -f "/home/$Domain/$File" ; then
        LocalFile="/home/$Domain/$File"
    elif sudo test -f "/home/$File" ; then
        LocalFile="/home/$File"
    elif sudo test -f "/root/$File" ; then
        LocalFile="/root/$File"
    fi

fi

if [[ ! $LocalFile = *".tar.gz" ]]; then
    echo "File $File not exists."
    exit 1
fi

RemoteDir="/backup"
RemoteUser="root"

echo "Copying $LocalFile To $RemoteServer:$RemoteDir"
sudo sshpass -p "$RemotePassword" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $LocalFile $RemoteUser@$RemoteServer:$RemoteDir

history -c
