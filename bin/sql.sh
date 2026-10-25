#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Domain=$1
Name=$2
User=$3
Pass=$4
Database=$5

Pass=$(echo "${Pass//\[DollarSign\]/$}")
Pass=$(echo "${Pass//\[AndSign\]/&}")
Pass=$(echo "${Pass//\[EqualSign\]/=}")
Pass=$(echo "${Pass//\[HashSign\]/#}")

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

TimeStamp=$(date +'%s')

if [ $# -eq 0 ]; then

    exit 1

fi

if [ "$Name" = "go" ] || [ "$Name" = "mysql" ] || [ "$Name" = "roundcube" ]; then

    echo "Database already exists."
    exit 1

fi

if [ "$User" = "root" ] || [ "$User" = "go" ] || [ "$User" = "mysql" ]; then

    echo "Username $User already exists."
    exit 1

fi

DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain' and Trash=0")
if [[ ! "$DomainExists" = "$Domain" ]]; then
    echo "Account $Domain not exists"
    exit 1
fi

DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
if [ "$Name" = "$DatabaseExists" ]; then
    echo "Database '$Name' already exists."
    exit 1
fi

sudo /go/mysql $Domain $Name $User $Pass

sudo mariadb -uroot -p$MySQLRootPassword $Name <$Database

echo "Database $Database imported successfully."
