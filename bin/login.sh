#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

SSHUsername=$(sudo grep -oP 'SSHUsername="\K[^"]+' /usr/local/goadmio/include/config/config.php)
SSHPassword=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSHPassword from Config where ConfigID=1")

echo "Username: $SSHUsername"
echo "Password: $SSHPassword"
