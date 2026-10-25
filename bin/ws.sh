#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo mkdir -p /usr/local/goadmio/linux

if [[ $(ps -acx | grep httpd | wc -l) > 0 ]]; then

    echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

fi

if [[ $(ps -acx | grep apache | wc -l) > 0 ]]; then

    echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

fi

if [[ $(ps -acx | grep nginx | wc -l) > 0 ]]; then

    echo "NGINX" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

fi

if sudo test ! -f "/usr/local/goadmio/linux/ws.db" ; then

    echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

fi
