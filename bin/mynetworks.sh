#!/bin/bash

# MyNetworks

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ServerIP=$(curl -s -4 checkip.amazonaws.com)

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set MyNetworks='$@'"

sudo /usr/sbin/postconf -e "mynetworks = 127.0.0.0/8 [::1]/128 $ServerIP $@"

sudo /go/mail restart
