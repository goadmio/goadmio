#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Name=$1

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Name" = "all" ]; then
    if [ -z "$STY" ]; then exec screen -dm -S RepairAll /bin/bash "$0"; fi
fi

if [ "$Name" = "all" ]; then
    mysqlcheck -uroot -p$MySQLRootPassword --repair --all-databases
else
    mysqlcheck -uroot -p$MySQLRootPassword -r $Name
fi
