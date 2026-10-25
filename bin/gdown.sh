#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y install python3-paramiko
    sudo dnf -y install python3
    yes | cp -rf /usr/bin/pip3 /usr/bin/pip
    pip install gdown

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt -y install pip
    pip install gdown

fi

echo "Examples:-"
echo "Download file from google drive:"
echo "gdown --id <file_id>"
echo ""
echo "Download folder from google drive:"
echo "gdown --folder --id <folder_id>"
