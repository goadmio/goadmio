#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

LockFile="/usr/local/goadmio/lock/hourly.lock"
if [ "$1" = "block" ]; then

    if sudo test -f $LockFile ; then
        if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
            InstanceFile=$(<$LockFile)
            echo "Instance ($InstanceFile) already running."
            exit 1
        fi
    fi

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

	# Run When Click Ctrl+C
	trap 'sudo rm -f "$LockFile"' EXIT

fi

if [ $(date +%H) -eq 00 ]; then

    sudo /go/daily

else

    M=$(date +%-M)

    if [ "$M" -le 10 ]; then
        sudo /go/iptop block
    fi

    if [ "$M" -le 10 ]; then
        sudo /go/posttop block
    fi

    if [ "$M" -le 10 ]; then
        sudo /go/bottop block
    fi

    if [ "$M" -le 10 ]; then
        sudo /go/404top block
    fi

    if [ "$M" -le 10 ]; then
        sudo /go/sshtop block
    fi

    if [ "$M" -le 10 ]; then
        sudo /go/sasltop block
    fi

    sudo /go/underattack
    sudo /go/checkapache
    sudo /go/checknginx
    sudo /go/fm
    sudo /go/mem
    sudo /go/cpu
    sudo /go/memoryavg
    sudo /go/loadavg

fi

sudo rm -f $LockFile
