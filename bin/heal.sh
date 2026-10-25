#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Heal=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT Heal FROM Config")

if [[ "$@" = *"--disable"* ]]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Heal='0'"

    echo "Auto-Heal has been disabled."
    exit 1

fi

if [[ "$@" = *"--enable"* ]]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Heal='1'"

    echo "Auto-Heal has been enabled."
    exit 1

fi

if [ "$Heal" -eq "0" ]; then

    echo "Auto-Heal is disabled."
    exit 1

fi

if sudo test -f /usr/local/goadmio/minio/minio.conf ; then

    if grep -q ":443 " /usr/local/goadmio/minio/minio.conf; then
        exit 1
    fi

fi

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
Hostname=$(</etc/hostname)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

ServerIP=$(curl -s -4 checkip.amazonaws.com)

if sudo test -f "/etc/disk" ; then

    Disk=$(</etc/disk)

    Re="^[0-9]+$"
    if ! [[ "$Disk" =~ $Re ]]; then
        Disk="90"
    fi

else
    Disk="90"
fi

# Int value (H) to remove space before number
declare -i H=$(date +%k)

if [ "$H" -ge "18" ]; then
    Q="4"
elif [ "$H" -ge "12" ]; then
    Q="3"
elif [ "$H" -ge "6" ]; then
    Q="2"
else
    Q="1"
fi

D=$(date +'%Y-%j')
DateQ="$D-$Q"

# Check Mariadb Status
echo "Checking MySQL Status..."
Check=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select count(User) from mysql.user")

if [[ ! "$Check" -ge "1" ]]; then

    echo "Restarting MariaDB..."
    MSG="Restarting MariaDB"

    sudo systemctl restart mariadb

    # Check Socket
    Socket=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select count(User) from mysql.user" 2>&1)

    if [[ "$Socket" = *"mysql.sock"* ]]; then

        MSG="Fixing MySQL Socket"

        sudo rm -rf /var/lib/mysql/mysql.sock
        sudo systemctl restart mariadb

    fi

    sudo /go/sendmail "GoAdmio Auto-Heal System ($MSG)" "GoAdmio Auto-Heal System ($MSG)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System ($MSG)*" "Service Monitoring"

fi

# Check Apache & NGINX Status
if [[ "$ServerIP" = *"."* ]]; then

    echo "Checking $WS Status..."
    Status=$(sudo wget -q -O - -t 1 --timeout=10 "http://$ServerIP:2020/conf.php")

    if [ "$Status" != "1" ]; then

        sleep 15s
        Status=$(sudo wget -q -O - -t 1 --timeout=10 "http://$ServerIP:2020/conf.php")

    fi

    if [ "$Status" != "1" ] && [ "$Apache" != "1" ]; then

        if sudo test ! -f "/usr/local/goadmio/tmp/$WS-status-$DateQ.db" ; then

            echo "" | sudo tee /usr/local/goadmio/tmp/$WS-status-$DateQ.db >/dev/null

            sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting $WS)" "GoAdmio Auto-Heal System (Restarting $WS)" "Service Monitoring"
            sudo /go/sendwhatsapp "GoAdmio Auto-Heal System (Restarting $WS)" "Service Monitoring"

            sudo /go/conf --installwebserver

            sleep 30s
            Status=$(sudo wget -q -O - -t 1 --timeout=10 "http://$ServerIP:2020/conf.php")

            if [ "$Status" != "1" ]; then

                sleep 15s
                Status=$(sudo wget -q -O - -t 1 --timeout=10 "http://$ServerIP:2020/conf.php")

            fi

            if [ "$Status" != "1" ]; then

                echo "Rebooting server..."

                sudo /go/sendmail "GoAdmio Auto-Heal System (Rebooting Server)" "GoAdmio Auto-Heal System (Rebooting Server)" "Service Monitoring"
                sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Rebooting Server)*" "Service Monitoring"

                sudo /usr/sbin/reboot

            fi

        fi

    fi

fi

