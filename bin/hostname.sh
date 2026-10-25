#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

Hostname=$1

IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

if [ $# -eq 0 ]; then
    Hostname=$(</etc/hostname)
    read -p "Hostname: " -e -i "$Hostname" Hostname
fi

if [ "$Hostname" = "restore" ]; then
    Hostname=$(</etc/hostname.bak)
fi

HostnameDots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)

if [ "$HostnameDots" -lt "2" ]; then

    echo "Invalid Server Hostname, A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."

    exit 1

fi

IP=$(dig $Hostname +short | tail -n1)

if [ "$IP" != "$IPv4" ]; then
    echo "Failed to change server hostname. Hostname $Hostname Not Resolving To $IPv4"
    exit 1
fi

echo "$Hostname" | sudo tee /etc/hostname >/dev/null
hostname $Hostname

if [[ "$Hostname" = "smtp."* ]]; then

    IMAPHostname="${Hostname/smtp./imap.}"

    if [ $(dig $IMAPHostname +short | tail -n1) = "$IPv4" ]; then
        echo "$IMAPHostname" | sudo tee /etc/imap >/dev/null
    else
        echo "$Hostname" | sudo tee /etc/imap >/dev/null
    fi

else

    sudo rm -rf /etc/imap

fi

IFS='.' read -r -a Array <<<"$Hostname"

echo "# GoAdmio Setup" | sudo tee /etc/hosts >/dev/null
echo "127.0.0.1 localhost.localdomain localhost" | sudo tee -a /etc/hosts >/dev/null
echo "$IPv4 $Hostname ${Array[0]}" | sudo tee -a /etc/hosts >/dev/null

if sudo test -f "/usr/local/goadmio/include/config/config.php" ; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set Hostname='$Hostname' where ConfigID=1"

fi

echo "Hostname changed to $Hostname"

HostnameDomain=$(echo "$Hostname" | cut -d. -f2-)
MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}')
SMTPPass=$(echo -n "$MAC|$(date +%s)" | md5sum | awk '{print $1}')

# SMTP
echo "<?php" | sudo tee /usr/local/goadmio/include/config/smtp.php >/dev/null
echo "\$SMTPHost=\"$Hostname\";" | sudo tee -a /usr/local/goadmio/include/config/smtp.php >/dev/null
echo "\$SMTPUser=\"goadmio@$HostnameDomain\";" | sudo tee -a /usr/local/goadmio/include/config/smtp.php >/dev/null
echo "\$SMTPPass=\"$SMTPPass\";" | sudo tee -a /usr/local/goadmio/include/config/smtp.php >/dev/null
echo "\$SMTPPort=587;" | sudo tee -a /usr/local/goadmio/include/config/smtp.php >/dev/null
echo "?>" | sudo tee -a /usr/local/goadmio/include/config/smtp.php >/dev/null

if sudo test ! -d "/etc/letsencrypt/live/$Hostname" ; then

    # Installing SSL Certificate for Hostname
    sudo /go/mailssl
    sudo /go/postconf
    sudo /go/doveconf

fi

sudo /go/welcome
