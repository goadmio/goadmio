#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Timezone=$1

if [ $# -eq 0 ]; then

    # Auto Detect Timezone
    MyIP=$(last | head -n 1 | awk '{ print $3}')
    sudo curl -s -o /usr/local/goadmio/tmp/ip.info https://ipinfo.io/$MyIP
    sudo grep -oP 'timrzone="\K[^"]+' /usr/local/goadmio/tmp/ip.info
    Country=$(sudo grep -oP '"country": "\K[^"]+' /usr/local/goadmio/tmp/ip.info)
    Timezone=$(sudo grep -oP '"timezone": "\K[^"]+' /usr/local/goadmio/tmp/ip.info)

    if [[ "$Timezone" = *"/"* ]]; then

        echo "Country: $Country"
        echo "Timezone: $Timezone"

        if sudo test ! -f "/etc/country" ; then
            echo "$Country" | sudo tee /etc/country >/dev/null
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/country.db "UPDATE Country SET Whitelist='1' where Code='$Country';"
        fi

    else

        echo "Can't set time zone automatically."
        exit 1

    fi

fi

# Replace / with \/
PHPTimezone=$(echo $Timezone | sed -e 's/\//\\\//g')

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    File="/etc/php.ini"
    cd /etc/opt/remi
    for Version in *; do
        File="$File|/etc/opt/remi/$Version/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

elif [ "$OS" = "Debian" ]; then

    File="/etc/php.ini"
    cd /etc/php
    for Version in *; do
        File="$File|/etc/php/$Version/fpm/php.ini|/etc/php/$Version/cli/php.ini|/etc/php/$Version/apache2/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

elif [ "$OS" = "Ubuntu" ]; then

    File="/etc/php.ini"
    cd /etc/php
    for Version in *; do
        File="$File|/etc/php/$Version/fpm/php.ini|/etc/php/$Version/cli/php.ini|/etc/php/$Version/apache2/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

else

    echo "Unknown operating system."
    exit

fi

FileArray=$(echo $File | tr "|" "\n")

for File in $FileArray; do

    if sudo test -f "$File" ; then

        # GET Line Code that Start With date.timezone
        Code=$(sudo grep "^date.timezone" $File)

        if [ "$Code" = "" ]; then
            Code=$(sudo grep "^;date.timezone" $File)
        fi

        # Replace / with \/
        Code=$(echo $Code | sed -e 's/\//\\\//g')

        if grep -q "^date.timezone" $File; then
            # Edit
            sudo sed -i "s/$Code/date.timezone = \"$PHPTimezone\"/g" $File
        else
            # Add
            echo "date.timezone = \"$Timezone\"" >>$File
        fi

    fi

done

# Linux Timezone
sudo timedatectl set-timezone $Timezone

# Update Go pool timezone
sudo /go/php-fpm go go

# Update Timezone data
sudo /go/dst

echo "Local timezone has been set to $Timezone."

sudo /go/fpm --reload "| Executed by $(basename "$0")"
