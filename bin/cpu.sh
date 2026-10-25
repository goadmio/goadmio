#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Cores=$(lscpu -p | grep -v "^#" | cut -d, -f2 | sort -u | wc -l)

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $Threads)}")

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "CPU: ${ServerLoad}% ($Cores Cores / $Threads Threads)"
printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

sudo ps aux --sort=-%cpu | head -n 10

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "CPU: ${ServerLoad}% ($Cores Cores / $Threads Threads)"
printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

User=$(ps aux --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $1}')
Command=$(ps aux --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $11}')

P=$(ps aux --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print int($3/100)}')
Percent=$(($P * 100 / $Threads))

# if one user or service use more than 75% of Total CPUs
if [ "$Percent" -gt "75" ]; then

    sudo /go/sendmail "Current $User CPU Usage ($Percent %)" "WARNING: $User is using more than ${Percent}% of total CPU resources\n\nCommand: $Command" "CPU Usage"
    sudo /go/sendwhatsapp "*Current $User CPU Usage ($Percent %)*\n\nWARNING: $User is using more than ${Percent}% of total CPU resources\n\nCommand: $Command" "CPU Usage"

fi
