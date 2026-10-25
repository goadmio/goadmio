#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Port=$3

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Port" = "" ]; then
    Port="22222"
fi

sudo mkdir -p /usr/local/goadmio/tmp/serversync

echo "Copying MariaDB/MySQL to $RemoteServer..."

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/mysqlreset $MySQLRootPassword"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "systemctl stop mariadb"

sudo systemctl stop mariadb
sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/lib/mysql/ root@$RemoteServer:/var/lib/mysql/
sudo systemctl start mariadb

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "chown -R mysql:mysql /var/lib/mysql"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "systemctl restart mariadb"

echo "1" | sudo tee /usr/local/goadmio/tmp/serversync/MariaDB >/dev/null
