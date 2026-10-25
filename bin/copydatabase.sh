#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 '********' $4 >>/var/log/go/$(basename "$0").log

Name=$1
RemoteServer=$2
RemotePassword=$3

# Optional (Copy to Another Database Name)
DBName=$4
Port=$5

if [ "$Port" = "" ]; then
    Port="22222"
fi


echo -ne "Copying $Name Database to $RemoteServer | "

echo -ne "Dumping..."
sudo mariadb-dump $Name >/root/$Name.sql

echo -ne "\b\b\b\b\b\b\b\b\b\bCopying..."
sudo sshpass -p "$RemotePassword" rsync -azlh --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /root/$Name.sql root@$RemoteServer:/root

if [ "$DBName" != "" ]; then

    echo -ne "\b\b\b\b\b\b\b\b\b\bImporting to $DBName..."
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb -e 'CREATE DATABASE IF NOT EXISTS $DBName;'"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb $DBName < /root/$Name.sql"

else

    echo -ne "\b\b\b\b\b\b\b\b\b\bImporting..."
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb -e 'CREATE DATABASE IF NOT EXISTS $Name;'"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb $Name < /root/$Name.sql"

fi

echo ""