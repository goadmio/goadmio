#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo rm -rf /opt/IDriveForLinux

sudo wget https://www.idrivedownloads.com/downloads/linux/download-for-linux/linux-bin/idriveforlinux.bin
sudo chmod a+x idriveforlinux.bin
./idriveforlinux.bin --install
sudo rm -rf idriveforlinux.bin

# To run idrive from any folder
alias idrive='sudo /opt/IDriveForLinux/bin/idrive'
sudo grep -q '^alias idrive=' ~/.bashrc || echo 'alias idrive="sudo /opt/IDriveForLinux/bin/idrive"' >>~/.bashrc

# idrive --backup
# idrive -e
# idrive --scheduler
# idrive --speed-test
# idrive --terminate-job

# idrive --restore
# Default Restore Path
# /opt/IDriveForLinux/idriveIt/user_profile/root/info@goadmio.com/Restore_Data

# Delete all lines containing "idrivecron" from your crontab
crontab -l | grep -v "idrivecron" | crontab -
