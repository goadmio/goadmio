#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $# -eq 0 ]; then
    exit 1
fi

OS=$(</usr/local/goadmio/linux/os.db)

# IF IPV4
if [[ "$1" =~ ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$ ]]; then

    # Admin login alert with sendmail
    IP=$1
    sudo curl -s -o /usr/local/goadmio/tmp/ssh.info https://ipinfo.io/$IP
    Country=$(sudo grep -oP '"country": "\K[^"]+' /usr/local/goadmio/tmp/ssh.info)
    City=$(sudo grep -oP '"city": "\K[^"]+' /usr/local/goadmio/tmp/ssh.info)

    sudo /go/sendmail "Admin Login Alerts" "User root just logged in from $IP ($City - $Country)" "Admin Login"
    sudo /go/sendwhatsapp "*Admin Login Alerts*\n\nUser root just logged in from $IP ($City - $Country)" "Admin Login"

else

    # Change Admin Password
    Password=$1

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        echo "$Password" | passwd "admin" --stdin
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        Password=$(sudo openssl passwd $Password)
        usermod -p $Password admin

    fi

fi