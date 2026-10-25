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

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    File="/etc/php.ini"
    cd /etc/php
    for Version in *; do
        File="$File|/etc/php/$Version/fpm/php.ini|/etc/php/$Version/cli/php.ini|/etc/php/$Version/apache2/php.ini"
    done

    FileArray=$(echo $File | tr "|" "\n")

fi

FileArray=$(echo $File | tr "|" "\n")

for File in $FileArray; do

    if sudo test -f "$File" ; then

        Code=$(sudo grep "^max_input_time =" $File)

        if [ "$Code" = "" ]; then
            Code=$(sudo grep "max_input_time=" $File)

            Value=$(echo $Code | sed -e 's/max_input_time=//g')
        else
            Value=$(echo $Code | sed -e 's/max_input_time =//g')
        fi

        # TRIM String
        Value=$(echo $Value | sed -e 's/^[ \t]*//')

        if [ "${1,,}" = "return" ]; then

            echo "$Value"
            exit 1

        fi

        if [ $# -eq 0 ] || [[ "$1" = --* ]]; then
            Value="600"
        else
            Value=$@
        fi

        if grep "^max_input_time" $File; then
            # Edit
            sudo sed -i "s/max_input_time.*/max_input_time = $Value/g" $File
        else
            # Add
            echo "max_input_time = $Value" >>$File
        fi

    fi

done

echo "Max Input Time updated successfully."

At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
if [[ ! "$At" = *"fpm reload"* ]]; then
    echo "/go/fpm reload" | at now + 1 minute >/dev/null 2>&1
fi
