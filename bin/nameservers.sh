#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

NS1=$1
NS2=$2
NS3=$3
NS4=$4

if [ "$1" = "return" ]; then

    String=""

    File="/etc/nameservers"
    while IFS= read Line; do

        if [ "$String" = "" ]; then
            String="$Line"
        else
            String="$String|$Line"
        fi

    done <"$File"

    echo "$String"

    exit 1

fi

if [ $# -eq 0 ]; then
    exit 1
fi

echo "$NS1" | sudo tee /etc/nameservers >/dev/null
echo "$NS2" | sudo tee -a /etc/nameservers >/dev/null
echo "$NS3" | sudo tee -a /etc/nameservers >/dev/null
echo "$NS4" | sudo tee -a /etc/nameservers >/dev/null

echo "Nameservers changed to:"
echo "$NS1"
echo "$NS2"
echo "$NS3"
echo "$NS4"

sudo /go/zone all update

# Create Main DNS
MAIN=$(echo "$NS1" | cut -d '.' -f2-)
sudo /go/zone $MAIN main
