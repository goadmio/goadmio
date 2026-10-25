#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Password=$1

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo groupdel skeleton &>/dev/null
    sudo userdel skeleton &>/dev/null
    sudo adduser skeleton &>/dev/null

    echo "$Password" | passwd "skeleton" --stdin

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo groupdel skeleton &>/dev/null
    sudo userdel skeleton &>/dev/null

    sudo /go/adduser skeleton $Password

else
    echo "Unknown operating system."
    exit
fi

if sudo test -d /var/skeleton ; then
    sudo chmod a+w /var/skeleton
fi

echo "Skeleton FTP password has been changed successfully."

sudo systemctl restart vsftpd
