#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

Extension=$1
Action=$2

if [ $# -eq 0 ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/extension.db "DELETE FROM Extension"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        PHPVersion=$(/go/listphp | tail -n 1 | sed 's/\.//g')
        PHPVersion="php${PHPVersion}"
        Module=$(dnf search $PHPVersion-* | grep " : " | sed "s/$PHPVersion-php-//g" | sed 's/.x86_64//g' | sed 's/pecl-//g' | sed 's/ : /|/g')

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        PHPVersion=$(/go/listphp | tail -n 1)
        PHPVersion="php${PHPVersion}"
        Module=$(apt-cache search $PHPVersion-* | grep " - " | sed "s/$PHPVersion-//g" | sed 's/pecl-//g' | sed 's/ - /|/g')

    fi

    OUTPUT="Number|Module|Description"
    OUTPUT="$OUTPUT\n------|------|-----------"

    while read Line; do

        IFS='|' read -r -a Array <<<"$Line"
        Extension="${Array[0]}"
        Description=$(echo "${Array[1]}" | sed "s/'//g")

        if [[ ! "$Extension" = *"-"* ]]; then

            N=$(($N + 1))

            Name="$Extension"

            if [ "$Extension" = "curl" ] || [ "$Extension" = "fileinfo" ] || [ "$Extension" = "ftp" ] || [ "$Extension" = "gd" ] || [ "$Extension" = "gmp" ] || [ "$Extension" = "imagick" ] || [ "$Extension" = "imap" ] || [ "$Extension" = "mbstring" ] || [ "$Extension" = "mysql" ] || [ "$Extension" = "pdo" ] || [ "$Extension" = "pgsql" ] || [ "$Extension" = "pdo_sqlite" ] || [ "$Extension" = "sodium" ] || [ "$Extension" = "ssh2" ] || [ "$Extension" = "sqlite3" ]; then
                Required="1"
            else
                Required="0"
            fi

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/extension.db "INSERT INTO Extension (Name,Extension,Required,Description) VALUES ('$Name','$Extension','$Required','$Description')"

            OUTPUT="$OUTPUT\n$N|$Extension|$Description"

        fi

    done <<<"$Module"

    echo -ne $OUTPUT | column -t -s "|"

    exit 1

fi

TimeStamp=$(date +'%s')
if sudo test -f /usr/local/goadmio/db/lock.db ; then
    Lock=$(</usr/local/goadmio/db/lock.db)
else
    Lock=0
fi

LockStamp=$(($TimeStamp - $Lock))
if [ "$LockStamp" -lt "600" ]; then
    echo "Another instance is running"
    exit 1
fi
echo "$TimeStamp" | sudo tee /usr/local/goadmio/db/lock.db >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Default PHP
    if [ "$Action" = "0" ] || [ "$Action" = "2" ] || [ "$Action" = "remove" ]; then
        sudo dnf -y remove php-$Extension
    else
        sudo dnf -y install php-$Extension
    fi

    cd /etc/opt/remi
    for Version in *; do

        if [ "$Action" = "0" ] || [ "$Action" = "2" ] || [ "$Action" = "remove" ]; then
            sudo dnf -y remove $Version-php-$Extension
        else
            sudo dnf -y install $Version-php-$Extension
        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # Default PHP
    if [ "$Action" = "0" ] || [ "$Action" = "2" ] || [ "$Action" = "remove" ]; then
        sudo apt -y remove php-$Extension
    else
        sudo apt -y install php-$Extension
    fi

    cd /etc/php
    for Version in *; do

        if [ "$Action" = "0" ] || [ "$Action" = "2" ] || [ "$Action" = "remove" ]; then
            sudo apt -y remove php$Version-$Extension
        else
            sudo apt -y install php$Version-$Extension
        fi

    done

fi

sudo rm -rf /usr/local/goadmio/db/lock.db

At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
if [[ ! "$At" = *"fpm reload"* ]]; then
    echo "/go/fpm reload" | at now + 1 minute >/dev/null 2>&1
fi
