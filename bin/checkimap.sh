#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

IMAPHostname=$(</etc/imap)

Dots=$(sudo grep -o "\." <<<"$IMAPHostname" | wc -l)
if [ "$Dots" -lt "2" ]; then

    echo "Invalid IMAP Hostname ($IMAPHostname), IMAP hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."

    sudo /go/sendmail "IMAP Server is not working (Server IP: $ServerIP)" "Invalid Hostname ($Hostname), A hostname should consist of a name and a domain name. All valid IMAP hostnames should have 2 dots in them." "Invalid IMAP"
    sudo /go/sendwhatsapp "*IMAP Server is not working (Server IP: $ServerIP)*\n\nInvalid IMAP Hostname ($IMAPHostname), IMAP hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them." "Invalid IMAP"

    exit 1

fi

IP=$(dig $IMAPHostname +short | tail -n1)
if [ "$IP" != "$ServerIP" ]; then

    echo "Please Point $IMAPHostname to A Record: $ServerIP"
    sudo /go/sendmail "IMAP Server is not working ($IMAPHostname)" "Please Point $IMAPHostname to A Record: $ServerIP" "Invalid IMAP"
    sudo /go/sendwhatsapp "*IMAP Server is not working ($IMAPHostname)*\n\nPlease Point $IMAPHostname to A Record: $ServerIP" "Invalid IMAP"

    exit 1

fi

# PORT 993
sudo openssl s_client -connect localhost:993 <<<"Q" | sudo tee /usr/local/goadmio/tmp/993.db 2>&1 >/dev/null

if ! grep -q "$IMAPHostname" /usr/local/goadmio/tmp/993.db; then

    sudo /go/mailssl

    if sudo test -d "/etc/letsencrypt/live/$IMAPHostname" ; then

        sudo /go/installmail

        if ! grep -q "mynetworks" /etc/postfix/main.cf; then

            sudo /go/postconf
            sudo /go/mail restart

        fi
    fi

fi
