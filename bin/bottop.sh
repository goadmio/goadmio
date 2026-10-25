#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

LockFile="/usr/local/goadmio/lock/block.lock"
if [ "$1" = "block" ]; then

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

Action="$1"

if [ "$1" = "block" ]; then
    Head=50
else
    Head=25
fi

TimeStamp=$(date +'%s')
TTL=$((TimeStamp - 3600))

Hostname=$(</etc/hostname)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

sudo mkdir -p /var/log/go/bottop

# Bad Bots
Bots=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "select Name from Bot WHERE Block=1;" | tr '\n' '|' | sed -e 's/^|//' -e 's/|$//')
Bots=$(echo "$Bots" | tr '[:upper:]' '[:lower:]')

if [[ "$@" = *"--more"* ]]; then

    sudo awk -F'|' -v Bots="$Bots" -v TTL="$TTL" 'tolower($13) ~ Bots && $6 > TTL {print (($4 != "-") ? $4 : $3) "|" $13}' "$LOG" | sudo tee /usr/local/goadmio/tmp/bottop.db >/dev/null
    sudo sed -i 's/"/-/g' /usr/local/goadmio/tmp/bottop.db

else

    sudo awk -F'|' -v Bots="$Bots" -v TTL="$TTL" 'tolower($13) ~ Bots && $6 > TTL {print ($4 != "-") ? $4 : $3}' "$LOG" | sudo tee /usr/local/goadmio/tmp/bottop.db >/dev/null

fi

if sudo test -f /etc/white ; then

    Line="/etc/white"
    while IFS= read -r WhiteIP; do

        WhiteIP=$(echo "$WhiteIP" | sed 's/*//')

        if [[ "$WhiteIP" = *"."* ]]; then

            sudo sed -i "/^$WhiteIP/d" /usr/local/goadmio/tmp/bottop.db

        fi

    done <"$Line"

fi

Code=$(sudo cat /usr/local/goadmio/tmp/bottop.db | sort | uniq -ci | sort -nr | head -"$Head")

Visits=$(echo "$Code" | awk '{print $1}')
Visits=$(echo $Visits | tr "\n" " ")
IFS=' ' read -r -a VisitsArray <<<"$Visits"

IPArray=$(echo "$Code" | awk '{print $2}')

OUTPUT="IP|VISITS|Bot Name|COUNTRY|CITY|COMPANY"
OUTPUT="$OUTPUT\n--|------|--------|-------|----|-------"

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

        BotName=$(sudo grep "|$IP|" "$LOG" | head -1 | grep -ioE "$Bots" | head -1)

        if [[ "${Company,,}" != *"google"* ]] && [[ "$Company" != *"bing"* ]] && [[ "$Company" != *"cloudflare"* ]]; then

            if [ "$Visits" -ge "1" ] && [ "$Action" = "block" ]; then

                if ! compgen -G "/var/log/go/block/$IP.*" >/dev/null; then

                    E=$(($E + 1))
                    Err="${Err}- $IP $BotName ($Visits Visits) - Country: $Country, Company: $Company\n\n"

                    if [ "$BotName" != "" ]; then
                        echo "$(date +"%Y-%m-%d %H:%M:%S") $IP $BotName ($Visits Visits) - Country: $Country, Company: $Company" | sudo tee -a "/var/log/go/bottop/$BotName.log" >/dev/null
                    fi

                    sudo /go/block "$IP" bot "$Country" "$Company" "$BotName"

                fi

            fi

        fi

        OUTPUT="$OUTPUT\n$IP|$Visits|$BotName|$Country|$City|$Company"

    fi

    N=$(($N + 1))

done

echo -ne "$OUTPUT" | column -t -s "|"

if [ "$E" -gt "0" ]; then

    Header="Dear Server Administrator,\n\nThis is an automated security notification from the GoAdmio AI System.\n\nOur AI-powered monitoring tool has detected and blocked malicious bot activity targeting your server. The system automatically identified and prevented these requests based on abnormal behavior patterns, threat signatures, and IP reputation analysis.\n\nBelow is the list of IP addresses that have been blocked as part of this security action:\n\nBlocked IP Addresses:\n"
    Footer="The GoAdmio AI System will continue to monitor and protect your server in real-time. Should you have any questions or require further details regarding these blocked IPs, please do not hesitate to reach out.\n\nThank you for ensuring the security and integrity of your server.\n\nBest regards,\nGoAdmio AI Security Team\nwww.goadmio.com\n\n"
    Note="Note: This email is automatically generated by the GoAdmio AI System. Please do not reply directly to this message.\n\n"

    sudo /go/sendmail "Bad Bot Activity Blocked ($E IPs)" "${Header}${Err}${Footer}${Note}" "Block"
    sudo /go/sendwhatsapp "*Bad Bot Activity Blocked ($E IPs)*\n\n${Header}${Err}${Footer}${Note}" "Block"

fi

sudo rm -rf "$LockFile"