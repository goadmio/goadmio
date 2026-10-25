#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")

if [ "$AdminEmail" = "" ]; then

    echo "Enter administrator email"

    exit 1

fi

Schedule=$(</usr/local/goadmio/db/primary.db)
IFS='|' read -r -a Array <<<"$Schedule"
D="${Array[0]}"
Type="${Array[1]}"
Destination="${Array[2]}"
RemoteServer="${Array[3]}"
RemoteUser="${Array[4]}"
Port="${Array[6]}"
RemoteDir="${Array[7]}"
Email="${Array[8]}"
SHA1="${Array[5]}"

if [ "$Destination" = "LOCAL" ] && [ "$D" = "0" ]; then

    echo "Scheduled backup not working, It is recommended that you maintain a daily backup plan"
    exit 1

fi

if [ "$Destination" = "SCP" ]; then

    LYR=$(echo -n "$SHA1|primary" | md5sum | awk '{print $1}')

    if sudo test -f /usr/local/goadmio/db/$LYR.db ; then
        RemotePassword=$(sudo openssl pkeyutl -inkey /etc/primary.key -decrypt </usr/local/goadmio/db/$LYR.db)
    fi

    RemotePassword=$(sudo openssl pkeyutl -inkey /etc/primary.key -decrypt </usr/local/goadmio/db/$LYR.db)
    RemotePassword=$(echo "$RemotePassword" | base64 --decode)

    echo "" | sudo tee /usr/local/goadmio/connection.db >/dev/null
    sudo sshpass -p "$RemotePassword" rsync -e "ssh -p $Port -o StrictHostKeyChecking=no -o LogLevel=QUIET" /usr/local/goadmio/connection.db $RemoteUser@$RemoteServer:$RemoteDir/connection.db &>/usr/local/goadmio/db/scp.db

    if grep -q "permission" /usr/local/goadmio/db/scp.db || grep -q "denied" /usr/local/goadmio/db/scp.db; then

        echo "Scheduled backup not working, REMOTE: Invalid username or password."
        exit 1
    fi

fi

DiskSpacePercent=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g')
if [ "$DiskSpacePercent" -ge "90" ]; then

    echo "Your disk space is running low"

    sudo /go/sendmail "Go - Your disk space is running low" "Go - Your disk space is running low" "Disk Usage"
    sudo /go/sendwhatsapp "Go - Your disk space is running low" "Disk Usage"

    exit 1

fi

if [ "$Hostname" = "" ]; then

    echo "Hostname is not valid."

    exit 1

fi

IP=$(dig $Hostname +short | tail -n1)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [ "$IP" != "$ServerIP" ]; then

    echo "Hostname $Hostname Not Resolving To $ServerIP"

    exit 1

fi

if sudo test ! -f /etc/nameservers ; then

    echo "Configure nameservers or set up Cloudflare API"

    exit 1

fi
