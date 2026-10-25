#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Centos 7
    sudo yum -y groupinstall "Server with GUI"

    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum -y install tigervnc-server
    sudo yum -y install xrdp
    sudo systemctl enable xrdp
    sudo systemctl restart xrdp

    sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
    sudo firewall-cmd -reload

    echo ""
    echo "Now, it’s time to take RDP sessions from any Windows machine using Remote Desktop Protocol."
    echo "Run Remote Desktop on Windows"
    echo "Username: root"
    echo "Password: ******** (ROOT Password)"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt -y install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
    sudo apt -y install xrdp
    sudo apt -y install firefox-esr
    adduser xrdp ssl-cert
    sudo systemctl enable xrdp
    sudo systemctl restart xrdp
    sudo ufw allow 3389

    echo ""
    echo "Now, it’s time to take RDP sessions from any Windows machine using Remote Desktop Protocol."
    echo "Run Remote Desktop on Windows"
    echo "Username: root"
    echo "Password: ******** (ROOT Password)"

else
    echo "Unknown operating system."
    exit 1
fi
