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

    sudo mkdir -p /var/log/go/pdf

    Domain=$(echo "$1" | cut -d'/' -f3)

    for Char in a b c d e f 0 1 2 3 4 5 6 7 8 9; do

        if sudo test -f /var/log/go/pdf/$Domain-$Char.log  && [[ "$@" = *"--skip log"* ]]; then

            echo "/go/pdf $1 $Char | Skipped"
            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

        else

            echo "/go/pdf $1 $Char"
            echo "LOG File: /var/log/go/pdf/$Domain-$Char.log"
            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

            sudo nohup /go/pdf $1 $Char >/var/log/go/pdf/$Domain-$Char.log 2>&1 &

        fi

    done

    exit 1

fi

if [[ ! "$2" = *"--"* ]]; then
    StartsWith=$2
fi

# -newermt "2020-02-23"

if [ "$StartsWith" = "" ]; then
    Files=$(sudo find $Directory -name "*.pdf")
else
    Files=$(sudo find $Directory -name "$StartsWith*.pdf")
fi

C=$(echo "$Files" | wc -l)

while IFS= read -r File; do

    if [[ "$File" = *"."* ]]; then

        N=$(($N + 1))

        if [[ "$@" = *"--screen"* ]]; then
            # screen
            gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -sOutputFile=$File.bak $File
        else
            # ebook
            gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -sOutputFile=$File.bak $File
        fi

        # Copies the timestamps from one file to another
        sudo touch -r "$File" "$File.bak"

        if sudo test -f $File.bak ; then

            FSize=$(wc -c <$File)
            BSize=$(wc -c <$File.bak)

            if [ "$BSize" -lt "$FSize" ]; then

                P=$(sudo awk "BEGIN {print int($BSize * 100 / $FSize)}")

                if [ "$C" -eq "1" ]; then
                    echo "Resizing $File ($P%)..."
                else
                    echo "[$N/$C] Resizing $File ($P%)..."
                fi

                sudo rm -rf $File
                sudo mv $File.bak $File

            else

                if [ "$C" -eq "1" ]; then
                    echo "Resizing $File (Same Size)..."
                else
                    echo "[$N/$C] Resizing $File (Same Size)..."
                fi

                sudo rm -rf $File.bak

            fi

        fi

    fi

done <<<"$Files"
