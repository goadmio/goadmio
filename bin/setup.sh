#!/bin/bash

OS=$(</usr/local/goadmio/linux/os.db)
Machine=$(hostnamectl status | grep "Virtualization")
Version=$(</usr/local/goadmio/linux/version.db)

# Backup Hostname
if sudo test -f "/etc/hostname" ; then

    sudo cp /etc/hostname /etc/hostname.bak
    Hostname=$(</etc/hostname)

fi

clear
GoVersion=$(curl -s -k -m 10 --retry 0 https://download.goadmio.com/home/go/update/latest.txt | sed 's/[^0-9.]//g' | sed -E 's/([0-9]{2})([0-9])([0-9])([0-9])/\1.\2.\3/')
echo "Installing GoAdmio v${GoVersion}..."
sudo sed -i "s/\[GoVersion\]/$GoVersion/g" /usr/local/goadmio/install/index.html

DistroVersion=$((${Version%.*}))
echo "$OS Version: $Version"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [[ ! $DistroVersion -ge "9" ]]; then
        echo "GoAdmio requires at least $OS 9"
        exit 1
    fi

    InstallTime="25:00"
    InstallTimeLite="20:00"

elif [ "$OS" = "Debian" ]; then

    if [[ ! $DistroVersion -ge "11" ]]; then
        echo "GoAdmio requires at least $OS 11"
        exit 1
    fi

    InstallTime="17:00"
    InstallTimeLite="15:00"

elif [ "$OS" = "Ubuntu" ]; then

    if [[ ! $DistroVersion -ge "22" ]]; then
        echo "GoAdmio requires at least $OS 22"
        exit 1
    fi

    InstallTime="17:00"
    InstallTimeLite="15:00"

fi

if sudo test -f /usr/local/goadmio/db/lite.db ; then

    if [[ "$Machine" = *"kvm"* ]]; then

        echo "Virtualization: KVM"
        echo "Estimating Installation Time: $InstallTimeLite"

    elif [[ "$Machine" = *"openvz"* ]]; then

        echo "Virtualization: OpenVZ"
        echo "Estimating Installation Time: $InstallTimeLite"

    elif [[ "$Machine" = *"xen"* ]]; then

        echo "Virtualization: Xen"
        echo "Estimating Installation Time: $InstallTimeLite"

    else

        echo "Estimating Installation Time: $InstallTimeLite"

    fi

else

    if [[ "$Machine" = *"kvm"* ]]; then

        echo "Virtualization: KVM"
        echo "Estimating Installation Time: $InstallTime"

    elif [[ "$Machine" = *"openvz"* ]]; then

        echo "Virtualization: OpenVZ"
        echo "Estimating Installation Time: $InstallTime"

    elif [[ "$Machine" = *"xen"* ]]; then

        echo "Virtualization: Xen"
        echo "Estimating Installation Time: $InstallTime"

    else

        echo "Estimating Installation Time: $InstallTime"

    fi

fi

sleep 10s

FTPPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
SMTPPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

MySQLRootPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
# Create /root/.my.cnf
echo "[client]" >/root/.my.cnf
echo "user=root" >>/root/.my.cnf
echo "password=$MySQLRootPassword" >>/root/.my.cnf
echo "[mysqld]" >>/root/.my.cnf

ServerIP=$(curl -s -4 checkip.amazonaws.com)
MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}')
SSHUsername=$(echo -n "$ServerIP|$MAC" | md5sum | awk '{print "go" substr($1, 0, 14)}')
SSHPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

# Config
sudo /go/config $MySQLRootPassword $SSHUsername

sudo /go/server --install
sudo /go/firewall
sudo /go/php
sudo /go/installmariadb
sudo /go/package

# SET MySQL root password first time
sudo mariadb-admin -u root password $MySQLRootPassword

# Databases
sudo /go/sqliterc
sudo /go/filter
sudo /go/notify
sudo /go/database
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set SSHPassword='$SSHPassword'"

# Pool Full Access
sudo /go/adduser go $FTPPassword

# Create skeleton account (FTP Only)
sudo /go/adduser skeleton $FTPPassword

# Add GoAdmio (Grant Root Privileges)
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    useradd -M -ou 0 -g 0 $SSHUsername
    echo "$SSHPassword" | passwd "$SSHUsername" --stdin
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    useradd -M -ou 0 -g 0 $SSHUsername
    SSHPassword=$(sudo openssl passwd $SSHPassword)
    usermod -p $SSHPassword $SSHUsername
fi

if sudo test ! -f /usr/local/goadmio/db/lite.db ; then

    sudo /go/compress
    sudo /go/java
    sudo /go/installgo
    sudo /go/gdown
    # /go/postgresql

fi

# /go/autoresponders
sudo /go/dropbear --install
sudo /go/fail2ban
sudo /go/composer
sudo /go/roundcube
sudo /go/snappymail
sudo /go/speed
sudo /go/ssh2
sudo /go/installssl
sudo /go/installmail --skip
sudo /go/phpmyadmin
sudo /go/cron
sudo /go/go
sudo /go/finish
