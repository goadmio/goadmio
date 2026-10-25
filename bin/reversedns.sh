#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

Hostname=$(</etc/hostname)

ServerIP=$(curl -s -4 checkip.amazonaws.com)

ReverseDNS=$(host $ServerIP | awk '{ print $5 }' | sed 's/.$//')

if [ "$Hostname" = "$ReverseDNS" ]; then

    echo "Reverse DNS: $ReverseDNS"

else

    echo "Hostname: $Hostname"
    echo "Reverse DNS: $ReverseDNS"

    echo "Reverse DNS Mismatch."

fi
