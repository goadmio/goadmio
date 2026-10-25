#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    CRON="/var/spool/cron"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    CRON="/var/spool/cron/crontabs"

else

    CRON="/var/spool/cron"

fi

cd $CRON

for File in *; do

    if [ "$File" != "root" ] && [ "$File" != "go" ]; then

        echo "Deleting Malware $File..."
        sudo rm -rf $CRON/$File

        sudo rm -rf /tmp/*

    fi

done
