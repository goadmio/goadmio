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

if [[ "$@" = *"--md5"* ]]; then

    sudo mkdir -p /var/log/go/img

    Domain=$(echo "$1" | cut -d'/' -f3)

    for Char in a b c d e f 0 1 2 3 4 5 6 7 8 9; do

        if sudo test -f /var/log/go/img/$Domain-$Char.log  && [[ "$@" = *"--skip log"* ]]; then

            echo "/go/img $1 $Char | Skipped"
            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

        else

            echo "/go/img $1 $Char"
            echo "LOG File: /var/log/go/img/$Domain-$Char.log"
            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

            sudo nohup /go/img $1 $Char >/var/log/go/img/$Domain-$Char.log 2>&1 &

        fi

    done

    exit 1

fi

if [[ ! "$2" = *"--"* ]]; then
    StartsWith=$2
fi

if [ "$StartsWith" = "" ]; then
    Files=$(sudo find $Directory -name "*.webp" -size +512k -o -name "*.jpeg" -size +512k -o -name "*.jpg" -size +512k -o -name "*.png" -size +512k)
else
    Files=$(sudo find $Directory -name "$StartsWith*.webp" -size +512k -o -name "$StartsWith*.jpeg" -size +512k -o -name "$StartsWith*.jpg" -size +512k -o -name "$StartsWith*.png" -size +512k)
fi

C=$(echo "$Files" | wc -l)

while IFS= read -r File; do

    if [[ "$File" = *"."* ]]; then

        N=$(($N + 1))

        echo "[$N/$C] Resizing $File..."

        convert $File -resize 800x600 $File

    fi

done <<<"$Files"
