#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Date=$(date +'%Y-%m-%d')
Today=$(date '+%b %e')

sudo mkdir -p /var/log/go/mail/incoming
echo "Time|From|To|IP|Subject" | sudo tee /var/log/go/mail/incoming/incoming-$Date.log >/dev/null
echo "----|----|--|--|-------" | sudo tee -a /var/log/go/mail/incoming/incoming-$Date.log >/dev/null

IDs=$(sudo cat /var/log/maillog | grep "^$Today " | grep "smtpd\[" | awk '{ print $6 }' | sed 's/://' | grep '^[A-F0-9]*$')

for ID in $IDs; do

    Time=$(sudo cat /var/log/maillog | grep "smtpd\[" | grep "$ID:" | awk '{print $3}' | head -1)
    To=$(sudo cat /var/log/maillog | grep "$ID:" | grep "from=" | grep "to=" | grep -oP 'to=<\K[^>]+' | head -1)
    From=$(sudo cat /var/log/maillog | grep "$ID:" | grep "from=" | grep "to=" | grep -oP 'from=<\K[^>]+' | head -1)
    IP=$(sudo cat /var/log/maillog | grep "$ID:" | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    Subject=$(sudo cat /var/log/maillog | grep "$ID:" | grep -o 'Subject:.*;' | sed 's/Subject: //' | sed 's/ from .*//' | cut -c1-75 | head -1)

    if [[ "$From" = *"@"* ]] && [[ ! "$From" = *"goadmio"* ]] && [[ ! "$From" = *"root"* ]]; then

        echo "$Time|$From|$To|$IP|$Subject" | sudo tee -a /var/log/go/mail/incoming/incoming-$Date.log >/dev/null

    fi

done

sudo cat /var/log/go/mail/incoming/incoming-$Date.log | column -t -s "|"
