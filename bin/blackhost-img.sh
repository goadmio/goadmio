#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo apt -y install nano
sudo apt -y install curl
sudo apt -y install wget
sudo apt -y install parted
sudo apt -y install gdisk
sudo apt -y install lvm2

sudo yum -y install nano
sudo yum -y install curl
sudo yum -y install wget
sudo yum -y install parted
sudo yum -y install gdisk
sudo yum -y install lvm2

# Shell Welcome Message

sudo wget https://www.blackhost.com/blackhost.img --no-check-certificate
sudo cat /root/blackhost.img >/etc/motd
echo "" | sudo tee -a /etc/motd >/dev/null
echo "If you have questions or need help, don't hesitate to get in touch." | sudo tee -a /etc/motd >/dev/null
echo "Email: support@blackhost.com" | sudo tee -a /etc/motd >/dev/null
echo "Website: www.blackhost.com" | sudo tee -a /etc/motd >/dev/null
echo "" | sudo tee -a /etc/motd >/dev/null

echo "[Unit]" | sudo tee /etc/systemd/var/go/blackhost.service >/dev/null
echo "Description=Blackhost" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "[Service]" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "User=root" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "WorkingDirectory=/usr/bin" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "ExecStart=/usr/bin/blackhost" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "# optional items below" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "Restart=always" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "RestartSec=3" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "[Install]" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
echo "WantedBy=multi-user.target" | sudo tee -a /etc/systemd/var/go/blackhost.service >/dev/null
sudo systemctl enable blackhost
sudo chmod +x /usr/bin/blackhost

if sudo test ! -f /etc/fstab ; then

    sudo touch /etc/fstab
    sudo chmod 0640 /etc/fstab

fi
