#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/password "$@"
fi

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") '********' >>/var/log/go/$(basename "$0").log

Domain=$1
Password=$2

OS=$(</usr/local/goadmio/linux/os.db)

Password=$(echo "${Password//\[DollarSign\]/$}")
Password=$(echo "${Password//\[AndSign\]/&}")
Password=$(echo "${Password//\[EqualSign\]/=}")
Password=$(echo "${Password//\[HashSign\]/#}")

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Domain" = "all" ]; then

    OUTPUT="Domain Password"

    cd /home
    for Domain in *; do

        Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

        if sudo test -d "/home/$Domain/www" ; then

            if [ "$Password" = "" ]; then

                Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

            fi

            sudo /go/password $Domain $Password

            OUTPUT="$OUTPUT\n$Username $Password"

        fi

    done

    echo -ne $OUTPUT | column -t

    exit 1

fi

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if sudo test ! -d "/home/$Domain" ; then
    echo "Directory /home/$Domain not exists."
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo groupdel $Username &>/dev/null
    sudo userdel -f $Username &>/dev/null

    sudo /go/adduser $Username $Password

    echo "Password has been modified successfully ($Domain)."

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo groupdel $Username &>/dev/null
    sudo userdel -f $Username &>/dev/null

    sudo /go/adduser $Username $Password

    echo "Password has been modified successfully ($Domain)."

else
    echo "Unknown operating system."
    exit
fi

sudo chgrp nobody /home/$Domain/www
sudo find /home/$Domain/www -type f -not -name "* *" | xargs chmod 777
sudo find /home/$Domain/www -type d -not -name "* *" | xargs chmod 777
sudo chown -R $Username:$Username /home/$Domain/www

sudo firewall-cmd --zone=public --add-port=20/tcp --permanent &>/dev/null
sudo firewall-cmd --zone=public --add-port=21/tcp --permanent &>/dev/null
sudo firewall-cmd --reload &>/dev/null

sudo chmod 755 /home/$Domain

# Change SSH Password
sudo /go/passwd $Domain

sudo systemctl restart vsftpd

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "update Site SET Password='$Password' where Username='$Username'"

echo "Change default password for all MySQL Databases:"
sudo /go/phpmyadmin $Domain
