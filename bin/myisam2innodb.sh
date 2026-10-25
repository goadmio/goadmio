#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Name=$1
Table=$2

if [ $# -eq 0 ]; then
    exit 1
fi

if [ "$1" = "all" ]; then

    SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT schema_name FROM information_schema.schemata where schema_name!='performance_schema' and schema_name!='information_schema' and schema_name!='sys';")
    for Database in $SQL; do
        printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
        echo "Converting Database $Database to InnoDB..."
        printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

        sudo /go/myisam2innodb $Database
    done

    exit 1

fi

if [ "$Table" = "" ]; then

    sudo mariadb -uroot -p$MySQLRootPassword -N -e "select table_name from information_schema.tables where TABLE_SCHEMA='$Name' AND ENGINE='MyISAM';" | sudo tee /usr/local/goadmio/$Name.txt >/dev/null

    File="/usr/local/goadmio/$Name.txt"
    while IFS= read Table; do

        echo "Converting Table '$Table' to InnoDB..."

        sudo mariadb -e "ALTER TABLE $Name.$Table ENGINE=InnoDB"

    done <"$File"

else

    echo "Converting Table '$Table' to InnoDB..."

    sudo mariadb -e "ALTER TABLE $Name.$Table ENGINE=InnoDB"

fi
