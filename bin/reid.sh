#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Name=$1
Table=$2

E=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select count(*) from $Name.$Table;" 2>/dev/null)
if [ $? -ne "0" ]; then
    # MySQL error
    echo "Table $Name.$Table doesn't exist."
    exit 1
fi

N=0
Columns=""

SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='$Name' AND TABLE_NAME='$Table';")
for Column in $SQL; do

    N=$(($N + 1))

    if [ "$N" -eq 1 ]; then

        ColumnID="$Column"

    else

        if [ "$Columns" = "" ]; then

            Columns="$Column"

        else

            Columns="$Columns,$Column"

        fi

    fi

done

echo "Re-sorting $ColumnID Column in $Table ($Name Database)..."

sudo mariadb -uroot -p$MySQLRootPassword -e "ALTER TABLE $Name.$Table DROP $ColumnID;"
sudo mariadb -uroot -p$MySQLRootPassword -e "ALTER TABLE $Name.$Table ADD $ColumnID INT NOT NULL AUTO_INCREMENT FIRST ,ADD PRIMARY KEY ($ColumnID);"
