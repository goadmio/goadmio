#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

TimeStamp=$(date +'%s')

if sudo test -d /home/$Domain/www ; then

    echo "Can't recover an active account."

else

    sudo /go/snapshot $Domain restore latest

    if sudo test -d /home/$Domain/www ; then
        echo "Account $Domain has been restored."
    fi

fi
