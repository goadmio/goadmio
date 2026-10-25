#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# cd /var/lib/vz/template/iso
# http://centos.activecloud.co.il/7.9.2009/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso

nano /etc/pve/qemu-server/100.conf
pct enter 100
qm list
qm showcmd 100
qm guest passwd 100 root

enp41s0
ifreload -a
ifconfig -a

nano /etc/network/interfaces

auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
address 192.168.10.2/24
gateway 192.168.10.1
bridge-ports enp41s0
bridge-stp off
bridge-fd 0

auto eth0
iface eth0 inet static
address 136.243.89.219
netmask 255.255.255.192
gateway 136.243.89.193

dns-nameservers 8.8.8.8 8.8.4.4

H3CT4evMkRakcw

MAC: 00:50:56:00:AE:98
