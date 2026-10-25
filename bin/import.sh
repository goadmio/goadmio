#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

File=$1
Database=$2

sudo cat $File | grep -oP '(?<=INSERT).*(?=VALUES)' | sed 's/ IGNORE / /' | sed 's/[`"){}]//g' | awk '{$1=$1};1' | sed 's/^INTO //' | sed -E 's/^([a-zA-Z0-9_]+)[[:space:]]+([a-zA-Z0-9_]+)/\1/' | sed 's/ //g' | sed 's/(/|/g' | sed 's/,/\|/g' | sort | uniq >/usr/local/goadmio/tmp/$Database.db

C=$(sudo cat /usr/local/goadmio/tmp/$Database.db | wc -l)

while read Line; do

    T=0

    ID=$(echo "$Line" | cut -d'|' -f2)

    IFS='|' read -ra ColumnArray <<<"$Line"
    for Name in "${ColumnArray[@]}"; do

        if [ "$T" -eq "0" ]; then

            TableName="$Name"

            N=$(($N + 1))

            echo -ne "\r[$N/$C] Checking Table $TableName                                                  "

            sudo mariadb -s -e "CREATE TABLE $Database.$TableName ($ID INT AUTO_INCREMENT PRIMARY KEY)" >/dev/null 2>&1

        else

            sudo mariadb -s -e "ALTER TABLE $Database.$TableName ADD $Name TEXT;" >/dev/null 2>&1

        fi

        T=$(($T + 1))

    done

done </usr/local/goadmio/tmp/$Database.db

pv $File | mariadb --force -uroot -p"$MySQLRootPassword" $Database 2>/dev/null
