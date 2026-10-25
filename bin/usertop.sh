#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

LockFile="/usr/local/goadmio/lock/backup.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi

Action=$1

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $Threads)}")

if [ "$Action" = "history" ]; then

    sudo cat $LOG | awk -F'|' '{print $2}' | tail -10000 | sed 's/www.//g' | sort | uniq -ci | sort -nr | head -10

else

    sudo cat $LOG | awk -F'|' '{print $2'} | tail -100 | sed 's/www.//g' | sort | uniq -ci | sort -nr | head -10

    if [ "$ServerLoad" -ge "100" ]; then

        Domain=$(sudo cat $LOG | awk -F'|' '{print $2'} | tail -250 | sed 's/www.//g' | sort | uniq -ci | sort -nr | head -1 | awk '{print $2}')
        echo "Turn On Under Attack Mode: $Domain"
        echo $(date +"[%b %d %H:%M:%S]#") "Turn On Under Attack Mode: $Domain (/go/usertop)" | sudo tee -a /var/log/go/underattack.log >/dev/null

        sudo /go/underattack $Domain
        sudo /go/iptop underattack

        sudo /go/sendmail "Under DDoS Attack (CPU: ${ServerLoad}%)" "Website $Domain Under DDoS Attack" "Under Attack"
        sudo /go/sendwhatsapp "*Under DDoS Attack (CPU: ${ServerLoad}%)*\n\nWebsite $Domain Under DDoS Attack" "Under Attack"

    elif [ "$ServerLoad" -ge "10" ]; then

        # Check Non-Human
        sudo /go/iptop robot

    fi

fi
