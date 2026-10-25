#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

LockFile="/usr/local/goadmio/lock/block.lock"
if [ "$1" = "block" ] || [ "$1" = "robot" ] || [ "$1" = "underattack" ]; then

    if sudo test -f "$LockFile" ; then
        if [[ $(($(date +%s) - $(stat -c %Y "$LockFile" 2>/dev/null))) -le "60" ]]; then
            InstanceFile=$(<"$LockFile")
            echo "Instance ($InstanceFile) already running."
            exit 1
        fi
    fi

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

	# Run When Click Ctrl+C
	trap 'sudo rm -f "$LockFile"' EXIT

fi

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $Threads)}")

Stamp="$1"
TimeStamp=$(date +'%s')
Hostname=$(</etc/hostname)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

if [[ "$Stamp" =~ ^[0-9]+$ ]]; then
    TTL=$((TimeStamp - $Stamp))
    HT=$((Stamp / 60))
    Head=25
elif [ "$Stamp" = "block" ]; then
    TTL=$((TimeStamp - 3600))
    HT=$((3600 / 60))
    Head=50
elif [ "$Stamp" = "robot" ]; then
    TTL=$((TimeStamp - 900))
    HT=$((900 / 60))
    Head=50
elif [ "$Stamp" = "underattack" ]; then

    if [ "$ServerLoad" -gt "100" ]; then
        TTL=$((TimeStamp - 900))
        HT=$((900 / 60))
    else
        exit 1
    fi

    Head=1

elif [ "$Stamp" = "hour" ]; then
    TTL=$((TimeStamp - 3600))
    HT=$((3600 / 60))
    Head=25
elif [ "$Stamp" = "day" ]; then
    TTL=$((TimeStamp - 86400))
    HT=$((86400 / 60))
    Head=25
elif [ "$Stamp" = "week" ]; then
    TTL=$((TimeStamp - 604800))
    HT=$((604800 / 60))
else
    TTL=$((TimeStamp - 86400))
    HT=$((86400 / 60))
    Head=25
fi

if sudo test -f "/var/go/etc/iptop" ; then

    Limit=$(</var/go/etc/iptop)

    if ! [[ "$Limit" =~ ^[0-9]+$ ]]; then
        Limit=2500
    fi

else

    Limit=2500

fi

if [ "$Stamp" = "robot" ]; then
    Limit=$((Limit / 4))
fi

if [ "$Stamp" = "underattack" ]; then
    Limit="100"
fi

sudo awk -F'|' '{ if ($6 > '"$TTL"' && $4 != "-") print $4; else if ($6 > '"$TTL"') print $3 }' "$LOG" | sudo tee "/usr/local/goadmio/tmp/iptop-$TimeStamp.db" >/dev/null

if sudo test -f /etc/white ; then

    Line="/etc/white"
    while IFS= read -r WhiteIP; do

        WhiteIP=$(echo "$WhiteIP" | sed 's/*//')

        if [[ "$WhiteIP" = *"."* ]]; then

            sudo sed -i "/^$WhiteIP/d" "/usr/local/goadmio/tmp/iptop-$TimeStamp.db"

        fi

    done <"$Line"

fi

Code=$(sudo cat "/usr/local/goadmio/tmp/iptop-$TimeStamp.db" | sort | uniq -ci | sort -nr | head -"$Head")

Visits=$(echo "$Code" | awk '{print $1}')
Visits=$(echo $Visits | tr "\n" " ")
IFS=' ' read -r -a VisitsArray <<<"$Visits"

IPArray=$(echo "$Code" | awk '{print $2}')

OUTPUT="IP|VISITS|COUNTRY|CITY|COMPANY"
OUTPUT="$OUTPUT\n--|------|-------|----|-------"

