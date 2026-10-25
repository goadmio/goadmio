#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") '********' >>/var/log/go/$(basename "$0").log

Password=$1

if [ $# -eq 0 ]; then
    exit 1
fi

Hostname=$(</etc/hostname)
OS=$(</usr/local/goadmio/linux/os.db)

sudo rm -rf /root/.my.cnf

sudo systemctl stop mariadb
sudo pkill -9 mysqld 2>/dev/null
sudo pkill -9 mariadbd 2>/dev/null

mariadbd-safe --skip-grant-tables --skip-networking >res 2>&1 &

sleep 5

sudo mariadb -u root -e "FLUSH PRIVILEGES;ALTER USER 'root'@'localhost' IDENTIFIED BY '$Password';FLUSH PRIVILEGES;"

if sudo test -f "/var/run/mysqld/mysqld.pid" ; then
    PID=$(</var/run/mysqld/mysqld.pid)
    sudo kill $PID
fi

if sudo test -f "/var/run/mariadb/mariadb.pid" ; then
    PID=$(</var/run/mariadb/mariadb.pid)
    sudo kill $PID
fi

cd /var/lib/mysql
for File in *; do

    if [[ "$File" = *".pid" ]]; then

        PID=$(</var/lib/mysql/$File)
        sudo kill $PID

    fi

done

sudo systemctl restart mariadb

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
