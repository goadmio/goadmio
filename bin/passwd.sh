#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Domain=$1

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if sudo test -d "/home/$Domain/etc" ; then

    Passwd=$(sudo grep "^$Username:" /etc/passwd)
    echo "$Passwd" | sudo tee /home/$Domain/etc/passwd >/dev/null

    Group=$(sudo grep "^$Username:" /etc/group)
    echo "$Group" | sudo tee /home/$Domain/etc/group >/dev/null

fi
