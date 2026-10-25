#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Port=$3

if [ "$Port" = "" ]; then
    Port="22222"
fi

echo "Copying PostgreSQL to $RemoteServer..."

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "systemctl stop postgresql"
sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/lib/pgsql/data/ root@$RemoteServer:/var/lib/pgsql/data/
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "chown -R postgres:postgres /var/lib/pgsql/data"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "systemctl restart postgresql"
