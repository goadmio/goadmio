#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Name=$1
Table=$2

if [ $# -eq 0 ]; then
    read -p "Database Name: " -e Name
fi

if [ "$Table" = "" ]; then

    sudo mariadb -uroot -p$MySQLRootPassword -N -e "select table_name from information_schema.tables where TABLE_SCHEMA='$Name' AND ENGINE='InnoDB';" | sudo tee /usr/local/goadmio/$Name.txt >/dev/null

    File="/usr/local/goadmio/$Name.txt"
    while IFS= read Table; do

        echo "Converting Table '$Table' to MyISAM..."

        sudo mariadb -e "ALTER TABLE $Name.$Table ENGINE=MyISAM"

    done <"$File"

else

    echo "Converting Table '$Table' to MyISAM..."

    sudo mariadb -e "ALTER TABLE $Name.$Table ENGINE=MyISAM"

fi
