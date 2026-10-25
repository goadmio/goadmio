#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)

echo "Installing DMARC..."

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y remove opendmarc &>/dev/null
    sudo dnf -y install opendmarc

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    DEBIAN_FRONTEND='noninteractive' apt -y purge opendmarc &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y install opendmarc

fi

sudo sed -i '/AuthservID/d' /etc/opendmarc.conf
sudo sed -i '/TrustedAuthservIDs/d' /etc/opendmarc.conf

echo "AuthservID OpenDMARC" | sudo tee -a /etc/opendmarc.conf >/dev/null
echo "TrustedAuthservIDs $Hostname" | sudo tee -a /etc/opendmarc.conf >/dev/null
