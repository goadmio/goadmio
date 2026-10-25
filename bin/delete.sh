#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MESSAGE() {
    String=$(echo -e "$1")

    for ((i = 0; i < $(tput cols); i++)); do

        if [ "$i" -eq "0" ]; then
            echo -n "┌"
        elif [ "$i" -eq $(($(tput cols) - 1)) ]; then
            echo -n "┐"
        else
            echo -n '─'
        fi

    done
    echo ""

    while IFS= read -r Line; do

        echo -n "│ "
        echo -n "$Line"
        Length=${#Line}
        for ((i = 0; i < $(($(tput cols) - ($Length + 4))); i++)); do echo -n ' '; done
        echo -n " │"

    done <<<"$String"

    for ((i = 0; i < $(tput cols); i++)); do

        if [ "$i" -eq "0" ]; then
            echo -n "└"
        elif [ "$i" -eq $(($(tput cols) - 1)) ]; then
            echo -n "┘"
        else
            echo -n '─'
        fi

    done

    echo ""

}

Domain=$1
OS=$(</usr/local/goadmio/linux/os.db)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)
Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")

if [[ ! "$DomainExists" = "$Domain" ]] && sudo test ! -d "/home/$Domain/www"; then
    echo "Domain $Domain not exists"
    exit 1
fi

# Immediately delete from GoAdmio interface
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Trash=1 where Domain='$Domain'"

if [[ ! "$@" = *"--force"* ]]; then
    echo "Preparing to delete $Domain..."
    sudo /go/snapshot $Domain >/dev/null 2>&1
fi

echo "Deleting files..."

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    VHOST="/etc/httpd/vhost/$Domain.conf"
    VHOSTSSL="/etc/httpd/vhost/$Domain-le-ssl.conf"

    # Delete PHP-FPM Pool
    sudo rm -rf /etc/php-fpm.d/$Domain.conf
    sudo rm -rf /etc/opt/remi/*/php-fpm.d/$Domain.conf

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    VHOST="/etc/apache2/vhost/$Domain.conf"
    VHOSTSSL="/etc/apache2/vhost/$Domain-le-ssl.conf"

    # Delete PHP-FPM Pool
    sudo rm -rf /etc/php/*/fpm/pool.d/$Domain.conf

else
    echo "Unknown operating system."
    exit
fi

sudo userdel -f $Username >/dev/null 2>&1
sudo rm -rf /home/$Domain
sudo rm -rf $VHOST
sudo rm -rf $VHOSTSSL

# NGINX
sudo rm -rf /etc/nginx/vhost/$Domain.conf
sudo rm -rf /etc/nginx/vhost/$Domain.bak

SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Domain='$Domain';")
for Database in $SQL; do

    echo "Dropping MySQL/MariaDB database $Database..."
    sudo mariadb -uroot -p$MySQLRootPassword -e "DROP DATABASE $Database"

done

SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Domain='$Domain';")
for Database in $SQL; do

    echo "Dropping PostgreSQL database $Database..."
    sudo su - postgres -c "dropdb $Database"

done

# Delete DNS Zone
sudo /go/zone $Domain delete

# Delete FTP Permissions
sudo rm -rf /etc/vsftpd/permission/$Domain

# Remove line start with $Domain #Domain
sudo sed -i "/^$Domain #Domain/d" /etc/postfix/vmail_domains

# Delete DKIM Record
sudo rm -rf /etc/opendkim/$Domain

# Delete Cron Jobs
CronFile="${Domain//./_}"
if sudo test -f /etc/cron.d/$CronFile ; then
    sudo rm -rf /etc/cron.d/$CronFile
fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "delete from Site where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "delete from Alias where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "delete from Subdomain where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "delete from Directory where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "delete from Mysql where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "delete from Postgre where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "delete from SQLite where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "delete from Mail where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "delete from Ftp where Domain='$Domain'"

echo "Domain $Domain has been deleted."

if [[ ! "$@" = *"--force"* ]]; then

    if [ -t 0 ]; then

        if sudo test -f /var/go/etc/snapshot.conf ; then

            MESSAGE "Info: Domain Deletion Recovery\nIf you deleted a domain $Domain by mistake, you can recover it with:\n/go/recover $Domain"

        fi

    fi

fi

# Immediately Allow Recover
sudo rm -rf /var/log/go/recover/$Domain.log
