#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

sudo mkdir -p /usr/local/goadmio/template/default

TimeStamp=$(date +'%s')

# -N (Remove Header From result)
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/go.db "select REPLACE(REPLACE(Code, '\r', ''), '\n', '') from go.Template where Name='Default Website Page'" | sudo tee /usr/local/goadmio/template/default/index.html >/dev/null

echo "Templates updated successfully."
