#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

TimeStamp=$(date +'%s')

if sudo test -f /usr/local/goadmio/tmp/wa.db ; then
    LockStamp=$(</usr/local/goadmio/tmp/wa.db)
    Diff=$((TimeStamp - LockStamp))
    Wait=$((50 - $Diff))

    if [ "$Diff" -lt "50" ]; then
        echo "Please wait $Wait seconds"
        exit 1
    fi
fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)

Err=0

if ! command -v npx &>/dev/null; then
    sudo /go/nodejs
    exit 1
fi

if sudo test -d /var/go/.local/share/mudslide ; then

    LoginNumber=$(timeout 7s npx mudslide me -c /var/go/.local/share/mudslide | grep -oP "\d{10,15}:" | sed "s/[^0-9]//g")

    if [[ "$LoginNumber" =~ ^[0-9]+$ ]]; then

        sudo mkdir -p /var/go/wa/$LoginNumber
        sudo rm -rf /var/go/wa/$LoginNumber/*
        sudo mv /var/go/.local/share/mudslide/* /var/go/wa/$LoginNumber/
        sudo rm -rf /var/go/.local/share/mudslide

        echo "0" | sudo tee /var/go/wa/$LoginNumber/failed >/dev/null

    fi

fi

if sudo test -f "/var/go/etc/wa" ; then
    DBName=$(</var/go/etc/wa)
else
    DBName="crm"
fi

if [ "$1" = "list" ]; then
    ls /var/go/wa -1
    exit 1
fi

# Create Login URL
if sudo test -d "/home/$1/www"  && [[ "$1" = *"."* ]]; then

    PID=$(lsof -i :50000 | tail -n 1 | awk {' print $2 '})

    if [ "$PID" != "" ]; then
        lsof -i :50000 | awk 'NR!=1 {print $2}' | xargs kill -9
    fi

    Domain=$1
    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

    sudo mkdir -p /var/go/.local/share/mudslide

    DomainIP=$(dig $Domain +short | tail -n1)
    if [ "$DomainIP" = "$ServerIP" ]; then
        echo "https://root:$Password@$Domain:50000"
        sudo nohup ttyd -p 50000 --credential root:$Password --ssl --ssl-cert /etc/letsencrypt/live/$Domain/fullchain.pem --ssl-key /etc/letsencrypt/live/$Domain/privkey.pem bash -c "npx mudslide login -c /var/go/.local/share/mudslide" bash >/dev/null 2>&1 &
    else
        echo "http://root:$Password@$ServerIP:50000"
        sudo nohup ttyd -p 50000 --credential root:$Password bash -c "npx mudslide login -c /var/go/.local/share/mudslide" bash >/dev/null 2>&1 &
    fi

    exit 1

fi

if [ "$1" = "login" ]; then

    Wait3Min=$((TimeStamp + 120))
    echo "$Wait3Min" | sudo tee /usr/local/goadmio/tmp/wa.db >/dev/null

    sudo mkdir -p /var/go/.local/share/mudslide
    npx mudslide logout -c /var/go/.local/share/mudslide
    npx mudslide login -c /var/go/.local/share/mudslide
    exit 1
fi

if [ "$1" = "logout" ]; then

    if [ "$2" != "" ]; then
        sudo rm -rf /var/go/wa/$2
    fi

    exit 1

fi

TimeStamp=$(date +'%s')

# Add Folder Names to Array
FolderArray=("/var/go/wa/"*)
FolderArray=($(shuf -e "${FolderArray[@]}"))

Sent=0
N=0

DeviceNo=$(ls /var/go/wa | wc -l)

if [ "$DeviceNo" -eq 0 ]; then

    echo "No devices are logged in"
    exit 1

fi

SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT CONCAT(ID,'|',Mobile,'|',Message) from $DBName.WA where TimeStamp<$TimeStamp order by ID limit 15;")
while read -r Result; do

    IFS='|' read -r -a Row <<<"$Result"

    ID="${Row[0]}"
    Mobile="${Row[1]}"
    Message="${Row[2]}"

    ID=$(printf "%.0f" "$ID")

    Mobile=$(echo "$Mobile" | sed "s/[^0-9]//g")

    if [[ "$ID" -gt 0 ]]; then

        if [[ "$Mobile" = 0* ]] || [[ "${#Mobile}" -lt 10 ]]; then

            echo "Invalid mobile number $Mobile"
            sudo mariadb -e "DELETE FROM $DBName.WA WHERE ID='$ID';"

        else

            Device=""

            # Rotate Folders
            Folder="${FolderArray[0]}"
            FolderArray=("${FolderArray[@]:1}")
            FolderArray+=("$Folder")

            if sudo test -d "$Folder" ; then

                Check=$(npx mudslide send $Mobile "$Message" -c $Folder | sed '/awaiting/d')

                # Try Again
                if [ "$Check" = "" ]; then
                    Check=$(npx mudslide send $Mobile "$Message" -c $Folder | sed '/awaiting/d')
                fi

                if [ "$Check" = "" ]; then

                    Device="$Folder"

                    if sudo test -f $Folder/failed ; then
                        echo "$Folder (Failed)"
                        sudo sed -i 's/[0-9]\+/echo $((& + 1))/e' $Folder/failed
                    else
                        echo "0" >$Folder/failed
                    fi

                    Failed=$(<$Folder/failed)
                    if [[ "$Failed" -gt "10" ]]; then
                        sudo rm -rf $Folder
                    fi

                elif [[ "$Check" = *"error"* ]] || [[ "$Check" != *"Done"* ]]; then

                    Device="$Folder"

                    if sudo test -f $Folder/failed ; then
                        echo "$Folder (Failed)"
                        sudo sed -i 's/[0-9]\+/echo $((& + 1))/e' $Folder/failed
                    else
                        echo "0" >$Folder/failed
                    fi

                    Failed=$(<$Folder/failed)
                    if [[ "$Failed" -gt "10" ]]; then
                        sudo rm -rf $Folder
                    fi

                else

                    N=$(($N + 1))

                    Sent=1

                    if [ "$N" -eq "1" ]; then
                        echo "$TimeStamp" | sudo tee /usr/local/goadmio/tmp/wa.db >/dev/null
                    fi

                    echo "Sending \"$Message\" To $Mobile (From $Folder)..."
                    sudo mariadb -e "DELETE FROM $DBName.WA WHERE ID='$ID';"

                    echo "0" >$Folder/failed

                    sleep 3

                fi

            fi

            if [ "$Device" != "" ] && [[ "$Err" -eq "0" ]]; then

                Err=1

                sudo /go/sendmail "WhatsApp Linked Device Logged Out ($Device)" "WhatsApp device not logged in ($ServerIP)" "Linked Device"
                sudo /go/sendwhatsapp "*WhatsApp Linked Device Logged Out ($Device)*\n\nWhatsApp device not logged in ($ServerIP)" "Linked Device"

            fi

        fi

    fi

done <<<"$SQL"

if [ "$N" -eq "0" ] || [ "$Sent" -eq "1" ]; then
    sudo rm -rf /usr/local/goadmio/tmp/wa.db
fi
