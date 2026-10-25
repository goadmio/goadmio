#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 $2 $3 '********' $5 $6 >>/var/log/go/$(basename "$0").log

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$1" = "system" ]; then

    sudo /go/my system

    sudo mariadb-install-db --datadir=/var/go/var/lib/mysql --user=mysql
    mariadbd --defaults-file=/var/go/etc/my.cnf >/var/log/go/mariadbd.log 2>&1 &
    sleep 5
    sudo mariadb --socket=/var/go/var/lib/mysql/mysql.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MySQLRootPassword';FLUSH PRIVILEGES;"

    echo "mariadb --port=3307"

    exit 1

fi

Domain=$1
Name=$2
User=$3
Pass=$4
Remote=$5
Action=$6

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [ $# -eq 0 ]; then
    exit 1
fi

TimeStamp=$(date +'%s')

if [ "$User" = "root" ] || [ "$User" = "go" ] || [ "$User" = "mysql" ] || [ "$User" = "horde" ] || [ "$User" = "roundcube" ]; then

    echo "MYSQL: MySQL Database Username $User already exists."
    exit 1

fi

if [ "$Name" = "root" ] || [ "$Name" = "go" ] || [ "$Name" = "mysql" ] || [ "$Name" = "horde" ] || [ "$Name" = "roundcube" ]; then

    echo "MYSQL: MySQL Database Name $Name already exists."
    exit 1

fi

if [ "$Action" = "delete" ]; then

    DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name' and Username='$Username'")

    if [ "$DatabaseExists" = "$Name" ]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "DELETE FROM Mysql where Name='$Name'"

        sudo mariadb -uroot -p$MySQLRootPassword -e "DROP DATABASE $Name"
        echo "Database $Name deleted successfully..."

    fi

elif [ "$Action" = "edit" ]; then

    DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select User from Mysql where Name!='$Name'")
    if [ "$User" = "$DatabaseExists" ]; then
        echo "MYSQL: Username $User already exists."
        exit 1
    fi

    if [ "$Remote" = "1" ]; then

        # Remote connection
        sudo mariadb -uroot -p$MySQLRootPassword -e "DROP USER '$User'@'%';"
        sudo mariadb -uroot -p$MySQLRootPassword -e "CREATE USER '$User'@'%' IDENTIFIED BY '$Pass';"
        sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON $Name.* TO '$User'@'%';"

    else

        # Local connection
        sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON $Name.* TO '$User'@'localhost' IDENTIFIED BY '$Pass';"

    fi

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "UPDATE Mysql SET User='$User',Pass='$Pass' where Name='$Name'"

    echo "Database '$Name' was successfully modified."

else

    DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")
    if [[ ! "$DomainExists" = "$Domain" ]]; then
        echo "MYSQL: Account $Domain not exists"
        exit 1
    fi

    NameExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
    if [ "$Name" = "$NameExists" ]; then
        echo "MYSQL: Database '$Name' already exists."
        exit 1
    fi

    UserExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select User from Mysql where User='$User'")
    if [ "$User" = "$UserExists" ]; then
        echo "MYSQL: Username '$User' already exists."
        exit 1
    fi

    sudo mariadb -uroot -p$MySQLRootPassword -e "CREATE DATABASE IF NOT EXISTS $Name"

    if [ "$Remote" = "1" ]; then

        # Remote connection
        sudo mariadb -uroot -p$MySQLRootPassword -e "CREATE USER '$User'@'%' IDENTIFIED BY '$Pass';"
        sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON $Name.* TO '$User'@'%';"

    else

        # Local connection
        if [[ "$Pass" =~ ^\*[A-F0-9]{40}$ ]]; then

            # MySQL Encrypted Password
            # sudo mariadb -uroot -p$MySQLRootPassword -e   "GRANT USAGE ON $Name.* TO '$User'@'localhost' IDENTIFIED BY PASSWORD '$Pass';"
            sudo mariadb -uroot -p"$MySQLRootPassword" -e "ALTER USER '$User'@'localhost' IDENTIFIED BY PASSWORD '$Pass';"

        else

            sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON $Name.* TO '$User'@'localhost' IDENTIFIED BY '$Pass';"

        fi

    fi

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "INSERT INTO Mysql (Name,User,Pass,Domain,Username,TimeStamp) VALUES ('$Name','$User','$Pass','$Domain','$Username','$TimeStamp')"

    # Change default MySQL Password (All Databases for this Domain)
    sudo /go/phpmyadmin $Domain

    if [ "$Remote" = "1" ]; then

        echo "Database '$Name' created successfully."
        echo ""
        echo "MySQL Hostname: $ServerIP"
        echo "MySQL Database Name: $Name"
        echo "MySQL Database Username: $User"
        echo "MySQL Database Password: $Pass"

    else

        echo "Database '$Name' created successfully."
        echo ""
        echo "MySQL Hostname: localhost"
        echo "MySQL Database Name: $Name"
        echo "MySQL Database Username: $User"
        echo "MySQL Database Password: $Pass"

    fi

fi
