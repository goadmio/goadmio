#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1

echo "1) Add"
echo "2) Delete"

read -p "Action: " -e Action

read -p "IP: " -e -i "$IP" IP

N=0

File="/root/domain.txt"
while IFS= read Domain; do

    # TRIM String
    Domain=$(echo $Domain | sed -e 's/^[ \t]*//')
    Domain="${Domain//$'\r'/}"

    N=$(($N + 1))

    if [ "$Action" = "1" ] || [ "$Action" = "add" ]; then

        echo "$N| Adding $IP >> $Domain..."
        sudo curl "https://test.httpapi.com/api/dns/manage/add-ipv4-record.json?auth-userid=61678&api-key=Gkn0gtHe4sYoF8xgl5Rbwlq0QEeEzLiL&domain-name=$Domain&value=$IP"
        echo " "

        echo "$N| Adding www CNAME >> $Domain..."
        sudo curl "https://test.httpapi.com/api/dns/manage/add-cname-record.json?auth-userid=61678&api-key=Gkn0gtHe4sYoF8xgl5Rbwlq0QEeEzLiL&domain-name=$Domain&value=$Domain&host=www"
        echo " "

    fi

    if [ "$Action" = "2" ] || [ "$Action" = "delete" ]; then

        echo "$N| Deleting $IP >> $Domain..."
        sudo curl "https://test.httpapi.com/api/dns/manage/delete-ipv4-record.json?auth-userid=61678&api-key=Gkn0gtHe4sYoF8xgl5Rbwlq0QEeEzLiL&domain-name=$Domain&&value=$IP"
        echo " "

    fi

done <"$File"
