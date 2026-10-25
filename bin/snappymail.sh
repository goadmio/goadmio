#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

ProgressBar "Installing SnappyMail Webmail"

# Backup Data
if sudo test -d /usr/local/goadmio/home/go/webmail/snappymail/data ; then
    sudo mkdir -p /var/go/snappymail/data
    sudo /go/cf /usr/local/goadmio/home/go/webmail/snappymail/data /var/go/snappymail/data
fi

sudo rm -rf /usr/local/goadmio/home/go/webmail/snappymail
sudo mkdir -p /usr/local/goadmio/home/go/webmail/snappymail
cd /usr/local/goadmio/home/go/webmail/snappymail
sudo wget -q https://github.com/the-djmaze/snappymail/releases/download/v2.38.2/snappymail-2.38.2.tar.gz
sudo tar -xzf snappymail-2.38.2.tar.gz
sudo rm -rf snappymail-2.38.2.tar.gz

# Restore Data
if sudo test -d /var/go/snappymail/data ; then
    sudo /go/cf /var/go/snappymail/data /usr/local/goadmio/home/go/webmail/snappymail/data
fi

sudo chmod 777 -R /usr/local/goadmio/home/go/webmail/snappymail/data

# Admin Area: https://webmail.crmrealty.net/snappymail/?admin
# Username: admin
# Password: cat /usr/local/goadmio/home/go/webmail/snappymail/data/_data_/_default_/admin_password.txt
