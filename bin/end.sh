#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo chmod 755 -R /usr/local/goadmio
sudo chmod 555 -R /usr/local/goadmio/home/go
sudo chmod 777 -R /usr/local/goadmio/cache
sudo chmod 777 -R /usr/local/goadmio/home/go/webmail/snappymail/data

sudo chown -R go:go /usr/local/goadmio/home/go
sudo chown -R go:go /var/lib/sqlite
