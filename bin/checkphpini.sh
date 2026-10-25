#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    Dir="/etc"
    cd /etc/opt/remi
    for Version in *; do
        Dir="$Dir|/etc/opt/remi/$Version"
    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    Dir="/etc"
    cd /etc/php
    for Version in *; do
        Dir="$Dir|/etc/php/$Version/fpm|/etc/php/$Version/cli|/etc/php/$Version/apache2"
    done

fi

DirArray=$(echo $Dir | tr "|" "\n")

for Dir in $DirArray; do

    if sudo test -d "$Dir" ; then

        if sudo test -f "$Dir/php.ini" ; then

            Error=$(php -c $Dir/php.ini -i 2>&1 | grep " on line ")
            LineNo=$(echo "$Error" | grep -oP 'line \K\d+')
            File=$(echo "$Error" | grep -oP 'in \K\/[a-z0-9\/\.]+')

            if [ ! "$LineNo" = "" ]; then

                echo "$Error"

                LineCode=$(sed -n "${LineNo}p" $File)

                # Delete Line
                sudo sed -i "${LineNo}d" $File

                echo "Line ${LineNo} has been removed."

            fi

        fi

    fi

done
