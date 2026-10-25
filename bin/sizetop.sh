#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

echo -e "SIZE         HOST                      REQUEST"
echo -e "------------ ------------------------- ------------------------------------"
sudo awk -F'|' '($11 ~ /GET \/ HTTP/ || $11 ~ /\.php/) {print $10 "|" $2 "|" $11}' $LOG | sort -rn -t'|' -k1 | uniq | head -20 | awk -F'|' '{
    bytes = $1
    if (bytes >= 1048576) {
        printf "%-12s %-25s %s\n", sprintf("%.2f MB", bytes/1048576), $2, $3
    } else if (bytes >= 1024) {
        printf "%-12s %-25s %s\n", sprintf("%.2f KB", bytes/1024), $2, $3
    } else {
        printf "%-12s %-25s %s\n", sprintf("%d B", bytes), $2, $3
    }
}'
