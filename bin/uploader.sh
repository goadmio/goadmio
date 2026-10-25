#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

Stamp=$1
TimeStamp=$(date +'%s')

if [ $# -eq 1 ] && sudo test -f $1 ; then

    sudo find . -name "88888888888.jpg" -type f -exec readlink -f {} \;

    File=$(sudo find $1 -type f -exec readlink -f {} \;)
    Domain=$(echo "$File" | cut -d'/' -f3)

    FileSize=$(stat -c %s $File)
    FileStamp=$(stat -c %Y $File)

    sudo /go/uploader 604800 | grep "$Domain" | sudo tee /usr/local/goadmio/tmp/uploader.log >/dev/null

    FileSizeMin=$(($FileSize - 1000))
    FileSizeMax=$(($FileSize + 10000))

    FileStampMin=$(($FileStamp - 30))
    FileStampMax=$(($FileStamp + 30))

    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

    echo "File Size: $FileSize (Excluding Header Size)"

    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

    sudo awk '$1 > '"$FileSizeMin"' && $1 < '"$FileSizeMax"' && $3 > '"$FileStampMin"' && $3 < '"$FileStampMax"' { print $1, $2, $4, $5 }' /usr/local/goadmio/tmp/uploader.log | sort -n | column -t

    exit 1

fi

if [[ "$Stamp" =~ ^[0-9]+$ ]]; then
    TTL=$((TimeStamp - $Stamp))
elif [ "$Stamp" = "hour" ]; then
    TTL=$((TimeStamp - 3600))
else
    TTL=$((TimeStamp - 86400))
fi

if sudo test -f "/etc/posttop" ; then

    Limit=$(</etc/posttop)

    if ! [[ "$Limit" =~ ^[0-9]+$ ]]; then
        Limit="250"
    fi

else

    Limit="250"

fi

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

sudo awk -F'|' '$6 > '"$TTL"' && $11 ~ /POST/ { print $9, $7, $6, ($4 != "-" ? $4 : $3), $2""$11 }' $LOG | sort -n | column -t
