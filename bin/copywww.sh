#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 $3 '********' >>/var/log/go/$(basename "$0").log

From=$1
To=$2
RemoteServer=$3
RemotePassword=$4
Port=$5

if [ "$Port" = "" ]; then
    Port="22222"
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)

if [ $# -eq 2 ] || [ $# -eq 3 ]; then

    if [[ ! $@ = *"--force"* ]]; then

        if sudo test -f "/home/$To/www/index.php"  || sudo test -f "/home/$To/www/index.html"  || sudo test -f "/home/$To/www/index.htm" ; then

            echo "Unable to copy files, The directory /home/$To/www is not empty."
            exit 1

        fi

    fi

    rsync -azlh --rsync-path="sudo rsync" /home/$From/www/ /home/$To/www/
    sudo chown -R $To:$To /home/$To/www

    echo "Transferring files from $From to $To..."

elif [ $# -eq 4 ]; then

    if [[ ! "$RemoteServer" = *"."* ]]; then
        echo "Invalid Remote Server $RemoteServer"
        exit 1
    fi

    echo "Transferring files from $From to $To..."
    sudo sshpass -p "$RemotePassword" rsync -azlh --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$From/www/ root@$RemoteServer:/home/$To/www/
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "chown -R $To:$To /home/$To/www"

else

    echo "Invalid Parameters"

fi