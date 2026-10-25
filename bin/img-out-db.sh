#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $1 = "restore" ]; then

    sh /usr/local/goadmio/tmp/restore.sh
    exit 1

fi

if sudo test -d "$1" ; then
    Directory="$1"
elif sudo test -d "/home/$1/www" ; then
    Directory="/home/$1/www"
else
    echo "Domain $1 does not exist."
    exit 1
fi

if [ "$2" = "" ]; then
    echo "Please enter database name."
    exit 1
fi

sudo mariadb-dump $2 >/usr/local/goadmio/tmp/$2.sql

sudo find $Directory -name *.webp -o -name *.jpeg -o -name *.jpg -o -name *.png -o -name *.gif -o -name *.mp4 -o -name *.pdf -o -name *.doc -o -name *.zip -o -name *.tar -o -name *.gz >/usr/local/goadmio/tmp/images.db

sudo mkdir -p /usr/local/goadmio/tmp/image

Line="/usr/local/goadmio/tmp/images.db"
while IFS= read P; do

    IFS='/' read -r -a Array <<<"$P"
    Filename=${Array[-1]}

    if ! grep -q "$Filename" /usr/local/goadmio/tmp/$2.sql; then

        N=$(($N + 1))

        echo "$N - $P"

        sudo mv $P /usr/local/goadmio/tmp/image
        echo "cp /usr/local/goadmio/tmp/image/$Filename $P" | sudo tee -a /usr/local/goadmio/tmp/restore.sh >/dev/null

    fi

done <"$Line"
