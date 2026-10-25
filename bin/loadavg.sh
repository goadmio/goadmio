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

CPUThreads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $CPUThreads)}")

echo "$ServerLoad" | sudo tee -a /var/log/load.log >/dev/null

Load=$(sudo awk '{sum+=$1; count++} END {print int(sum/count)'} /var/log/load.log)

echo "$Load"

if [[ "$Load" -gt "70" ]]; then

    sudo /go/sendmail "High Load Averages ($Load %)" "High Load Averages ($Load %)" "Load Average"
    sudo /go/sendwhatsapp "*High Load Averages ($Load %)*" "Load Average"

fi
