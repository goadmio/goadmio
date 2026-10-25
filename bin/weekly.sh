#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# Today is the first Sunday of the month
if [ "$(date +%w)" -eq 0 ] && [ "$(date +%d)" -le 7 ]; then
    sudo /go/monthly
fi

sudo /go/log
sudo /go/clean
sudo /go/mailssl
sudo /go/package

sudo /usr/bin/certbot renew --quiet

HardDiskInfo=$(/go/speed | grep "Hard")
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET HardDiskInfo='$HardDiskInfo'"
