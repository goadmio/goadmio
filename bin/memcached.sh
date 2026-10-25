#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    echo "Installing MEMCACHED"
    sudo dnf -y install memcached
    # Securing Memcached
    sudo sed -i 's/OPTIONS=""/OPTIONS="-l 127.0.0.1 -U 0"/g' /etc/sysconfig/memcached
    sudo systemctl enable memcached
    sudo systemctl start memcached

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    echo "Installing Memcached"
    sudo apt -y install memcached
    # Securing Memcached
    sudo sed -i 's/OPTIONS=""/OPTIONS="-l 127.0.0.1 -U 0"/g' /etc/default/memcached
    sudo systemctl enable memcached
    sudo systemctl start memcached

fi
