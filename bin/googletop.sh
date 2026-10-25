#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Max=$2

Max=$((Max))

if [ "$Max" -eq "0" ]; then
    Max=2
fi

TimeStamp=$(date +'%s')
Hostname=$(</etc/hostname)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [ "$WS" = "Apache" ]; then

        LOG="/var/log/httpd/access*"

    else

        LOG="/var/log/nginx/access.*"
        FileStamp=$(stat -c %Y "/var/log/nginx/access.log" 2>/dev/null)

    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$WS" = "Apache" ]; then

        if sudo test -f /var/log/apache2/access.log ; then
            LOG="/var/log/apache2/access*"
        elif sudo test -f /var/log/apache2/other_vhosts_access.log ; then
            LOG="/var/log/apache2/other_vhosts_access*"
        else
            echo "File /var/log/apache2/access.log not found."
            exit 1
        fi

    else

        if sudo test -f /var/log/nginx/access.log ; then
            LOG="/var/log/nginx/access*"
        elif sudo test -f /var/log/nginx/other_vhosts_access.log ; then
            LOG="/var/log/nginx/other_vhosts_access*"
        else
            echo "File /var/log/nginx/access.log not found."
            exit 1
        fi

    fi

fi

if [ "$1" = "block" ]; then
    sudo rm -rf /usr/local/goadmio/tmp/block.db
fi

LogSeconds=$((TimeStamp - FileStamp))

if [ "$LogSeconds" -gt "60" ]; then
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
    echo "Log Seconds: $LogSeconds"
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
fi

zgrep -h "gad_campaignid" $LOG >/usr/local/goadmio/tmp/google-ads.log
sudo awk -F'|' '{ if ($11 ~ /gad_campaignid/ && $4 != "-") print $4; else if ($11 ~ /gad_campaignid/) print $3 }' /usr/local/goadmio/tmp/google-ads.log >/usr/local/goadmio/tmp/googletop.db

Code=$(sudo cat /usr/local/goadmio/tmp/googletop.db | sort | uniq -ci | sort -nr | head -5000)

Visits=$(echo "$Code" | awk '{print $1'})
Visits=$(echo $Visits | tr "\n" " ")
IFS=' ' read -r -a VisitsArray <<<"$Visits"

IPArray=$(echo "$Code" | awk '{print $2'})

if [ $# -eq 0 ]; then

    OUTPUT="IP|VISITS|COUNTRY|CITY|COMPANY"
    OUTPUT="$OUTPUT\n--|------|-------|----|-------"

fi

N=0
E=0
for IP in $IPArray; do

    if [ "$IP" != "$IPv4" ] && [ "$IP" != "$IPv6" ] && [ "$IP" != "127.0.0.1" ]; then

        if [ $# -eq 0 ]; then

            Visits="${VisitsArray[$N]}"

            Whois=$(WHOIS "$IP")
            Company=$(COMPANY "$Whois" "$IP")

            if [ -t 0 ]; then
                Country=$(COUNTRY "$IP")
                City=$(CITY "$IP")
            else
                Country=$(echo "$Whois" | awk 'tolower($1) == "country:" { print $2;exit }')
                City=$(echo "$Whois" | grep -i "city:" | head -n1 | awk -F: '{print $2}' | sed 's/^[ \t]*//')
            fi

        fi

        if [ "$1" = "max" ]; then

            if [ "${VisitsArray[$N]}" -ge "$Max" ]; then

                echo "$IP"
                N=$(($N + 1))

            fi

        elif [ "$1" = "block" ]; then

            if [ "${VisitsArray[$N]}" -ge "1" ]; then

                echo "$IP" | sudo tee -a /usr/local/goadmio/tmp/block.db >/dev/null

            fi

        else

            OUTPUT="$OUTPUT\n$IP|${VisitsArray[$N]}|$Country|$City|$Company"
            N=$(($N + 1))

        fi

    fi

done

if [ "$1" = "block" ]; then

    echo "52.0.0.0/11"
    echo "54.0.0.0/11"
    echo "34.0.0.0/11"
    echo "35.0.0.0/11"
    echo "20.0.0.0/11"
    echo "23.0.0.0/11"
    echo "159.203.0.0/16"
    echo "89.0.0.0/8"
    echo "146.70.0.0/16"

    sudo sed -i 's/\.[0-9]\+$/.*/' /usr/local/goadmio/tmp/block.db
    sudo sed -i -E 's/(:[0-9a-fA-F]*){2}$/::\/64/' /usr/local/goadmio/tmp/block.db
    sort /usr/local/goadmio/tmp/block.db | uniq -d

    sudo /go/googletop max 2

    exit 1

fi

if [ $# -eq 0 ]; then
    echo -ne $OUTPUT | column -t -s "|"
fi

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "IPs: $N"
printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

if [ "$E" -gt "0" ]; then

    sudo /go/sendmail "Google Ads ($E IPs)" "$Err" "Block"
    sudo /go/sendwhatsapp "*Google Ads ($E IPs)*\n\n$Err" "Block"

fi
