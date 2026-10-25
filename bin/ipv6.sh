#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo rm -rf /usr/local/goadmio/cache/*

if [[ "$1" = *":"* ]]; then

    # SETUP IPv6
    Name=$(nmcli -t -f NAME connection show --active | head -1)

    sudo nmcli connection modify "$Name" ipv6.method manual
    sudo nmcli connection modify "$Name" ipv6.addresses "$1/64"
    sudo nmcli connection modify "$Name" ipv6.gateway "fe80::1"
    sudo nmcli connection modify "$Name" ipv6.dns "2a01:4ff:ff00::add:1"
    sudo nmcli connection modify "$Name" +ipv6.routes "fe80::1/128 :: 100 onlink=true"
    sudo nmcli connection up "$Name"

    exit 1

fi

if [ "$1" = "0" ] || [ "$1" = "disable" ] || [ "$1" = "--disable" ]; then

    E=0

    # Disable IPv6
    echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf >/dev/null
    echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf >/dev/null
    echo "net.ipv6.conf.lo.disable_ipv6=1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf >/dev/null

    # Apply immediately
    sudo sysctl -p /etc/sysctl.d/99-disable-ipv6.conf

else

    E=1

    # Enable IPv6
    sudo rm -rf /etc/sysctl.d/99-disable-ipv6.conf

    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0 >/dev/null 2>&1

fi

IPv6=$(curl -s -6 https://icanhazip.com)

if [[ "$IPv6" = *":"* ]]; then
    echo "IPv6: $IPv6"
else

    if [ "$E" -eq "1" ]; then
        echo "Please wait up to 3 minutes to activate IPv6..."
    fi

fi
