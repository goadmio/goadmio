#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Username=$1
Password=$2

OS=$(</usr/local/goadmio/linux/os.db)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Username" = "go" ]; then

    sudo useradd -m -d /var/go -s /bin/bash go
    sudo chown go:go /var/go

    # Copy the common profile files (only ones that exist)
    sudo /go/profile

    sudo useradd -M -d /var/admin admin

    exit 1

elif [ "$Username" = "skeleton" ]; then

    Domain="$Username"
    Directory="/var/skeleton"

elif [ "$Username" = "opendkim" ]; then

    Domain="$Username"
    Directory="/etc/$Domain"

else

    UsernameExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Username='$Username'")

    if [[ ! "$UsernameExists" = "$Username" ]]; then
        echo "Username $Username not exists"
        exit 1
    fi

    Domain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Username='$Username'")
    Directory="/home/$Domain"

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    adduser -d $Directory $Username >/dev/null 2>&1

    if [ "$Password" != "" ]; then
        echo "$Password" | sudo passwd "$Username" --stdin >/dev/null 2>&1
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    adduser --disabled-password --force-badname --gecos "" $Username >/dev/null 2>&1
    usermod -d $Directory -m $Username >/dev/null 2>&1

    if [ "$Password" != "" ]; then
        Password=$(sudo openssl passwd $Password)
        usermod -p $Password $Username >/dev/null 2>&1
    fi

fi
