#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Password=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ $# -eq 0 ]; then

    read -p "Domain: " -e Domain
    read -p "Password: " -e Password

fi

if sudo test ! -d "/home/$Domain" ; then
    echo "Account $Domain not exists."
    exit 1
fi

if sudo test -f "/home/$Domain/www/wp-config.php" ; then

    TablePrefix=$(sudo grep '$table_prefix' /home/$Domain/www/wp-config.php)
    TablePrefix=$(echo $TablePrefix | sed "s/\$table_prefix//g")
    TablePrefix=$(echo $TablePrefix | sed "s/[=;'\"]//g")
    TablePrefix=$(echo $TablePrefix | sed -e 's/^[ \t]*//')
    TablePrefix="${TablePrefix//$'\r'/}"

    WordpressDBName=$(sudo grep "DB_NAME" /home/$Domain/www/wp-config.php)
    WordpressDBName=${WordpressDBName/define/}
    WordpressDBName=${WordpressDBName/DB_NAME/}
    WordpressDBName=${WordpressDBName//(/}
    WordpressDBName=${WordpressDBName//)/}
    WordpressDBName=${WordpressDBName//;/}
    WordpressDBName=${WordpressDBName//,/}
    WordpressDBName=${WordpressDBName//\'/}
    WordpressDBName=$(echo $WordpressDBName | sed -e 's/^[ \t]*//')
    WordpressDBName="${WordpressDBName//$'\r'/}"

    Username=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select user_login from ${WordpressDBName}.${TablePrefix}users where ID='1'")
    Email=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select user_email from ${WordpressDBName}.${TablePrefix}users where ID='1'")

    sudo mariadb -uroot -p$MySQLRootPassword -e "update ${WordpressDBName}.${TablePrefix}users set user_pass='$Password' where ID='1'"

    echo "WordPress Username: $Username"
    echo "WordPress Email: $Email"

    echo "WordPress Password has been modified successfully."

else

    echo "WordPress not installed."

fi
