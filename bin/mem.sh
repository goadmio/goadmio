#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "MEMORY:"
printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
sudo ps aux --sort=-%mem | head -n 10

echo ""

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "VSIZE (VSZ):"
printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
sudo ps aux --sort=-vsize | head -n 10

MEMUser=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $1}')
MEMMemory=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print int($4)}')
MEMCommand=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $11}')

VSZUser=$(ps aux --sort=-vsize | head -n 2 | tail -n 1 | awk '{print $1}')
VSZMemory=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print int($4)}')
VSZCommand=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $11}')

if [[ "$MEMMemory" -gt "75" ]] || [[ "$VSZMemory" -gt "75" ]]; then

    sudo /go/sendmail "High Memory Usage ($MEMMemory %)" "User: $MEMUser\nCommand (MEM): $MEMCommand\nCommand (VSZ): $VSZCommand" "Memory Usage"
    sudo /go/sendwhatsapp "*High Memory Usage ($MEMMemory %)*\n\nUser: $MEMUser\nCommand (MEM): $MEMCommand\nCommand (VSZ): $VSZCommand" "Memory Usage"

fi
