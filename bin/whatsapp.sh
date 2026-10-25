#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if sudo test -f "/etc/wa" ; then
    DBName=$(</etc/wa)
else
    DBName="crm"
fi

if [ $# -eq 0 ]; then

    cd /whatsapp
    for Mobile in *; do

        Session=$(sudo find /whatsapp/$Mobile -type f | wc -l)

        if [ "$Session" -lt 10 ]; then
            if [[ "$Mobile" =~ ^[0-9]+$ ]]; then
                sudo rm -rf /whatsapp/$Mobile
            fi
        fi

    done

    # Move Login Devices
    if sudo test -d /usr/local/goadmio/whatsapp ; then

        cd /usr/local/goadmio/whatsapp
        for Mobile in *; do

            LoginNumber=$(timeout 7s npx mudslide me -c /usr/local/goadmio/whatsapp/$Mobile | grep -oP "\d{10,15}:" | sed "s/[^0-9]//g")

            if [[ "$LoginNumber" =~ ^[0-9]+$ ]]; then

                sudo mkdir -p /whatsapp/$LoginNumber
                sudo rm -rf /whatsapp/$LoginNumber/*
                sudo mv /usr/local/goadmio/whatsapp/$Mobile/* /whatsapp/$LoginNumber/
                sudo rm -rf /usr/local/goadmio/whatsapp/$Mobile

                echo "0" >/whatsapp/$LoginNumber/failed

            else
                sudo rm -rf /usr/local/goadmio/whatsapp/$Mobile
            fi

        done

    fi

    H=$(date +%H)

    if [[ "$H" -lt 10 ]] || [[ "$H" -ge 22 ]]; then

        sudo mariadb -uroot -p$MySQLRootPassword -N -e "UPDATE $DBName.Member SET Send=0;"

        echo "Script can only run between 10 AM - 10 PM"
        exit 1
    fi

    sudo /go/send

    exit 1

fi

if [ $# -eq 1 ]; then

    Mobile=$1
    Mobile=$(echo "$Mobile" | sed 's/[^0-9]*//g')

    if [ "$Mobile" = "" ]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET AdminMobile=''"
        echo "Mobile Deleted."
        exit 1

    fi

    if [ ${#Mobile} -lt 10 ]; then
        echo "Invalid Mobile $1."
        exit 1
    fi

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET AdminMobile='$Mobile'"

    echo "Admin Whatsapp mobile number has been changed to +${Mobile}"

    exit 1

fi

Domain=$1
Mobile=$2
Password=$3
Mobile=$(echo "$Mobile" | sed 's/[^0-9]*//g')

if [ ${#Mobile} -lt 10 ]; then
    echo "Invalid Mobile."
    exit 1
fi

Port="5${Mobile: -4}"

PID=$(lsof -i :$Port | tail -n 1 | awk {' print $2 '})

if [ "$PID" != "" ]; then
    lsof -i :$Port | awk 'NR!=1 {print $2}' | xargs kill -9
fi

if [ ! ${#Password} -eq 16 ]; then
    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
fi

SSH=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSH from Config where ConfigID=1")
SSHFontSize=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSHFontSize from Config where ConfigID=1")

if [ "$SSH" = "White" ]; then

    Style="-t fontSize=$SSHFontSize -t theme={\"background\":\"#FFFFFF\",\"foreground\":\"#000000\"}"

elif [ "$SSH" = "Blue" ]; then

    Style="-t fontSize=$SSHFontSize -t theme={\"background\":\"#0000A0\",\"foreground\":\"#FFFFFF\"}"

elif [ "$SSH" = "Gray" ]; then

    Style="-t fontSize=$SSHFontSize -t theme={\"background\":\"Gray\",\"foreground\":\"#FFFFFF\"}"

else

    Style="-t fontSize=$SSHFontSize -t theme={\"background\":\"#000000\",\"foreground\":\"#FFFFFF\"}"

fi

LoginNumber=$(timeout 7s npx mudslide me -c /whatsapp/$Mobile | grep -oP "\d{10,15}:" | sed "s/[^0-9]//g")

if [ "$LoginNumber" = "$Mobile" ]; then

    echo "Already logged in."

else

    sudo rm -rf /usr/local/goadmio/whatsapp/$Mobile
    sudo mkdir -p /usr/local/goadmio/whatsapp/$Mobile

    if sudo test -f /etc/letsencrypt/live/$Domain/privkey.pem ; then

        echo "https://root:$Password@$Domain:$Port"
        sudo nohup ttyd -p $Port $Style --credential root:$Password --ssl --ssl-cert /etc/letsencrypt/live/$Domain/fullchain.pem --ssl-key /etc/letsencrypt/live/$Domain/privkey.pem bash -c "npx mudslide login -c /usr/local/goadmio/whatsapp/$Mobile" bash >/dev/null 2>&1 &

    else

        echo "http://root:$Password@$ServerIP:$Port"
        sudo nohup ttyd -p $Port $Style --credential root:$Password bash -c "npx mudslide login -c /usr/local/goadmio/whatsapp/$Mobile" bash >/dev/null 2>&1 &

    fi

fi
