#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if id "go" >/dev/null 2>&1; then

    # Copy the common profile files (only ones that exist)
    sudo cp -af /root/.bashrc       /var/go/ 2>/dev/null
    sudo cp -af /root/.bash_profile /var/go/ 2>/dev/null
    sudo cp -af /root/.profile      /var/go/ 2>/dev/null
    sudo cp -af /root/.bash_logout  /var/go/ 2>/dev/null
    sudo chown -R go:go /var/go/ 2>/dev/null

fi