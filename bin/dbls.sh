#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $*" | sudo tee -a /var/log/go/$(basename "$0").log >/dev/null

DBName=$1
TableName=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ $# -eq 1 ]; then

    sudo mariadb-dump -uroot -p"$MySQLRootPassword" --no-create-info "$DBName" | grep -oE '[A-Za-z0-9_.-]+\.([A-Za-z0-9_-]){1,4}' | grep -v '\.\.' | grep -vE '\.[0-9]{1,4}$' | sort -u

    sudo mariadb-dump -uroot -p"$MySQLRootPassword" --no-create-info "$DBName" | grep -oE '\b[a-f0-9]{32}\b' | sort -u

elif [ $# -eq 2 ]; then

    sudo mariadb-dump -uroot -p"$MySQLRootPassword" --no-create-info "$DBName" | grep -oE '[A-Za-z0-9_.-]+\.([A-Za-z0-9_-]){1,4}' | grep -v '\.\.' | grep -vE '\.[0-9]{1,4}$' | sort -u >/tmp/${DBName}.file
    sudo mariadb-dump -uroot -p"$MySQLRootPassword" --no-create-info "$DBName" | grep -oE '\b[a-f0-9]{32}\b' | sort -u >>/tmp/${DBName}.file

    sudo mariadb -uroot -p"$MySQLRootPassword" -e "CREATE TABLE IF NOT EXISTS $DBName.$TableName (ID INT AUTO_INCREMENT PRIMARY KEY,File CHAR(255) NOT NULL DEFAULT '' UNIQUE,Download INT DEFAULT '0',TimeStamp INT DEFAULT UNIX_TIMESTAMP()) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    sudo mariadb -uroot -p"$MySQLRootPassword" -e "LOAD DATA INFILE '/tmp/${DBName}.file' IGNORE INTO TABLE $DBName.$TableName LINES TERMINATED BY '\n' (File);"

fi
