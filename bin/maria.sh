#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

LockFile="/usr/local/goadmio/lock/maria.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi
echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
# Run When Click Ctrl+C
trap 'sudo rm -f "$LockFile"' EXIT


export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/go
export HOME=/root
export RESTIC_PASSWORD="GoPanel"

Hostname=$(</etc/hostname)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ $(sudo grep -o "\." <<<"$Hostname" | wc -l) -lt "2" ]; then
    echo "Invalid Server Hostname $Hostname, A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."
    exit 1
fi

if [ "$1" = "start" ]; then

    if sudo test ! -f /var/go/etc/maria.conf ; then
        echo "Cron=\"0 12,16,20 * * *\"" | sudo tee /var/go/etc/maria.conf >/dev/null
    fi

    exit 1

fi

if [ "$1" = "stop" ]; then

    if sudo test -f /var/go/etc/maria.conf ; then

        sudo rm -rf /var/go/etc/maria.bak
        sudo mv /var/go/etc/maria.conf /var/go/etc/maria.bak

    fi

    exit 1

fi

H=$(date +%H)

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
if [ "$Threads" -ge 2 ]; then
    Parallel=$(($Threads / 2))
else
    Parallel=1
fi

if sudo test -f "/var/go/etc/maria.conf" ; then

    Dir=$(sudo grep -E "^Dir*=*" /var/go/etc/maria.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
    RemoteDir=$(sudo grep -E "^RemoteDir*=*" /var/go/etc/maria.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

    if [ "$Dir" = "" ]; then

        sudo mkdir -p /maria
        Dir="/maria"

    elif sudo test ! -d "$Dir" ; then

        echo "Folder $Dir not Exists."
        exit 1

    fi

    RemoteDir="${RemoteDir#/}"

    if [ "$RemoteDir" = "" ]; then

        RemoteDir="maria"

    fi

else

    echo "File /var/go/etc/maria.conf not Exists."

    exit 1

fi

ulimit -n 65535
sudo sysctl -w kernel.io_uring_disabled=0 >/dev/null 2>&1

if grep -q "\[maria\]" /root/.config/rclone/rclone.conf; then
    Destination="maria:$RemoteDir/$Hostname"
    ResticDestination="rclone:$Destination"
elif grep -q "\[backup\]" /root/.config/rclone/rclone.conf; then
    Destination="backup:$RemoteDir/$Hostname"
    ResticDestination="rclone:$Destination"
else
    Destination="/backup/maria"
    ResticDestination="/backup/maria"
    sudo mkdir -p /backup/maria
fi

if [ "$1" = "restore" ] || [ "$1" = "connect" ]; then

    if [ "$1" = "connect" ]; then

        DataDir="/var/go/var/lib/mysql"

        sudo /go/mysql system
        PID=$(lsof -i :3307 | tail -n 1 | awk {' print $2 '})
        if [ "$PID" != "" ]; then
            lsof -i :3307 | awk 'NR!=1 {print $2}' | xargs kill -9
        fi
        sudo rm -rf /var/go/var/lib/mysql/*

    else

        DataDir="/var/lib/mysql"

    fi

    if [[ ! "$2" = *"--"* ]]; then
        Archive=$2
    fi

    if [ "$1" = "restore" ] && [[ "$@" = *"--force"* ]]; then

        sudo systemctl stop mariadb >/dev/null
        sudo rm -rf /var/lib/mysql/*

    fi

    if [ "$1" = "restore" ] && sudo test -d "/var/lib/mysql/mysql" ; then

        echo "Directory /var/lib/mysql is not empty."

    else

        if [ "$Archive" != "" ]; then

            if [[ $(restic --repo $ResticDestination snapshots --tag $Archive | wc -l) -gt "1" ]]; then

                sudo rm -rf $Dir
                sudo mkdir -p $Dir

                echo "Restoring Restic TAG $Archive..."
                restic --repo $ResticDestination restore latest --target / --tag $Archive

            elif [[ $(restic --repo $ResticDestination snapshots $Archive | wc -l) -gt "1" ]]; then

                echo "Restoring Restic ID $Archive..."
                sudo rm -rf $Dir
                sudo mkdir -p $Dir

                restic --repo $ResticDestination restore $Archive --target /

            else

                echo "Archive $Archive does not exist"
                restic --repo $ResticDestination snapshots

                exit 1

            fi

        fi

        echo "Restoring MariaDB Backup..."
        if [ "$1" = "restore" ]; then
            sudo systemctl stop mariadb >/dev/null
        fi

        IncrementalFileNo=$(ls $Dir/$Hostname/incremental | wc -l)

        # Restore Backup
        if [ "$IncrementalFileNo" -eq "0" ]; then

            # Decompress
            sudo mariadb-backup --decompress --target-dir=$Dir/$Hostname/full

            # Prepare the Full Backup
            sudo mariadb-backup --prepare --target-dir=$Dir/$Hostname/full

            # Restore Full Backup
            sudo mariadb-backup --copy-back --datadir=$DataDir --parallel=$Parallel --target-dir=$Dir/$Hostname/full

        else

            # Decompress
            sudo mariadb-backup --decompress --parallel=$Parallel --target-dir=$Dir/$Hostname/full
            sudo mariadb-backup --decompress --parallel=$Parallel --target-dir=$Dir/$Hostname/incremental

            # Prepare the Full Backup
            sudo mariadb-backup --prepare --target-dir=$Dir/$Hostname/full

            # Prepare Full & Incremental Backup
            sudo mariadb-backup --prepare --target-dir=$Dir/$Hostname/full --incremental-dir=$Dir/$Hostname/incremental

            # Restore Full & Incremental Backup
            sudo mariadb-backup --copy-back --datadir=$DataDir --parallel=$Parallel --target-dir=$Dir/$Hostname/full

        fi

        if [ "$1" = "restore" ]; then
            sudo chown -R mysql:mysql /var/lib/mysql
            sudo systemctl restart mariadb
        else
            sudo chown -R mysql:mysql /var/go/var/lib/mysql
            mariadbd --defaults-file=/var/go/etc/my.cnf >/var/log/go/mariadbd.log 2>&1 &
            sleep 10
            sudo mariadb --socket=/var/go/var/lib/mysql/mysql.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MySQLRootPassword';FLUSH PRIVILEGES;"
            echo "mariadb --port=3307"

        fi

    fi

    exit 1

fi

if [ "$1" = "list" ]; then

    restic --repo $ResticDestination snapshots
    exit 1

fi

if [ "$1" = "refresh" ]; then

    sudo rm -rf $Dir/$Hostname/full
    sudo rm -rf $Dir/$Hostname/incremental

fi

sudo mkdir -p $Dir/$Hostname/full
sudo mkdir -p $Dir/$Hostname/incremental

if sudo test ! -d "$Dir/$Hostname/full/mysql" ; then

    echo "Taking Full Backup..."
    sudo mariadb-backup --backup --compress --parallel=$Parallel --user=root --password=$MySQLRootPassword --target-dir=$Dir/$Hostname/full

    echo "Restic Full Backup: $Destination..."
    restic init --repo $ResticDestination

    # Remove old snapshots
    restic --repo $ResticDestination forget --keep-within 24h --keep-daily 7 --keep-weekly 4 --keep-monthly 12
    restic --repo $ResticDestination prune

    restic backup $Dir --repo $ResticDestination --compression auto --tag $H

    exit 1

fi

echo "Taking Incremental Backup..."
sudo rm -rf $Dir/$Hostname/incremental/*
sudo mariadb-backup --backup --compress --parallel=$Parallel --user=root --password=$MySQLRootPassword --target-dir=$Dir/$Hostname/incremental --incremental-basedir=$Dir/$Hostname/full

echo "Restic Incremental Backup: $Destination..."
restic backup $Dir --repo $ResticDestination --compression auto --tag $H

sudo rm -f $LockFile
