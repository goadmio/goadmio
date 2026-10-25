#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

mkdir -p /root/.config/sqlite3
echo ".timeout 30000" | tee /root/.config/sqlite3/sqliterc > /dev/null
echo ".timeout 30000" | tee /root/.sqliterc > /dev/null
chown -R root:root /root/.config
chown -R root:root /root/.sqliterc
chmod 644 /root/.config/sqlite3/sqliterc
chmod 644 /root/.sqliterc