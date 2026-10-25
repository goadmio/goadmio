#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# https://ostechnix.com/install-and-configure-kvm-in-centos-8-server/

# Check if CPU Supports Virtualization Technology
VT=$(</proc/cpuinfo)

if [[ "$VT" = *"vmx"* ]]; then

    echo "Server Supports Intel Virtualization Technology."

elif [[ "$VT" = *"svm"* ]]; then

    echo "Server Supports AMD Virtualization Technology."

else

    echo "Sorry,  Your Server doesn't Support Virtualization."

fi

sudo dnf -y install qemu-kvm libvirt virt-install
sudo dnf -y install qemu-img virt-manager virt-viewer libvirt-client

sudo systemctl enable libvirtd
sudo systemctl restart libvirtd
