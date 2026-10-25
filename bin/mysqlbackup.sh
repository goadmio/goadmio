#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Port=$3
Database=$4
Config=$5

Date=$(date +'%Y-%m-%d')
Time=$(date +"%Y-%m-%d %H:%M:%S")

if [ $# -eq 0 ] || [ "$Config" = "1" ]; then

    Config="1"

    if sudo test -f /var/go/etc/mysqlbackup.conf ; then

        RemoteServer=$(sudo grep -E "^RemoteServer*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
        RemoteUser=$(sudo grep -E "^RemoteUser*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
        RemotePassword=$(sudo grep -E "^RemotePassword*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
        RemoteDir=$(sudo grep -E "^RemoteDir*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
        Port=$(sudo grep -E "^Port*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)
        MaxSessions=$(sudo grep -E "^MaxSessions*=*" /var/go/etc/mysqlbackup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

    else

        echo "File /var/go/etc/mysqlbackup.conf not found"
        exit 1

    fi

    if [ "$RemotePassword" = "" ]; then

        if sudo test -f /var/go/etc/go.key ; then

            MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}' | base64)
            RemotePassword=$(sudo openssl base64 -d -aes-128-cbc -d -pbkdf2 -nosalt -md md5 -in /var/go/etc/go.key -pass pass:"$MAC")

        else

            echo "REMOTE: Invalid password"
            exit 1

        fi

    fi

fi

Hostname=$(</etc/hostname)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$RemoteUser" = "" ]; then
    RemoteUser="root"
fi

if [ "$RemoteDir" = "" ]; then
    RemoteDir="/backup"
fi

if [ "$Port" = "" ]; then
    Port="22222"
fi

MaxSessions=$((MaxSessions))

if [ "$MaxSessions" -eq "0" ]; then
    MaxSessions=100
fi

if [ "$Database" != "" ]; then

    sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/lib/mysql/$Database/ $RemoteUser@$RemoteServer:$RemoteDir/mariadb/$Hostname/mysql/$Database/

    echo "1" | sudo tee /usr/local/goadmio/tmp/mysqlbackup/$Database >/dev/null

    exit 1

fi

sudo rm -rf /usr/local/goadmio/tmp/mysqlbackup
sudo mkdir -p /usr/local/goadmio/tmp/mysqlbackup
sudo rm -rf /var/log/go/mysqlbackup
sudo mkdir -p /var/log/go/mysqlbackup

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $RemoteUser@$RemoteServer "mkdir -p $RemoteDir/mariadb/$Hostname/mysql" | sudo tee /usr/local/goadmio/tmp/scp.db >/dev/null

if grep -iqE "permission|denied|error" /usr/local/goadmio/tmp/scp.db; then
    echo "REMOTE: Invalid username or password"
    exit 1
fi

echo "Backup MariaDB/MySQL to $RemoteServer:$RemoteDir/mariadb/$Hostname/mysql..."

echo -ne "Working... Please be patient"

# STOP Firewall & Fail2ban
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $RemoteUser@$RemoteServer "/go/firewall stop" >/dev/null 2>&1

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $RemoteUser@$RemoteServer "echo $Time >> $RemoteDir/mariadb/$Hostname/mysql.log"

Folders=$(sudo find /var/lib/mysql -maxdepth 1 -mindepth 1 -type d | tr '\n' '|' | sed -e 's/^|//' -e 's/|$//')

IFS='|' read -ra FolderArray <<<"$Folders"
for Folder in "${FolderArray[@]}"; do

    N=$(($N + 1))

    if [ "$N" -ge "$MaxSessions" ]; then
        N=$(($N - 1))
        break
    fi

    echo -ne "."

    Database="${Folder##*/}"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $RemoteUser@$RemoteServer "mkdir -p $RemoteDir/mariadb/$Hostname/mysql/$Database"

    sudo nohup /go/mysqlbackup $RemoteServer $RemotePassword $Port $Database $Config >/var/log/go/mysqlbackup/$Database.log 2>&1 &

done

print_percentage_bar() {
    local percentage=$1
    local width=50
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf "["
    printf "%${filled}s" | tr ' ' '-'
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%\n" "$percentage"
}

for ((i = 1; ; i++)); do

    clear

    F=$(ls /usr/local/goadmio/tmp/mysqlbackup | wc -l)

    P=$(($F * 100 / $N))

    if [ "$MaxSessions" -eq "100" ]; then
        ls -tr /usr/local/goadmio/tmp/mysqlbackup | sed "s/^/✓ /"
    fi

    echo ""

    print_percentage_bar $P

    if [ "$F" -eq "$N" ]; then
        break
    fi

    sleep 10

done

echo ""
echo -ne "Verifying"

for N in {1..25}; do

    if [ "$N" -eq "20" ]; then
        echo ":"
        sudo systemctl stop mariadb
    fi

    Check=$(sshpass -p "$RemotePassword" rsync -azlh --delete --stats -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/lib/mysql/ $RemoteUser@$RemoteServer:$RemoteDir/mariadb/$Hostname/mysql/)

    if [[ "$Check" = *"transferred: 0"* ]]; then
        # No files transferred (already in sync)
        break
    else
        # Files were transferred (incremental sync occurred)
        echo -ne "."
    fi

done

sudo systemctl start mariadb

# START Firewall & Fail2ban
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $RemoteUser@$RemoteServer "/go/firewall start" >/dev/null 2>&1

echo ""
