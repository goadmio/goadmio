#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

LockFile="/usr/local/goadmio/lock/block.lock"
if [ "$1" = "block" ]; then

    if sudo test -f $LockFile ; then
        if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "60" ]]; then
            InstanceFile=$(<$LockFile)
            echo "Instance ($InstanceFile) already running."
            exit 1
        fi
    fi

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

	# Run When Click Ctrl+C
	trap 'sudo rm -f "$LockFile"' EXIT

fi

Action=$1

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

TimeStamp=$(date +'%s')
Hostname=$(</etc/hostname)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

if sudo test -f "/var/go/etc/ddos" ; then

    Limit=$(</var/go/etc/ddos)

    if ! [[ "$Limit" =~ ^[0-9]+$ ]]; then
        Limit="20000"
    fi

else

    Limit="20000"

fi

if [[ "$Action" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

    # One IP
    echo "$Action" | sudo tee /usr/local/goadmio/tmp/ddos.db >/dev/null

else

    # All IPs
    sudo awk -F'|' '{ if ($4 != "-") print $4; else print $3 }' $LOG >/usr/local/goadmio/tmp/ddos.db

fi

sudo sed -i "/^$IPv4/d" /usr/local/goadmio/tmp/ddos.db
sudo sed -i "/^$IPv6/d" /usr/local/goadmio/tmp/ddos.db

if sudo test -f /var/go/etc/white ; then

    Line="/var/go/etc/white"
    while IFS= read WhiteIP; do

        WhiteIP=$(echo "$WhiteIP" | sed 's/*//')

        if [[ "$WhiteIP" = *"."* ]]; then

            sudo sed -i "/^$WhiteIP/d" /usr/local/goadmio/tmp/ddos.db

        fi

    done <"$Line"

fi

Code=$(sudo cat /usr/local/goadmio/tmp/ddos.db | sort | uniq -ci | sort -nr | head -25)

Visits=$(echo "$Code" | awk '{print $1'})
Visits=$(echo $Visits | tr "\n" " ")
IFS=' ' read -r -a VisitsArray <<<"$Visits"

IPArray=$(echo "$Code" | awk '{print $2'})

OUTPUT="IP|VISITS|COUNTRY|CITY|COMPANY"
OUTPUT="$OUTPUT\n--|------|-------|----|-------"

N=0
E=0
for IP in $IPArray; do

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

    if [ "$IP" != "$IPv4" ] && [ "$IP" != "$IPv6" ] && [ "$IP" != "127.0.0.1" ]; then

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

        if [[ "${Company,,}" != *"google"* ]] && [[ "$Company" != *"bing"* ]] && [[ "$Company" != *"cloudflare"* ]]; then

            if [ "$Action" = "block" ]; then

                if [[ "$Visits" -ge "$Limit" ]]; then

                    if ! compgen -G "/var/log/go/block/$IP.*" >/dev/null; then

                        E=$(($E + 1))
                        Err="${Err}- High Traffic $IP ($Visits Visits) - Country: $Country, Company: $Company.\n\n"

                        sudo /go/block $IP ddos "$Country" "$Company"

                    fi

                fi

            fi

        fi

        OUTPUT="$OUTPUT\n$IP|${VisitsArray[$N]}|$Country|$City|$Company"

        N=$(($N + 1))

    fi

done

echo -ne $OUTPUT | column -t -s "|"

if [ "$E" -gt "0" ]; then

    Header="Dear Server Administrator,\n\nThis is an automated security notification from the GoAdmio AI System.\n\nOur advanced AI-powered DDoS protection tool has detected and successfully mitigated a distributed denial-of-service (DDoS) attack targeting your server. The system automatically identified and blocked malicious traffic based on abnormal request patterns, volumetric attack signatures, and coordinated IP threat analysis.\n\nBelow are the IP addresses that have been proactively blocked to protect your server's availability and performance:\n\nBlocked DDoS Attack Sources:\n"
    Footer="The GoAdmio AI DDoS Protection System will continue to monitor network traffic and apply real-time mitigation measures to ensure your server remains accessible and secure. These automated protections are designed to distinguish between legitimate user traffic and coordinated attack patterns.\n\nIf you need to review these blocks, adjust protection settings, or require further details about the attack patterns detected, please visit your security dashboard or contact our support team.\n\nThank you for prioritizing the stability and security of your infrastructure.\n\nBest regards,\nGoAdmio AI Security Team\nwww.goadmio.com\n"
    Note="Note: This email is automatically generated by the GoAdmio AI System. Please do not reply directly to this message.\n\n"

    sudo /go/sendmail "DDoS Attack Mitigated on Your Server ($E IPs)" "${Header}${Err}${Footer}${Note}" "Block"
    sudo /go/sendwhatsapp "*DDoS Attack Mitigated on Your Server ($E IPs)*\n\n${Header}${Err}${Footer}${Note}" "Block"

fi

Requests=$(zgrep -h "" ${LOG}* | awk '{print $1}' | wc -l)
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Requests='$Requests' where ConfigID=1"

sudo rm -f $LockFile
