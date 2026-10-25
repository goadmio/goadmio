#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") '********' >>/var/log/go/$(basename "$0").log

Password=$1

OS=$(</usr/local/goadmio/linux/os.db)

if [ $# -eq 0 ]; then
    exit 1
fi

RemotePassword="$Password"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    echo "$Password" | passwd "root" --stdin

    if [[ "$@" = *"--go"* ]]; then
        echo "$Password" | passwd "go" --stdin
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    Password=$(sudo openssl passwd $Password)
    usermod -p $Password root

    if [[ "$@" = *"--go"* ]]; then
        usermod -p $Password go
    fi

fi

# Encrypt ROOT Password
sudo rm -rf /root/.ssh/known_hosts
MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}' | base64)
echo "$RemotePassword" | sudo openssl enc -aes-128-cbc -pbkdf2 -nosalt -a -md md5 -out /var/go/etc/go.key -pass pass:"$MAC"

history -c

echo "Your ROOT password has been changed successfully."
