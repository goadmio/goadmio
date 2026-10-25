#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo dnf -y install dpkg
sudo dnf -y install npm

sudo npm install -g idrive-cli

sudo wget https://www.idrivedownloads.com/downloads/linux/linux-desktop/IDriveForLinux.deb
sudo /usr/bin/idrive-cli setup --deb IDriveForLinux.deb --trust-package

# echo 'tiger' | /usr/bin/idrive-cli login info@goadmio.com --password-stdin
