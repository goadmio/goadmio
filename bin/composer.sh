#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

ProgressBar "Installing Composer"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    sudo dnf -y install composer
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    DEBIAN_FRONTEND='noninteractive' apt -y install composer
fi
