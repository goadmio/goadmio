#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/phpmyadmin "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [[ $(free -m | grep Mem | awk '{ print $2 }') -lt "512" ]]; then

    echo "phpMyAdmin requires at least 0.5 GB of RAM to install."
    exit 1

fi

source /go/function

Domain=$1

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [[ $# -eq 0 ]] || [[ "$@" = *"--install"* ]]; then

    Version=$1

    if [ "$Version" = "" ]; then
        Version="5.2.3"
    fi

    ProgressBar "Installing phpMyAdmin $Version"

    sudo rm -rf /usr/local/goadmio/home/go/phpmyadmin
    sudo mkdir -p /usr/local/goadmio/home/go

    sudo curl -s -L "https://files.phpmyadmin.net/phpMyAdmin/$Version/phpMyAdmin-$Version-all-languages.tar.gz" | sudo tee /usr/local/goadmio/home/go/phpmyadmin-latest.tar.gz >/dev/null
    cd /usr/local/goadmio/home/go
    sudo tar -zxf phpmyadmin-latest.tar.gz
    sudo rm -f /usr/local/goadmio/home/go/phpmyadmin-latest.tar.gz
    sudo mv phpMyAdmin-* phpmyadmin
    sudo cp /usr/local/goadmio/home/go/phpmyadmin/config.sample.inc.php /usr/local/goadmio/home/go/phpmyadmin/config.inc.php

    sudo mkdir /usr/local/goadmio/home/go/phpmyadmin/tmp
    sudo chmod 777 /usr/local/goadmio/home/go/phpmyadmin/tmp

    sudo sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/if \(\$_COOKIE\['CookiesMySQLUsername']\)\n\{\n\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = 'config';\n\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';\n\$cfg\['Servers'\]\[\$i\]\['user'\] = \$_COOKIE\['CookiesMySQLUsername'\];\n\$cfg\['Servers'\]\[\$i\]\['password'\] = \$_COOKIE\['CookiesMySQLPassword'\];\n\$cfg\['Servers'\]\[\$i\]\['LogoutURL'\] = 'logout.php';\n\}/" /usr/local/goadmio/home/go/phpmyadmin/config.inc.php

    echo "<?php" | sudo tee /usr/local/goadmio/home/go/phpmyadmin/logout.php >/dev/null
    echo "unset (\$_COOKIE['CookiesMySQLUsername']);" | sudo tee -a /usr/local/goadmio/home/go/phpmyadmin/logout.php >/dev/null
    echo "unset (\$_COOKIE['CookiesMySQLPassword']);" | sudo tee -a /usr/local/goadmio/home/go/phpmyadmin/logout.php >/dev/null
    echo 'setcookie ("CookiesMySQLUsername","",time() - (86400 * 30), "/");' >>/usr/local/goadmio/home/go/phpmyadmin/logout.php
    echo 'setcookie ("CookiesMySQLPassword","",time() - (86400 * 30), "/");' >>/usr/local/goadmio/home/go/phpmyadmin/logout.php
    echo 'header("Location: index.php");' >>/usr/local/goadmio/home/go/phpmyadmin/logout.php
    echo '?>' >>/usr/local/goadmio/home/go/phpmyadmin/logout.php

    sudo mariadb -uroot -p$MySQLRootPassword -e "CREATE DATABASE IF NOT EXISTS phpmyadmin;"
    sudo mariadb -uroot -p$MySQLRootPassword phpmyadmin </usr/local/goadmio/home/go/phpmyadmin/sql/create_tables.sql

    sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MySQLRootPassword';"

elif [ "$1" = "all" ]; then

    cd /home
    for Domain in *; do

        if sudo test -d /home/$Domain/www ; then

            sudo /go/phpmyadmin $Domain

        fi

    done

else

    Salt=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Salt from Site where Domain='$Domain'")

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Domain='$Domain'")
    for Name in $SQL; do

        sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT ALL PRIVILEGES ON $Name.* TO '$Domain'@'localhost' IDENTIFIED BY '$Salt';"

    done

fi

cd /tmp
