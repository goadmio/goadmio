#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)
Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Firewall=0

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! systemctl is-active --quiet firewalld; then
        echo "FIREWALLD is not active."
        exit 1
    fi

    if ! firewall-cmd --list-ports | grep -q "80/tcp"; then
        Firewall=1
        echo "Port 80 is not allowed in FIREWALLD."
        Err="${Err}- Port 80 is not allowed in FIREWALLD.\n"
    fi

    if ! firewall-cmd --list-ports | grep -q "443/tcp"; then
        Firewall=1
        echo "Port 443 is not allowed in FIREWALLD."
        Err="${Err}- Port 443 is not allowed in FIREWALLD.\n"
    fi

    if ! firewall-cmd --list-ports | grep -q "21/tcp"; then
        Firewall=1
        echo "Port 21 is not allowed in FIREWALLD."
        Err="${Err}- Port 21 is not allowed in FIREWALLD.\n"
    fi

    if ! firewall-cmd --list-ports | grep -q "22/tcp"; then
        Firewall=1
        echo "Port 22 is not allowed in FIREWALLD."
        Err="${Err}- Port 22 is not allowed in FIREWALLD.\n"
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if ! ufw status | grep -q "Status: active"; then
        echo "UFW is not active."
        exit 1
    fi

    if ! ufw status | grep -q "80/tcp.*ALLOW"; then
        Firewall=1
        echo "Port 80 is not allowed in UFW."
        Err="${Err}- Port 80 is not allowed in UFW.\n"
    fi

    if ! ufw status | grep -q "443/tcp.*ALLOW"; then
        Firewall=1
        echo "Port 443 is not allowed in UFW."
        Err="${Err}- Port 443 is not allowed in UFW.\n"
    fi

    if ! ufw status | grep -q "21/tcp.*ALLOW"; then
        Firewall=1
        echo "Port 21 is not allowed in UFW."
        Err="${Err}- Port 21 is not allowed in UFW.\n"
    fi

    if ! ufw status | grep -q "22/tcp.*ALLOW"; then
        Firewall=1
        echo "Port 22 is not allowed in UFW."
        Err="${Err}- Port 22 is not allowed in UFW.\n"
    fi

fi

if [ "$Firewall" -eq "1" ]; then

    sudo /go/firewall

    sudo /go/sendmail "Firewall Checker" "$Err" "Firewall Checker"
    sudo /go/sendwhatsapp "*Firewall Checker*\n\n$Err" "Firewall Checker"

fi
