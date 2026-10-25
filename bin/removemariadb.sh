#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo rm -rf /etc/yum.repos.d/mariadb.repo

    sudo dnf -y remove mariadb*
    sudo dnf -y remove MariaDB*
    sudo dnf clean all
    sudo rm -rf /var/cache/yum/*

elif [ "$OS" = "Debian" ]; then

    sudo apt -y remove mariadb-*

elif [ "$OS" = "Ubuntu" ]; then

    DEBIAN_FRONTEND='noninteractive' apt -y remove mariadb-*

else
    echo "Unknown operating system."
    exit
fi
