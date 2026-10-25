#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

H=$(date +%w-%H)

if [ "$H" = "0-00" ]; then
    sudo rm -rf /var/log/load.log
fi

Memory=$(free -h | grep Mem | awk '{ print $2 }' | sed 's/i//')
MemoryUsed=$(free -h | grep Mem | awk '{ print $3 }' | sed 's/i//')
MemoryPercent=$(free | awk '/Mem/{printf("%d"), int($3/$2*100)}')
echo "$MemoryPercent" | sudo tee -a /var/log/memory.log >/dev/null

Memory=$(sudo awk '{sum+=$1; count++} END {print int(sum/count)'} /var/log/memory.log)

echo "$Memory"

if [[ "$Memory" -gt "70" ]]; then

    sudo /go/sendmail "High Memory Usage Averages ($Memory %)" "High Memory Usage Averages ($Memory %)" "Memory Usage"
    sudo /go/sendwhatsapp "*High Memory Usage Averages ($Memory %)*" "Memory Usage"

fi
