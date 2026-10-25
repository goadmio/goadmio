#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

Action=$1

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

clear

for N in {1..1000}; do

    Time=$(date +'%Y-%m-%d %H:%M:%S')

    if [[ $@ != "" ]]; then

        Code=$(sudo cat $LOG | grep "$1" | awk -F'|' '{print $2 " " $11'} | tail -100)

    else

        Code=$(sudo cat $LOG | awk -F'|' '{print $2 " " $11'} | tail -200)

    fi

    Code=$(echo "$Code" | sort | uniq -ci | sort -nr | head -20)

    clear

    echo "┌─────────────────────┐"
    echo "│ $Time │"
    echo "└─────────────────────┘"
    echo ""

    echo "$Code" | sed 's/ HTTP\/2\.0//' | cut -c1-125

    sleep 2

done
