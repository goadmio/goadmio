#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 $3 '********' $5 >>/var/log/go/$(basename "$0").log

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Domain=$1
Name=$2
User=$3
Pass=$4
Source=$5

TimeStamp=$(date +'%s')

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ $# -eq 0 ]; then

    exit 1

fi

if [ "$User" = "root" ] || [ "$User" = "go" ] || [ "$User" = "mysql" ] || [ "$User" = "horde" ] || [ "$User" = "roundcube" ]; then

    echo "MYSQL: MySQL Database Username $User already exists."
    exit 1

fi

DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")
if [[ ! "$DomainExists" = "$Domain" ]]; then
    echo "Account Domain $Domain not exists"
    exit 1
fi

DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
if [ "$Name" = "$DatabaseExists" ]; then
    echo "Database '$Name' already exists."
    exit 1
fi

sudo /go/mysql $Domain $Name $User $Pass

echo "Exporting Database $Source..."
sudo mariadb-dump --skip-lock-tables -uroot -p$MySQLRootPassword $Source | pv -n >/usr/local/goadmio/tmp/$Name.sql
echo "99"

echo "Importing Database $Source to $Name..."
pv /usr/local/goadmio/tmp/$Name.sql -n | mariadb -uroot -p$MySQLRootPassword $Name

echo "Database import completed successfully..."
echo "100"

sudo rm -rf /usr/local/goadmio/tmp/$Name.sql

# Change default MySQL Password (All Databases for this Domain)
sudo /go/phpmyadmin $Domain
