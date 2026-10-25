#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo systemctl disable dhcpcd
sudo apt -y install isc-dhcp-server

echo "INTERFACESv4=\"vmbr0\"" | sudo tee /etc/default/isc-dhcp-server >/dev/null
echo "INTERFACESv6=\"\"" | sudo tee -a /etc/default/isc-dhcp-server >/dev/null
echo "authoritative;" | sudo tee -a /etc/default/isc-dhcp-server >/dev/null

# /etc/dhcp/dhcpd.conf

sudo systemctl enable isc-dhcp-server
sudo systemctl restart isc-dhcp-server
journalctl -u isc-dhcp-server