N=0
E=0
for IP in $IPArray; do

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
    Visits="${VisitsArray[$N]}"

    if [ "$IP" != "$IPv4" ] && [ "$IP" != "$IPv6" ] && [ "$IP" != "127.0.0.1" ]; then

        Whois=$(WHOIS "$IP")
        Company=$(COMPANY "$Whois" "$IP")

        if [ -t 0 ]; then
            Country=$(COUNTRY "$IP")
            City=$(CITY "$IP")
        else
            Country=$(echo "$Whois" | awk 'tolower($1) == "country:" { print $2;exit }')
            City=$(echo "$Whois" | grep -i "city:" | head -n1 | awk -F: '{print $2}' | sed 's/^[ \t]*//')
        fi

        # Robot
        if echo "$Company" | grep -qiE "(Alibaba|Microsoft|UAB Host Baltic|Bunny Communications LLC|Censys|DigitalOcean|Arelion|IPv4 address block|Ace Data Center|ACEVILLE PTE|Packethub|Comcast Cable Communications|Amazon Data Services|SOFTGAURD POWERTRONICS|Beijing|Zhejiang|CNC Group|Arisk Communications|Intelligence Hosting|Anthropic)"; then

            if [ "$Stamp" = "block" ] || [ "$Stamp" = "robot" ] || [ "$Stamp" = "underattack" ]; then

                if [ "$Visits" -ge "1" ]; then

                    if ! compgen -G "/var/log/go/block/$IP.*" >/dev/null; then

                        CountryCode=$(geoiplookup "$IP" | head -1 | awk {' print $4 '} | sed 's/[^A-Za-z]//g')

                        if [ "$Country" = "$CountryCode" ]; then

                            E=$(($E + 1))
                            Err="${Err}- Robot $IP ($Visits Visits / $HT Minutes) - Country: $Country, Company: $Company.\n\n"

                            sudo /go/block "$IP" robot "$Country" "$Company"

                        fi

                    fi

                fi

            fi

        elif [[ "${Company,,}" != *"google"* ]] && [[ "$Company" != *"bing"* ]] && [[ "$Company" != *"cloudflare"* ]]; then

            if [ "$Stamp" = "block" ] || [ "$Stamp" = "robot" ] || [ "$Stamp" = "underattack" ]; then

                if [[ "$Visits" -ge "$Limit" ]]; then

                    if ! compgen -G "/var/log/go/block/$IP.*" >/dev/null; then

                        E=$(($E + 1))
                        Err="${Err}- High Traffic $IP ($Visits Visits / $HT Minutes) - Country: $Country, Company: $Company.\n\n"

                        sudo /go/block "$IP" ip "$Country" "$Company"

                    fi

                fi

            fi

        fi

        OUTPUT="$OUTPUT\n$IP|$Visits|$Country|$City|$Company"

    fi

    N=$(($N + 1))

done

echo -ne "$OUTPUT" | column -t -s "|"

if [ "$E" -gt "0" ]; then

    Header="Dear Server Administrator,\n\nThis is an automated security alert from GoAdmio AI.\n\nUnusual load patterns were detected on your server. The system has automatically blocked IP addresses exhibiting abnormally high traffic consistent with botnets, scraping tools, or DDoS attacks.\n\nThis measure protects your infrastructure from resource exhaustion.\n\nBlocked IP Addresses:\n"
    Footer="The GoAdmio AI System will continue to monitor traffic anomalies and bot behavior in real-time. Should you have any questions or require further details regarding these blocked IPs, please do not hesitate to reach out.\n\nThank you for ensuring the security and integrity of your server.\n\nBest regards,\nGoAdmio AI Security Team\nwww.goadmio.com\n\n"
    Note="Note: This email is automatically generated by the GoAdmio AI System. Please do not reply directly to this message."

    sudo /go/sendmail "Blocking of High Traffic and Non-Human Bot IPs ($E IPs)" "${Header}${Err}${Footer}${Note}" "Block"
    sudo /go/sendwhatsapp "*Blocking of High Traffic and Non-Human Bot IPs ($E IPs)*\n\n${Header}${Err}${Footer}${Note}" "Block"

fi

sudo rm -rf "/usr/local/goadmio/tmp/iptop-$TimeStamp.db"
sudo rm -rf "$LockFile"