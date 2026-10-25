#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if sudo test -f /usr/local/goadmio/include/config/config.php ; then
    SSHUsername=$(sudo grep -oP 'SSHUsername="\K[^"]+' /usr/local/goadmio/include/config/config.php)
else
    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}')
    SSHUsername=$(echo -n "$ServerIP|$MAC" | md5sum | awk '{print "go" substr($1, 0, 14)}')
fi

SSHPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET SSHPassword='$SSHPassword'"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Grant Root Privileges
    sudo useradd -M -ou 0 -g 0 $SSHUsername &>/dev/null
    echo "$SSHPassword" | sudo passwd "$SSHUsername" --stdin &>/dev/null

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # Grant Root Privileges
    sudo useradd -M -ou 0 -g 0 $SSHUsername &>/dev/null
    sudo usermod --password $(echo $SSHPassword | openssl passwd -1 -stdin) $SSHUsername

fi
