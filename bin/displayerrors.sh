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

        Value=$(sudo grep -E "^display_errors*=*" $File | head -1 | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        if [ "${1,,}" = "return" ]; then

            echo "$Value"
            exit 1

        fi

        if [ $# -eq 0 ] || [[ "$1" = --* ]]; then
            Value="On"
        else
            Value=$@
        fi

        if grep -q "^[[:space:]]*display_errors[[:space:]]*=" $File; then
            sudo sed -i "s/^[[:space:]]*display_errors[[:space:]]*=.*/display_errors = $Value/" $File
        else
            echo "display_errors = $Value" >>$File
        fi

    fi

done

echo "Display Errors updated successfully."

At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
if [[ ! "$At" = *"fpm reload"* ]]; then
    echo "/go/fpm reload" | at now + 1 minute >/dev/null 2>&1
fi
