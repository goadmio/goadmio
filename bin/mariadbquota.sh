#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

MAX_USER_CONNECTIONS=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mariadb.db "select MAX_USER_CONNECTIONS from MariaDB where MariaDBID='1'")
MAX_QUESTIONS=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mariadb.db "select MAX_QUESTIONS from MariaDB where MariaDBID='1'")
MAX_UPDATES=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mariadb.db "select MAX_UPDATES from MariaDB where MariaDBID='1'")

SQL=$(sudo mariadb -N -uroot -p$MySQLRootPassword -e "SELECT user FROM mysql.user WHERE user NOT IN ('root','mysql','mariadb.sys','mysql.session','mysql.sys','PUBLIC')")

for USER in $SQL; do

    sudo mariadb -uroot -p$MySQLRootPassword -e "ALTER USER '$USER'@'localhost' WITH MAX_USER_CONNECTIONS $MAX_USER_CONNECTIONS;"
    sudo mariadb -uroot -p$MySQLRootPassword -e "ALTER USER '$USER'@'localhost' WITH MAX_QUERIES_PER_HOUR $MAX_QUESTIONS;"
    sudo mariadb -uroot -p$MySQLRootPassword -e "ALTER USER '$USER'@'localhost' WITH MAX_UPDATES_PER_HOUR $MAX_UPDATES;"

done

sudo /go/my
