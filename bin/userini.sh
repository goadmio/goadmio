#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # CentOS
    File="/etc/php.ini"
    cd /etc/opt/remi
    for Version in *; do
        File="$File|/etc/opt/remi/$Version/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

elif [ "$OS" = "Debian" ]; then

    # Ubuntu
    File="/etc/php.ini"
    cd /etc/php
    for Version in *; do
        File="$File|/etc/php/$Version/fpm/php.ini|/etc/php/$Version/cli/php.ini|/etc/php/$Version/apache2/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

elif [ "$OS" = "Ubuntu" ]; then

    # Ubuntu
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

        sudo sed -i 's/;user_ini.filename = ".user.ini"//g' $File
        sudo sed -i 's/;user_ini.filename =/user_ini.filename =/g' $File

    fi

done
