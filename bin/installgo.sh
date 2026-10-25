#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)

ProgressBar "Installing Go Programming Language"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo rm -rf /root/golang
    sudo mkdir -p /root/golang
    cd /root/golang
    sudo dnf -y remove go
    sudo dnf -y install go

    sudo rm -rf /usr/lib/golang/*
    sudo rm -rf go1.24.2.linux-amd64.tar.gz
    sudo wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
    sudo tar -xzf go1.24.2.linux-amd64.tar.gz
    cf /root/golang/go /usr/lib/golang

    sudo rm -rf /root/golang

elif [ "$OS" = "Debian" ]; then

    dpkg --configure -a

elif [ "$OS" = "Ubuntu" ]; then

    dpkg --configure -a

fi
