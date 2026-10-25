#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
HostnameDots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)

if [ "$HostnameDots" -lt "2" ]; then

    echo "Invalid Server Hostname, A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."
    exit 1

fi

if sudo test ! -f "/etc/network/interfaces.bak" ; then
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
fi

if sudo test ! -f "/etc/apt/sources.list.d/pve-install-repo.list" ; then

    # hostnamectl set-hostname nvme2.blackhost.com
    hostnamectl set-hostname $Hostname

    sudo apt -y install curl
    sudo apt -y install screen

    sudo curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg http://download.proxmox.com/debian/proxmox-release-bookworm.gpg
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-install-repo.list >/dev/null

    sudo apt -y update
    sudo apt -y full-upgrade

    sudo apt -y install net-tools
    sudo apt -y install proxmox-ve

    sudo systemctl disable dhcpcd
    sudo apt -y install isc-dhcp-server

    echo "INTERFACESv4=\"vmbr0\"" | sudo tee /etc/default/isc-dhcp-server >/dev/null
    echo "INTERFACESv6=\"\"" | sudo tee -a /etc/default/isc-dhcp-server >/dev/null
    echo "authoritative;" | sudo tee -a /etc/default/isc-dhcp-server >/dev/null

    # /etc/dhcp/dhcpd.conf
    sudo systemctl enable isc-dhcp-server
    sudo systemctl restart isc-dhcp-server

    sudo mkdir -p /root/.config/rclone
    sudo curl https://rclone.org/install.sh | bash
    # /root/.config/rclone/rclone.conf

    # mkfs.ext4 /dev/sdb
    # mount /dev/sdb /var/lib/vz
fi

## IF you can not install proxmox edit file /etc/apt/sources.list
# deb http://mirror.hetzner.com/debian/packages bullseye main contrib non-free
# deb http://mirror.hetzner.com/debian/packages bullseye-updates main contrib non-free
# deb http://deb.debian.org/debian bullseye main contrib non-free
# deb http://deb.debian.org/debian bullseye-updates main contrib non-free
# deb http://security.debian.org/debian-security bullseye-security main contrib non-free

# Fix Fedora Network
# systemctl enable systemd-networkd-wait-online.service
# systemctl enable systemd-networkd.service
# systemctl enable systemd-networkd.socket
# systemctl restart systemd-networkd
