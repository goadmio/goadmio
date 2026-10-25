#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" = "" ]; then
    Dir=$(pwd)
elif sudo test -f "$1" ; then
    Dir=$1
elif sudo test -d "$1" ; then
    Dir=$1
else

    echo "Mo such file or directory"
    exit 1

fi

Files=$(sudo find $Dir -maxdepth 1 -type f)
C=$(echo "$Files" | wc -l)

if [ "$Files" != "" ]; then

    while read File; do

        Name=$(echo "${File##*/}")

        Chmod=$(stat -c "%a %n" $File | awk {' print $1 '})
        Info=$(ls -lh --time-style='+%Y-%m-%d %H:%M' $File | awk {' print $2 " " $3 " " $4 " " $5 " " $6 " " $7 '})

        OUTPUT="$OUTPUT\n$Chmod $Info $Name"

    done <<<"$Files"

    echo -ne $OUTPUT | column -t | sort -k 8

fi