# Check PHP FPM Status
echo "Checking FPM Status..."
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    cd /etc/opt/remi
    for Version in *; do
        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            FMPStatus=$(systemctl status $Version-php-fpm)
            if [[ "$FMPStatus" = *"(dead)"* ]]; then

                if sudo test ! -f "/usr/local/goadmio/tmp/$Version-php-fpm-status-$DateQ.db" ; then

                    FPM="1"
                    echo "" | sudo tee /usr/local/goadmio/tmp/$Version-php-fpm-status-$DateQ.db >/dev/null

                    echo "Restarting $Version-php-fpm..."

                    sudo systemctl restart $Version-php-fpm

                fi

            fi

        fi
    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php
    for Version in *; do
        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            FMPStatus=$(systemctl status php$Version-fpm)
            if [[ "$FMPStatus" = *"(dead)"* ]]; then

                if sudo test ! -f "/usr/local/goadmio/tmp/php$Version-fpm-status-$DateQ.db" ; then

                    FPM="1"
                    echo "" | sudo tee /usr/local/goadmio/tmp/php$Version-fpm-status-$DateQ.db >/dev/null

                    echo "Restarting php$Version-fpm..."
                    sudo systemctl restart php$Version-fpm

                fi

            fi

        fi
    done

fi

if [ "$FPM" = "1" ]; then

    sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting FPM)" "(Restarting FPM)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Restarting FPM)*" "Service Monitoring"

fi

echo "Checking SSHD Status..."
Command=$(systemctl status sshd 2>&1)
if echo $Command | grep -iqE "dead|could not be found|changed on disk"; then

    echo "Restarting SSHD..."

    if [ "$OS" = "Ubuntu" ]; then
        sudo systemctl restart ssh
        sudo systemctl enable ssh
    else
        sudo systemctl restart sshd
        sudo systemctl enable sshd
    fi

    sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting SSHD)" "GoAdmio Auto-Heal System (Restarting SSHD)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Restarting SSHD)*" "Service Monitoring"

    Command=$(systemctl status sshd 2>&1)
    if echo $Command | grep -iqE "dead|could not be found|changed on disk"; then
        sudo /go/ssh
    fi

    Command=$(systemctl status sshd 2>&1)
    if echo $Command | grep -iqE "dead|could not be found|changed on disk"; then

        echo "Installing SSH..."
        sudo /go/installssh >/var/log/go/cron/installssh.log 2>&1

        Header="Dear Server Administrator,\n\nThis is an automated security alert from GoAdmio AI.\n\nOur monitoring system has detected irregularities in the SSH service on your server. These may include misconfigurations, missing service files, or potential service interruptions that could impact remote access and server manageability.\n\nTo ensure uninterrupted access and maintain security standards, the GoAdmio AI System will now automatically install and configure the SSH service on your server. This proactive measure restores secure remote connectivity and resolves the detected issue without requiring manual intervention.\n\n"
        Footer="The GoAdmio AI System will continue to monitor SSH service health and other critical components in real-time. Should you have any questions or require further details regarding this automated action, please do not hesitate to reach out.\n\nThank you for maintaining the security and reliability of your server.\n\nBest regards,\nGoAdmio AI Security Team\nwww.goadmio.com\n\n"
        Note="Note: This email is automatically generated by the GoAdmio AI System. Please do not reply directly to this message."

        sudo /go/sendmail "SSH Service Issue Detected - Resolution Initiated" "${Header}${Err}${Footer}${Note}" "Server Down"
        sudo /go/sendwhatsapp "*SSH Service Issue Detected - Resolution Initiated*\n\n${Header}${Err}${Footer}${Note}" "Server Down"

    fi

fi


echo "Checking DROPBEAR Status..."
Command=$(systemctl status dropbear 2>&1)
if echo $Command | grep -iqE "dead|could not be found|changed on disk"; then

    echo "Restarting DROPBEAR..."

    sudo systemctl restart dropbear
    sudo systemctl enable dropbear
    
    sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting DROPBEAR)" "GoAdmio Auto-Heal System (Restarting DROPBEAR)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Restarting DROPBEAR)*" "Service Monitoring"

    Command=$(systemctl status dropbear 2>&1)
    if echo $Command | grep -iqE "dead|could not be found|changed on disk"; then

        echo "Installing DROPBEAR..."
        sudo /go/dropbear >/var/log/go/cron/dropbear.log 2>&1

        Header="Dear Server Administrator,\n\nThis is an automated security alert from GoAdmio AI.\n\nOur monitoring system has detected irregularities in the DROPBEAR service on your server. These may include misconfigurations, missing service files, or potential service interruptions that could impact remote access and server manageability.\n\nTo ensure uninterrupted access and maintain security standards, the GoAdmio AI System will now automatically install and configure the DROPBEAR service on your server. This proactive measure restores secure remote connectivity and resolves the detected issue without requiring manual intervention.\n\n"
        Footer="The GoAdmio AI System will continue to monitor DROPBEAR service health and other critical components in real-time. Should you have any questions or require further details regarding this automated action, please do not hesitate to reach out.\n\nThank you for maintaining the security and reliability of your server.\n\nBest regards,\nGoAdmio AI Security Team\nwww.goadmio.com\n\n"
        Note="Note: This email is automatically generated by the GoAdmio AI System. Please do not reply directly to this message."

        sudo /go/sendmail "DROPBEAR Service Issue Detected - Resolution Initiated" "${Header}${Err}${Footer}${Note}" "Server Down"
        sudo /go/sendwhatsapp "*DROPBEAR Service Issue Detected - Resolution Initiated*\n\n${Header}${Err}${Footer}${Note}" "Server Down"

    fi

