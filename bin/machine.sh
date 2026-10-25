#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Machine=$(sudo hostnamectl status | grep "Virtualization")

if [[ "$Machine" = *"kvm"* ]]; then

    echo "KVM" | sudo tee /usr/local/goadmio/linux/machine.db >/dev/null

elif [[ "$Machine" = *"openvz"* ]]; then

    echo "OpenVZ" | sudo tee /usr/local/goadmio/linux/machine.db >/dev/null

elif [[ "$Machine" = *"xen"* ]]; then

    echo "Xen" | sudo tee /usr/local/goadmio/linux/machine.db >/dev/null

elif [[ "$Machine" = *"lxc"* ]]; then

    echo "LXC" | sudo tee /usr/local/goadmio/linux/machine.db >/dev/null

else

    echo "" | sudo tee /usr/local/goadmio/linux/machine.db >/dev/null

fi
