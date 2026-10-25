#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

echo "go ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/go >/dev/null