fi

echo "Checking POSTFIX Status..."
Command=$(systemctl status postfix 2>&1)
if echo $Command | grep -iqF dead; then

    echo "Restarting POSTFIX..."

    sudo /go/postconf
    sudo systemctl restart postfix
    sudo systemctl enable postfix

    sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting POSTFIX)" "GoAdmio Auto-Heal System (Restarting POSTFIX)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Restarting POSTFIX)*" "Service Monitoring"

fi

echo "Checking DOVECOT Status..."
Command=$(systemctl status dovecot 2>&1)
if echo "$Command" | grep -iqE "dead|fatal"; then

    echo "Restarting DOVECOT..."

    sudo /go/doveconf
    sudo systemctl restart dovecot
    sudo systemctl enable dovecot

    sudo /go/sendmail "GoAdmio Auto-Heal System (Restarting DOVECOT)" "GoAdmio Auto-Heal System (Restarting DOVECOT)" "Service Monitoring"
    sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Restarting DOVECOT)*" "Service Monitoring"

fi

echo "Checking Memory Status..."
# Check Memory Usage
MemoryUsage=$(free | grep Mem | awk '{print int($3/$2 * 100.0)}')

if [ "$MemoryUsage" -gt "90" ]; then

    if sudo test ! -f "/usr/local/goadmio/tmp/memory-status-$DateQ.db" ; then

        echo "" | sudo tee /usr/local/goadmio/tmp/memory-status-$DateQ.db >/dev/null

        MemoryMB=$(free -m | grep Mem | awk '{print $2}')
        if [ "$MemoryMB" -le "1500" ]; then
            Notify="2 GB of RAM is the minimum system requirement for GoAdmio. (Current Memory: $MemoryMB MB)"
        fi

        sudo /go/sendmail "GoAdmio Auto-Heal System (Memory Usage: ${MemoryUsage}%)" "$Notify" "Service Monitoring"
        sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Memory Usage: ${MemoryUsage}%)*" "Service Monitoring"

        sudo /go/fpm reload

    fi

fi

# Server Load
CPUThreads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $CPUThreads)}")

if [ "$ServerLoad" -gt "200" ]; then

    if sudo test ! -f "/usr/local/goadmio/tmp/load-$DateQ.db" ; then

        echo "" | sudo tee /usr/local/goadmio/tmp/load-$DateQ.db >/dev/null

        MEM=$(/go/mem)

        sudo /go/sendmail "GoAdmio Auto-Heal System (Server Load: ${ServerLoad}%)" "$MEM" "Service Monitoring"
        sudo /go/sendwhatsapp "*GoAdmio Auto-Heal System (Server Load: ${ServerLoad}%)*\n\n$MEM" "Service Monitoring"

        sudo /go/ddos block

    fi

fi

echo "Checking Disk Usage Status..."
DiskUsage=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g')
if [ "$DiskUsage" -ge "$Disk" ]; then

    echo "Your disk space is running low (Disk Usage: ${DiskUsage}%)"
    sudo /go/sendmail "GoAdmio - Your disk space is running low (Disk Usage: ${DiskUsage}%)" "GoAdmio - Your disk space is running low (Disk Usage: ${DiskUsage}%)" "Service Monitoring"
    sudo /go/sendwhatsapp "*Your disk space is running low (Disk Usage: ${DiskUsage}%)*" "Service Monitoring"

    sudo /go/clean
    sudo /go/delcache all

fi

echo "Checking GoAdmio Usernames..."
if ! id "go" >/dev/null 2>&1 || ! id "admin" >/dev/null 2>&1; then
    echo "User go or admin does not exist"
    /go/adduser go
fi

echo "Checking GoAdmio Databases Ownership..."
if find /var/lib/sqlite \( ! -user go -o ! -group go \) -print -quit | grep -q .; then
    echo "Some GoAdmio Databases have wrong ownership"
    sudo chown -R go:go /var/lib/sqlite
fi



sudo /go/welcome
