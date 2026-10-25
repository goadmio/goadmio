#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Date=$(date +'%Y-%m-%d')
Today=$(date '+%b %e')

sudo mkdir -p /var/log/go/mail/outgoing
echo "Time|From|To|IP|Subject" | sudo tee /var/log/go/mail/outgoing/outgoing-$Date.log >/dev/null
echo "----|----|--|--|-------" | sudo tee -a /var/log/go/mail/outgoing/outgoing-$Date.log >/dev/null

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config" | sed 's/,/|/g')
if [[ "$AdminEmail" = *"@"* ]]; then
    IDs=$(sudo cat /var/log/maillog | sed -E "/$AdminEmail/d" | grep "^$Today " | grep "smtp\[" | grep "to=" | awk '{ print $6 }' | sed 's/://')
else
    IDs=$(sudo cat /var/log/maillog | grep "^$Today " | grep "smtp\[" | grep "to=" | awk '{ print $6 }' | sed 's/://')
fi

for ID in $IDs; do

    Time=$(sudo cat /var/log/maillog | grep "smtp\[" | grep "$ID:" | awk '{print $3}' | head -1)
    To=$(sudo cat /var/log/maillog | grep "$ID:" | grep -oP 'to=<\K[^>]+' | head -1)
    From=$(sudo cat /var/log/maillog | grep "$ID:" | grep -oP 'from=<\K[^>]+' | head -1)
    IP=$(sudo cat /var/log/maillog | grep "$ID:" | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    Subject=$(sudo cat /var/log/maillog | grep "$ID:" | grep -o 'Subject:.*;' | sed 's/Subject: //' | sed 's/ from .*//' | cut -c1-75 | head -1)

    if [[ "$From" = *"@"* ]] && [[ ! "$From" = *"go"* ]] && [[ ! "$From" = *"root"* ]]; then

        echo "$Time|$From|$To|$IP|$Subject" | sudo tee -a /var/log/go/mail/outgoing/outgoing-$Date.log >/dev/null

    fi

done

sudo cat /var/log/go/mail/outgoing/outgoing-$Date.log | column -t -s "|"
