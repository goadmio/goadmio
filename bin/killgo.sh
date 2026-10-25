#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

PID=$(lsof -i :8080 | tail -n 1 | awk {' print $2 '})

if [ "$PID" != "" ]; then
    sudo lsof -i :8080 | awk 'NR!=1 {print $2}' | xargs kill -9
fi
