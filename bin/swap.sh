#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Memory=$(free -m | awk '/Mem/ { print int(($2 + 1023) / 1024) }')

if [[ $(free -m | grep Mem | awk '{ print $2 }') -le "1024" ]]; then
    Memory="1"
fi

if [ "$Memory" -ge "4" ] && [ "$Memory" -le "256" ]; then
    SwapMemory=$((Memory / 2))
else
    SwapMemory=2
fi

if [ "$Memory" -ge "8" ]; then
    Swappiness="10"
elif [ "$Memory" -ge "6" ]; then
    Swappiness="15"
elif [ "$Memory" -ge "4" ]; then
    Swappiness="20"
elif [ "$Memory" -ge "2" ]; then
    Swappiness="30"
else
    Swappiness="60"
fi

Swap=$(free | awk '/Swap/ {print $2}')
Swap=${Swap:-0}

if [ "$Swap" -eq "0" ]; then

    sudo fallocate -l ${SwapMemory}G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    if ! grep -q " swap " /etc/fstab; then
        echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
    fi

fi

echo "vm.swappiness=$Swappiness" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1

# cat /proc/sys/vm/swappiness
