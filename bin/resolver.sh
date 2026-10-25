#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! command -v nmcli &>/dev/null; then
        sudo dnf -y install NetworkManager
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if ! command -v nmcli &>/dev/null; then
        sudo apt -y install network-manager
    fi

fi

if [[ $# -eq 0 ]] || [ "$1" = "Google" ] || [ "$1" = "google" ]; then

    PrimaryIP="8.8.8.8"
    SecondaryIP="8.8.4.4"
    TertiaryIP="2001:4860:4860::8888"

elif [ "$1" = "OpenDNS" ] || [ "$1" = "opendns" ]; then

    PrimaryIP="208.67.222.222"
    SecondaryIP="208.67.220.220"
    TertiaryIP="2620:119:35::35"

elif [ "$1" = "Quad9" ] || [ "$1" = "quad9" ]; then

    PrimaryIP="9.9.9.9"
    SecondaryIP="149.112.112.112"
    TertiaryIP="2620:fe::fe"

elif [ "$1" = "Cloudflare" ] || [ "$1" = "cloudflare" ]; then

    PrimaryIP="1.1.1.1"
    SecondaryIP="1.0.0.1"
    TertiaryIP="2606:4700:4700::1111"

else

    PrimaryIP=$1
    SecondaryIP=$2
    TertiaryIP=$3

fi

# if only one ip passed then get info about this ip
if [ "$SecondaryIP" = "" ]; then

    Whois=$(whois $1)
    Country=$(echo "$Whois" | awk 'tolower($1) == "country:" { print $2;exit }')
    Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}')

    if [ "$Organization" = "" ]; then
        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}')
    fi

    Organization=$(echo $Organization | sed -e 's/^[ \t]*//')

    echo "$Country|$Organization"

    exit 1

fi

Hostname=$(</etc/hostname)

if [ "$PrimaryIP" != "" ]; then
    echo "nameserver $PrimaryIP" | sudo tee /etc/resolv.conf >/dev/null
fi

if [ "$SecondaryIP" != "" ]; then
    echo "nameserver $SecondaryIP" | sudo tee -a /etc/resolv.conf >/dev/null
fi

if [ "$TertiaryIP" != "" ]; then
    echo "nameserver $TertiaryIP" | sudo tee -a /etc/resolv.conf >/dev/null
fi

Name=$(nmcli -t -f NAME connection show --active | head -1)

if [[ "$PrimaryIP" = *"."* ]] && [[ "$SecondaryIP" = *"."* ]] && [[ "$TertiaryIP" = *"."* ]]; then

    nmcli connection modify "$Name" ipv4.dns "$PrimaryIP $SecondaryIP $TertiaryIP"
    nmcli connection modify "$Name" ipv4.ignore-auto-dns yes

elif [[ "$PrimaryIP" = *"."* ]] && [[ "$SecondaryIP" = *"."* ]]; then

    nmcli connection modify "$Name" ipv4.dns "$PrimaryIP $SecondaryIP"
    nmcli connection modify "$Name" ipv4.ignore-auto-dns yes

    if [[ "$TertiaryIP" = *":"* ]] && [[ "$IPv6" = *":"* ]]; then
        nmcli connection modify "$Name" ipv6.dns "$TertiaryIP"
        nmcli connection modify "$Name" ipv6.ignore-auto-dns yes
    fi

elif [[ "$PrimaryIP" = *":"* ]] && [[ "$SecondaryIP" = *":"* ]] && [[ "$TertiaryIP" = *":"* ]] && [[ "$IPv6" = *":"* ]]; then

    nmcli connection modify "$Name" ipv6.dns "$PrimaryIP $SecondaryIP $TertiaryIP"
    nmcli connection modify "$Name" ipv6.ignore-auto-dns yes

elif [[ "$PrimaryIP" = *":"* ]] && [[ "$SecondaryIP" = *":"* ]] && [[ "$IPv6" = *":"* ]]; then

    nmcli connection modify "$Name" ipv6.dns "$PrimaryIP $SecondaryIP"
    nmcli connection modify "$Name" ipv6.ignore-auto-dns yes

fi

nmcli connection up "$Name" >/dev/null 2>&1

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    nmcli connection reload
    sudo systemctl restart NetworkManager

elif [ "$OS" = "Debian" ]; then

    nmcli connection reload

    if systemctl status NetworkManager &>/dev/null; then
        sudo systemctl restart NetworkManager
    fi

    if systemctl status networking &>/dev/null; then
        sudo systemctl restart networking
    fi

    if systemctl status resolvconf &>/dev/null; then
        sudo systemctl restart resolvconf
    fi

elif [ "$OS" = "Ubuntu" ]; then

    nmcli connection reload

    if systemctl status network-manager &>/dev/null; then
        sudo systemctl restart network-manager
    fi

fi

if grep -q "$PrimaryIP" /etc/resolv.conf; then

    echo "Your resolvers have been successfully configured."

else

    echo "Your resolvers failed to configure."

fi
