#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

while getopts ":d:" opt; do
    case ${opt} in
    d) Domain=$OPTARG ;;
    \?) echo "Usage: bbb [-d] Domain" ;;
    esac
done

if [ "$Domain" = "" ]; then
    echo "Usage: bbb [-d] Domain"
    exit 1
fi

enable_ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 0" | sudo tee -a /etc/sysctl.conf >/dev/null
echo "net.ipv6.conf.default.disable_ipv6 = 0" | sudo tee -a /etc/sysctl.conf >/dev/null
echo "net.ipv6.conf.lo.disable_ipv6 = 0" | sudo tee -a /etc/sysctl.conf >/dev/null
sudo sysctl -p

sudo apt -y install update
sudo apt -y install upgrade
sudo apt -y install nano
sudo apt -y install gnupg2

sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 1935
sudo ufw allow 3478
sudo ufw allow 16384:32768/udp # For WebRTC

sudo wget https://raw.githubusercontent.com/bigbluebutton/bbb-install/v3.0.x-release/bbb-install.sh
sudo chmod +x bbb-install.sh
bash bbb-install.sh -v jammy-300 -s $Domain -e info@$Domain

bbb-conf --restart

sudo systemctl restart nginx

bbb-conf --secret
