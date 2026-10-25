#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

echo "Deleting mail queue..."

sudo /usr/sbin/postsuper -d ALL
sudo /usr/sbin/postsuper -d ALL deferred
