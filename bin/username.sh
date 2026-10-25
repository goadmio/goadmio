#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

Domain=$1
Username=$2

if [[ ! "$Username" =~ ^[a-z0-9][a-z0-9_.-]*[$]?$ ]]; then
    echo "Invalid Username $Username"
    exit 1
fi

if [ ! ${#Username} -ge 3 ]; then
    echo "Username must be at least 3 chars"
    exit 1
fi

if id -u "$Username" >/dev/null 2>&1; then
    echo "Username $Username already exists."
    exit 1
fi

if grep -q "^$Username:" /etc/passwd; then
    echo "Username $Username already exists."
    exit 1
fi

# OLD Username
User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if sudo test ! -d "/home/$Domain" ; then
    echo "Directory /home/$Domain not exists."
    exit 1
fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "UPDATE SQLite SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE FTP SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/httplog.db "UPDATE Httplog SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "UPDATE Ftplog SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "UPDATE Mysql SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "UPDATE Subdomain SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "UPDATE Directory SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/github.db "UPDATE Github SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "UPDATE Alias SET Username='$Username' where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "UPDATE Block SET Username='$Username' where Domain='$Domain'"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo groupdel $User &>/dev/null
    sudo userdel -f $User &>/dev/null

    sudo /go/adduser $Username

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo groupdel $User &>/dev/null
    sudo userdel -f $User &>/dev/null

    sudo /go/adduser $Username

fi

sudo chgrp nobody /home/$Domain/www
sudo chown -R $Username:$Username /home/$Domain/www
sudo chmod 755 /home/$Domain

# Change default password for all MySQL Databases
sudo /go/phpmyadmin $Domain
