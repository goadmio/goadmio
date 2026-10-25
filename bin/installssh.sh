#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo /usr/bin/dnf -y remove openssh-server
    sudo /usr/bin/dnf -y remove openssh-clients
    sudo /usr/bin/dnf -y install openssh-server
    sudo /usr/bin/dnf -y install openssh-clients

    sudo firewall-cmd --zone=public --add-port=22/tcp --permanent

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    dpkg --configure -a

    DEBIAN_FRONTEND='noninteractive' apt -y purge openssh-server
    DEBIAN_FRONTEND='noninteractive' apt -y purge openssh-client

    DEBIAN_FRONTEND='noninteractive' apt -y remove openssh-server
    DEBIAN_FRONTEND='noninteractive' apt -y remove openssh-client
    DEBIAN_FRONTEND='noninteractive' apt -y install openssh-server
    DEBIAN_FRONTEND='noninteractive' apt -y install openssh-client

    sudo ufw allow ssh
    sudo ufw allow 22/tcp

fi

sudo rm -rf /etc/ssh/sshrc
sudo /go/ssh
