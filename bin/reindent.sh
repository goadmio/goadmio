#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" = "all" ]; then
    shfmt -w -i 4 *.sh
elif sudo test -f "$1" ; then
    shfmt -w -i 4 $1
fi
