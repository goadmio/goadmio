#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test -f "$1"  || sudo test -d "$1" ; then
    Directory="$1"
elif [ "$1" = "all" ]; then
    Directory="/home"
elif [[ $1 = *"/www/"* ]] && sudo test -d "$1" ; then
    Directory="$1"
elif sudo test -d "/home/$1/www" ; then
    Directory="/home/$1/www"
else
    echo "$1 does not exist"
    exit 1
fi

sudo find $Directory -type f -name "*.php" -print0 | xargs -0r awk ' /^\xEF\xBB\xBF/ {print FILENAME} {nextfile}'
