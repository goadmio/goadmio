#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Suspend='1' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Suspend='1' where Domain='$Domain'"

# Create VHOST CONF
sudo /go/apache $Domain
sudo /go/nginx $Domain
sudo /go/reload "| Executed by $(basename "$0")"

echo "Account $Domain has been suspended"

sudo /go/reload "| Executed by $(basename "$0")"
