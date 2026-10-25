#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

echo "IPs Info..."
DDos=$(sudo wget https://go.blackhost.com/file.php?Action=Blacklist -q -O - | tr -d '\r')
while read IP; do

    # TRIM
    IP=$(echo $IP | xargs echo -n)

    Whois=$(WHOIS "$IP")
    Company=$(COMPANY "$Whois" "$IP")

    echo "$IP|$Country|$Company"

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/blacklist.db "UPDATE Blacklist SET Country='$Country',Descr='$Descr',Organization='$Organization' WHERE IP='$IP'"

    if [ "$Country" = "EG" ]; then
        sudo /go/unblock $IP
    fi

    if echo "$Company" | grep -iqE "Contabo|HETZNER"; then
        sudo /go/unblock $IP
    fi

done <<<"$DDos"
