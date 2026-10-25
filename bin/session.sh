#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo chmod 755 /etc/my.cnf
sudo chmod 755 /root/.my.cnf

# Session Problems
sudo mkdir -p /tmp
sudo mkdir -p /var/lib/php/session
sudo mkdir -p /var/lib/php/sessions
sudo mkdir -p /var/lib/5.6/session
sudo mkdir -p /var/lib/7.0/session
sudo mkdir -p /var/lib/7.1/session
sudo mkdir -p /var/lib/7.2/session
sudo mkdir -p /var/lib/7.3/session
sudo mkdir -p /var/lib/7.4/session
sudo mkdir -p /var/lib/8.0/session
sudo mkdir -p /var/lib/8.1/session
sudo mkdir -p /var/lib/8.2/session
sudo mkdir -p /var/lib/8.3/session
sudo mkdir -p /var/lib/8.4/session
sudo mkdir -p /var/lib/8.5/session
sudo mkdir -p /var/lib/php56/session
sudo mkdir -p /var/lib/php70/session
sudo mkdir -p /var/lib/php71/session
sudo mkdir -p /var/lib/php72/session
sudo mkdir -p /var/lib/php73/session
sudo mkdir -p /var/lib/php74/session
sudo mkdir -p /var/lib/php80/session
sudo mkdir -p /var/lib/php81/session
sudo mkdir -p /var/lib/php82/session
sudo mkdir -p /var/lib/php83/session
sudo mkdir -p /var/lib/php84/session
sudo mkdir -p /var/lib/php85/session

sudo chmod 777 /tmp
sudo chmod 777 /var/lib/php/session
sudo chmod 777 /var/lib/php/sessions
sudo chmod 777 /var/lib/5.6/session
sudo chmod 777 /var/lib/7.0/session
sudo chmod 777 /var/lib/7.1/session
sudo chmod 777 /var/lib/7.2/session
sudo chmod 777 /var/lib/7.3/session
sudo chmod 777 /var/lib/7.4/session
sudo chmod 777 /var/lib/8.0/session
sudo chmod 777 /var/lib/8.1/session
sudo chmod 777 /var/lib/8.2/session
sudo chmod 777 /var/lib/8.3/session
sudo chmod 777 /var/lib/8.4/session
sudo chmod 777 /var/lib/8.5/session
sudo chmod 777 /var/lib/php56/session
sudo chmod 777 /var/lib/php70/session
sudo chmod 777 /var/lib/php71/session
sudo chmod 777 /var/lib/php72/session
sudo chmod 777 /var/lib/php73/session
sudo chmod 777 /var/lib/php74/session
sudo chmod 777 /var/lib/php80/session
sudo chmod 777 /var/lib/php81/session
sudo chmod 777 /var/lib/php82/session
sudo chmod 777 /var/lib/php83/session
sudo chmod 777 /var/lib/php84/session
sudo chmod 777 /var/lib/php85/session


