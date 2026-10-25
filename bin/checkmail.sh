#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)

if sudo test -f /etc/imap ; then
    IMAPHostname=$(</etc/imap)
else
    IMAPHostname=$(</etc/hostname)
fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)

# PORT 25
nc -w 3 -vv -z gmail-smtp-in.l.google.com 25 >/usr/local/goadmio/tmp/25.db 2>&1

# PORT 465
sudo openssl s_client -connect localhost:465 <<<"Q" | sudo tee /usr/local/goadmio/tmp/465.db 2>&1 >/dev/null

# PORT 993
sudo openssl s_client -connect localhost:993 <<<"Q" | sudo tee /usr/local/goadmio/tmp/993.db 2>&1 >/dev/null

# PORT 465
sudo openssl s_client -connect localhost:465 <<<"Q" | sudo tee /usr/local/goadmio/tmp/465.db 2>&1 >/dev/null

if command -v iptables &>/dev/null; then

    # Open All Ports
    iptables -I INPUT -j ACCEPT
    iptables -I OUTPUT -j ACCEPT

fi

if command -v firewall-cmd &>/dev/null; then

    sudo firewall-cmd --permanent --direct --remove-rule ipv4 filter OUTPUT 0 -p tcp --dport 25 -j DROP >/dev/null 2>&1
    sudo firewall-cmd --permanent --direct --remove-rule ipv6 filter OUTPUT 0 -p tcp --dport 25 -j DROP >/dev/null 2>&1
    sudo firewall-cmd --reload >/dev/null 2>&1

fi

if grep -q -E "unreachable|Connection timed out|TIMEOUT|failed" /usr/local/goadmio/tmp/25.db; then

    Whois=$(whois $ServerIP)
    Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}')

    if [ "$Organization" = "" ]; then
        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}')
    fi

    Organization=$(echo $Organization | sed -e 's/^[ \t]*//')

    echo "Your ISP $Organization blocking SMTP Port 25"

elif grep -q "Connected" /usr/local/goadmio/tmp/25.db; then

    echo "Port 25 is opened"

    if grep -q "$Hostname" /usr/local/goadmio/tmp/465.db; then
        echo "Port 465 is opened"
    else
        echo "SMTP SSL is not installed ($Hostname)"
        echo "Recommended:"
        echo "1 - Point a Hostname $Hostname to your Server IP $ServerIP"
        echo "2 - Run \"/go/installmail\""
    fi

    if grep -q "$IMAPHostname" /usr/local/goadmio/tmp/993.db; then
        echo "Port 993 is opened"
    else
        echo "IMAP SSL is not installed ($IMAPHostname)"
    fi

fi
