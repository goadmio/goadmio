#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") '********' >>/var/log/go/$(basename "$0").log

Password=$1

Password=$(echo "${Password//\[DollarSign\]/$}")
Password=$(echo "${Password//\[AndSign\]/&}")
Password=$(echo "${Password//\[EqualSign\]/=}")
Password=$(echo "${Password//\[HashSign\]/#}")

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ $# -eq 0 ]; then

    read -p "Password: " -e Password

fi

sudo rm -rf /root/.my.cnf

sudo mariadb -uroot -p$MySQLRootPassword -e "set password = password('$Password');"

echo "MySQL ROOT password has been changed successfully."

# GET Line Code that Contain DBPass
Code=$(sudo grep "DBPass" /usr/local/goadmio/include/config/config.php)
# Replace Line Code with New Line Code
sudo sed -i "s/$Code/\$DBPass=\"$Password\";/g" /usr/local/goadmio/include/config/config.php

# Create /root/.my.cnf
echo "[client]" >/root/.my.cnf
echo "user=root" >>/root/.my.cnf
echo "password=$Password" >>/root/.my.cnf
echo "[mysqld]" >>/root/.my.cnf
