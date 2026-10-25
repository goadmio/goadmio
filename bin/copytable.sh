#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 $3 '********' $6 | tee /var/log/go/$(basename "$0").log

LockFile="/usr/local/goadmio/lock/backup.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi
echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
# Run When Click Ctrl+C
trap 'sudo rm -f "$LockFile"' EXIT

Name=$1
Table=$2
RemoteServer=$3
RemotePassword=$4

# Optional (Copy to Another Database Name)
DBName=$5
Port=$6

if [ "$Port" = "" ]; then
    Port="22222"
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

E=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select count(*) from $Name.$Table;" 2>/dev/null)
if [ $? -ne "0" ]; then
    # MySQL error
    echo "Table $Name.$Table doesn't exist."
    exit 1
fi

echo -ne "Copying $Name.$Table Database Table to $RemoteServer | "

echo -ne "Dumping..."
sudo mariadb-dump $Name $Table >/root/$Name-$Table.sql

sudo sshpass -p "$RemotePassword" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q /root/$Name-$Table.sql root@$RemoteServer:/root

echo -ne "\b\b\b\b\b\b\b\b\b\bCopying..."
sudo sshpass -p "$RemotePassword" rsync -azlh -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /root/$Name-$Table.sql root@$RemoteServer:/root

if [ "$DBName" != "" ]; then

    # Copy to Another Database Name
    echo -ne "\b\b\b\b\b\b\b\b\b\bImporting to $DBName..."
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb -e 'CREATE DATABASE IF NOT EXISTS $DBName;'"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb $DBName < /root/$Name-$Table.sql"

else

    # Copy to Same Database Name
    echo -ne "\b\b\b\b\b\b\b\b\b\bImporting..."
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb -e 'CREATE DATABASE IF NOT EXISTS $Name;'"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "mariadb $Name < /root/$Name-$Table.sql"

fi

echo ""

sudo rm -f $LockFile
