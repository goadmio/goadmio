#!/usr/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

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

if [[ ! "$2" = *"--"* ]]; then
    Database=$2
fi

Files=$(sudo find $Directory -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp")

C=$(echo "$Files" | wc -l)

while IFS= read -r File; do

    if [[ "$File" = *.jpg ]] || [[ "$File" = *.jpeg ]] || [[ "$File" = *.gif ]] || [[ "$File" = *.png ]] || [[ "$File" = *.bmp ]]; then

        N=$(($N + 1))

        FileWebP="${File%.*}.webp"

        echo "[$N/$C] Converting $File to $FileWebP..."

        cwebp -q 80 "$File" -o "$FileWebP" -quiet

        if sudo test -f "$FileWebP" ; then

            if [[ ! "$@" = *"--keep"* ]]; then
                sudo rm -rf $File
            fi

        fi

    fi

done <<<"$Files"

if [ "$Database" != "" ]; then

    sudo mariadb -uroot -p$MySQLRootPassword -e "UPDATE IGNORE $Database.Image SET ImageName=replace(ImageName,'.jpeg','.webp');"
    sudo mariadb -uroot -p$MySQLRootPassword -e "UPDATE IGNORE $Database.Image SET ImageName=replace(ImageName,'.jpg','.webp');"
    sudo mariadb -uroot -p$MySQLRootPassword -e "UPDATE IGNORE $Database.Image SET ImageName=replace(ImageName,'.png','.webp');"
    sudo mariadb -uroot -p$MySQLRootPassword -e "UPDATE IGNORE $Database.Image SET ImageName=replace(ImageName,'.gif','.webp');"
    sudo mariadb -uroot -p$MySQLRootPassword -e "UPDATE IGNORE $Database.Image SET ImageName=replace(ImageName,'.bmp','.webp');"

fi
