#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# remove next
if sudo test -d "/usr/local/go" ; then

    sudo mv /usr/local/go /usr/local/goadmio

    sudo rm -f /go
    sudo ln -s /usr/local/goadmio/bin /go

fi