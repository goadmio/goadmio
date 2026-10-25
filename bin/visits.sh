#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

Stamp=$1

TimeStamp=$(date +'%s')
Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

if [[ "$Stamp" =~ ^[0-9]+$ ]]; then
    TTL=$((TimeStamp - $Stamp))
elif [ "$Stamp" = "hour" ]; then
    TTL=$((TimeStamp - 3600))
elif [ "$Stamp" = "day" ]; then
    TTL=$((TimeStamp - 86400))
elif [ "$Stamp" = "week" ]; then
    TTL=$((TimeStamp - 604800))
else
    TTL=$((TimeStamp - 86400))
fi

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

if sudo test ! -f /var/log/load.log ; then
    sudo /go/loadavg
fi

if sudo test ! -f /var/log/memory.log ; then
    sudo /go/memoryavg
fi

ServerLoad=$(sudo awk '{sum+=$1; count++} END {print int (sum/count)}' /var/log/load.log)
MemoryPercent=$(sudo awk '{sum+=$1; count++} END {print int (sum/count)}' /var/log/memory.log)

Visits=$(sudo awk -F'|' '$6 > '"$TTL"' {print $3}' $LOG | wc -l)

UVisits=$(sudo awk -F'|' '{ if ($6 > '"$TTL"' && $4 != "-") print $4; else if ($6 > '"$TTL"') print $3 }' $LOG | sort -u | wc -l)

if [ "$MemoryPercent" -ge $ServerLoad ]; then
    VisitsMax=$(sudo awk "BEGIN {print int($Visits / $MemoryPercent * 100 )}")
else
    VisitsMax=$(sudo awk "BEGIN {print int($Visits / $ServerLoad * 100 )}")
fi

echo "$Visits / $VisitsMax"

echo "Count Unique IPs: $UVisits"
