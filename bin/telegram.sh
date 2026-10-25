#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if ! command -v tdl &>/dev/null; then

    sudo wget https://github.com/iyear/tdl/releases/download/v0.20.3/tdl_Linux_64bit.tar.gz
    sudo tar -xzf tdl_Linux_64bit.tar.gz
    sudo mv tdl /usr/local/bin/
    sudo chmod +x /usr/local/bin/tdl

fi

if [ "$1" = "login" ]; then

    sudo tdl login --type code

    ChannelIDs=$(tdl chat ls -f "Type == 'channel'" | awk '{print $1,$3,$4}' | grep '-' | awk '{print $1,$2}')
    echo "$ChannelIDs"
    ChannelID=$(echo "$ChannelIDs" | awk '{print $1}')

    read -p "ChannelID: " -e -i "$ChannelID" ChannelID

    echo "ChannelID=\"$ChannelID\"" | sudo tee /var/go/etc/telegram.conf >/dev/null

    exit 1

fi

if sudo test -f /var/go/etc/telegram.conf ; then
    source /var/go/etc/telegram.conf
else
    sudo /go/telegram login
    exit 1
fi

if sudo test -f "$1" ; then

    File=$(basename $1)

    sudo tdl up "$File" --chat $ChannelID --path "$1"

elif sudo test -d "$1" ; then

    sudo find $1 -type f -print0 | while IFS= read -r -d '' P; do

        File=$(basename $P)
        sudo tdl up "$File" --chat $ChannelID --path "$P"

    done

else

    sudo tdl chat export -c $ChannelID -o /usr/local/goadmio/tmp/export.json
    ID=$(jq -r ".messages[] | select(.file == \"$1\") | .id" /usr/local/goadmio/tmp/export.json | head -1)

    sudo tdl dl -u https://t.me/c/$ChannelID/$ID -d .
    sudo mv ${ChannelID}_${ID}_$1 $1

fi
