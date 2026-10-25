#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    sudo dnf -y install tzdata &>/dev/null
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata &>/dev/null
fi
