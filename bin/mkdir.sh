#!/bin/bash

sudo mkdir -p /var/log/go
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo mkdir -p /var/lib/sqlite
sudo mkdir -p /usr/local/goadmio
sudo mkdir -p /usr/local/goadmio/linux
sudo mkdir -p /usr/local/goadmio/backup
sudo mkdir -p /usr/local/goadmio/include
sudo mkdir -p /usr/local/goadmio/include/config
sudo mkdir -p /usr/local/goadmio/install
sudo mkdir -p /usr/local/goadmio/template
sudo mkdir -p /usr/local/goadmio/template/default
sudo mkdir -p /usr/local/goadmio/template/publish
sudo mkdir -p /usr/local/goadmio/lock
sudo mkdir -p /var/log/go/progress
sudo mkdir -p /var/log/go/block
sudo mkdir -p /var/log/go/mail
sudo mkdir -p /var/log/go/mysql
sudo mkdir -p /var/log/go/delete
sudo mkdir -p /var/log/go/snapshot
sudo mkdir -p /var/log/go/cron
sudo mkdir -p /var/log/go/ip/country
sudo mkdir -p /var/log/go/ip/city
sudo mkdir -p /var/log/go/ip/whois
sudo mkdir -p /var/log/go/ip/company
sudo mkdir -p /var/log/go/background
sudo mkdir -p /var/log/go/recover
sudo mkdir -p /usr/local/goadmio/vps
sudo mkdir -p /usr/local/goadmio/tmp
sudo mkdir -p /usr/local/goadmio/db
sudo mkdir -p /var/lib/sqlite/backup
sudo mkdir -p /var/go/etc
sudo mkdir -p /var/go/cron/daily
sudo mkdir -p /var/go/cron/weekly
sudo mkdir -p /var/go/cron/monthly
sudo mkdir -p /var/go/wa
sudo mkdir -p /whatsapp
sudo mkdir -p /backup
sudo mkdir -p /root/.config/rclone
sudo mkdir -p /usr/local/goadmio/db/upgrade

# DNS ZONE DB
sudo mkdir -p /etc/zone
sudo mkdir -p /etc/bind/zone

sudo mkdir -p /cache
sudo chmod 777 /cache

sudo mkdir -p /usr/local/goadmio/cache
sudo chmod 777 /usr/local/goadmio/cache

# Create API folder
sudo mkdir -p /api
sudo chmod 777 /api

sudo mkdir -p /tmp/s3
sudo chmod 777 /tmp/s3

sudo mkdir -p /run/sock

sudo mkdir -p /usr/local/goadmio/sqlite
echo ".timeout 30000" | sudo tee /usr/local/goadmio/sqlite/sqlite.conf >/dev/null

# Log Folders
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/log/redis
sudo mkdir -p /var/log/mosquitto
sudo mkdir -p /var/log/audit
sudo mkdir -p /var/log/php-fpm
sudo mkdir -p /var/log/anaconda
sudo mkdir -p /var/log/chrony
sudo mkdir -p /var/log/qemu-ga
sudo mkdir -p /var/log/private
sudo mkdir -p /var/log/journal
sudo mkdir -p /var/log/letsencrypt
sudo mkdir -p /var/log/httpd
sudo mkdir -p /var/log/apache2
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/log/samba
sudo mkdir -p /var/log/sssd

echo "1|Creating Directories" | sudo tee /usr/local/goadmio/install/progress.html >/dev/null
