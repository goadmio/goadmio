#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test ! -f "/etc/network/interfaces.bak" ; then
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
fi

IP4=$(curl -s -4 icanhazip.com)
IP6=$(curl -s -6 icanhazip.com)

CIDR=$(sudo grep -oP "address [0-9.]+/\K[0-9]+" /etc/network/interfaces.bak)

Gateway4=$(sudo grep -oP "gateway \K[0-9.]+" /etc/network/interfaces.bak)
Netmask4=$(sudo grep -oP "netmask \K[0-9.]+" /etc/network/interfaces.bak | head -n 1)

if [[ ! "$Gateway4" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    Gateway4=$(ip route show default | awk '/default/ {print $3}')
fi

if [[ ! "$Netmask4" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

    Netmask4=$(sudo /usr/sbin/ifconfig | grep -w "inet" | awk '{print $4}' | tail -n 1)

    if [ "$Netmask4" = "255.0.0.0" ]; then
        Netmask4=$(sudo /usr/sbin/ifconfig | grep -w "inet" | awk '{print $4}' | head -n 1)
    fi

fi

if [ "$CIDR" = "30" ]; then
    Netmask4="255.255.255.252"
elif [ "$CIDR" = "29" ]; then
    Netmask4="255.255.255.248"
elif [ "$CIDR" = "28" ]; then
    Netmask4="255.255.255.240"
elif [ "$CIDR" = "27" ]; then
    Netmask4="255.255.255.224"
elif [ "$CIDR" = "26" ]; then
    Netmask4="255.255.255.192"
elif [ "$CIDR" = "25" ]; then
    Netmask4="25255.255.255.128"
elif [ "$CIDR" = "24" ]; then
    Netmask4="255.255.255.0"
fi

Gateway6=$(ip -6 route show default | awk '/default/ {print $3}')

Subnet=$(sudo grep -oP "up route add -net \K[0-9.]+" /etc/network/interfaces.bak)

cd /sys/class/net
for File in *; do

    if [ "$File" != "bonding_masters" ] && [ "$File" != "lo" ] && [ "$File" != "vmbr0" ] && [[ "$File" != *"_"* ]] && [[ "$File" != *"-"* ]]; then

        if grep -q "$File" /etc/network/interfaces.bak; then
            Network="$File"
        fi

    fi

done

echo "source /etc/network/interfaces.d/*" | sudo tee /etc/network/interfaces >/dev/null
echo "" | sudo tee -a /etc/network/interfaces >/dev/null
echo "auto lo" | sudo tee -a /etc/network/interfaces >/dev/null
echo "iface lo inet loopback" | sudo tee -a /etc/network/interfaces >/dev/null

if [ "$IP6" != "" ] && [ "$Gateway6" != "" ]; then
    echo "iface lo inet6 loopback" | sudo tee -a /etc/network/interfaces >/dev/null
fi

echo "" | sudo tee -a /etc/network/interfaces >/dev/null
echo "iface $Network inet manual" | sudo tee -a /etc/network/interfaces >/dev/null
echo "" | sudo tee -a /etc/network/interfaces >/dev/null
echo "auto vmbr0" | sudo tee -a /etc/network/interfaces >/dev/null
echo "iface vmbr0 inet static" | sudo tee -a /etc/network/interfaces >/dev/null

if [ "$CIDR" = "" ]; then
    echo "    address $IP4" | sudo tee -a /etc/network/interfaces >/dev/null
else
    echo "    address $IP4/$CIDR" | sudo tee -a /etc/network/interfaces >/dev/null
fi

echo "    gateway $Gateway4" | sudo tee -a /etc/network/interfaces >/dev/null
echo "    dns-nameservers 8.8.8.8" | sudo tee -a /etc/network/interfaces >/dev/null
echo "    bridge_ports $Network" | sudo tee -a /etc/network/interfaces >/dev/null
echo "    bridge_stp off" | sudo tee -a /etc/network/interfaces >/dev/null
echo "    bridge_fd 0" | sudo tee -a /etc/network/interfaces >/dev/null

if sudo test -f /proc/sys/net/ipv4/ip_forward ; then
    echo "    post-up echo 1 > /proc/sys/net/ipv4/ip_forward" | sudo tee -a /etc/network/interfaces >/dev/null
fi

if sudo test -f /proc/sys/net/ipv4/conf/$Network/proxy_arp ; then
    echo "    post-up echo 1 > /proc/sys/net/ipv4/conf/$Network/proxy_arp" | sudo tee -a /etc/network/interfaces >/dev/null
fi

echo "" | sudo tee -a /etc/network/interfaces >/dev/null

if sudo test -f "/etc/vm" ; then

    # DHCP
    echo "subnet $Subnet netmask $Netmask4 {" | sudo tee /etc/dhcp/dhcpd.conf >/dev/null
    echo "authoritative;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
    echo "default-lease-time 21600000;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
    echo "max-lease-time 432000000;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
    echo "}" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
    echo "" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null

    N=100

    Line="/etc/vm"
    while IFS= read IP; do

        if [[ "$IP" =~ ^[0-9] ]]; then

            N=$(($N + 1))

            MAC=$(printf '00:%02X:%02X:%02X:%02X:%02X\n' $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))

            echo "host VM$N {" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
            echo "hardware ethernet $MAC;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
            echo "option routers $Gateway4;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
            echo "option subnet-mask $Netmask4;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
            echo "fixed-address $IP;" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null
            echo "}" | sudo tee -a /etc/dhcp/dhcpd.conf >/dev/null

            if [[ "$IP" = *"/"* ]]; then
                # Subnet
                echo "    up ip route add $IP dev vmbr0" | sudo tee -a /etc/network/interfaces >/dev/null
            else
                # One IP
                echo "    up ip route add $IP/32 dev vmbr0" | sudo tee -a /etc/network/interfaces >/dev/null
            fi

        fi

    done <"$Line"

fi

if [ "$IP6" != "" ] && [ "$Gateway6" != "" ]; then
    echo "" | sudo tee -a /etc/network/interfaces >/dev/null
    echo "iface vmbr0 inet6 static" | sudo tee -a /etc/network/interfaces >/dev/null
    echo "    address $IP6" | sudo tee -a /etc/network/interfaces >/dev/null
    echo "    netmask 64" | sudo tee -a /etc/network/interfaces >/dev/null
    echo "    gateway $Gateway6" | sudo tee -a /etc/network/interfaces >/dev/null
fi
