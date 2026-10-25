#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" != "" ]; then

    Password=$(echo -n "[$1]" | md5sum | awk '{print $1}')
    history -c

elif sudo test -f /etc/config ; then
    Password=$(</etc/config)
else
    echo "Please enter password."
    exit 1
fi

if [ "$2" != "" ]; then
    Hostname=$2
else
    Hostname=$(</etc/hostname)
fi

Dots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)

if [ "$Dots" -ge "2" ] && [ "$Password" != "" ]; then

    AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
    CronEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CronEmail from Config")
    AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
    QueueNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select QueueNo from Config")
    WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
    WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")
    SSHAlert=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSHAlert from Config")
    IMAPAlert=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select IMAPAlert from Config")

    if [[ "$AdminEmail" = *"@"* ]]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=AdminEmail&Value=$AdminEmail&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [[ "$CronEmail" = *"@"* ]]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CronEmail&Value=$CronEmail&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [ "$AdminMobile" != "" ]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=AdminMobile&Value=$AdminMobile&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [[ "$QueueNo" -ge "100" ]]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=QueueNo&Value=$QueueNo&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [ "$WAInstanceID" != "" ]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=WAInstanceID&Value=$WAInstanceID&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [ "$WAAPIKey" != "" ]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=WAAPIKey&Value=$WAAPIKey&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [ "$SSHAlert" != "" ]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=SSHAlert&Value=$SSHAlert&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    if [ "$IMAPAlert" != "" ]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=IMAPAlert&Value=$IMAPAlert&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    CloudflareAccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
    CloudflareAPIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

    if [ "$CloudflareAccountID" != "" ] && [ "$CloudflareAPIToken" != "" ]; then

        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CloudflareAccountID&Value=$CloudflareAccountID&Password=$Password" -q -t 1 -T 5 --no-check-certificate
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CloudflareAPIToken&Value=$CloudflareAPIToken&Password=$Password" -q -t 1 -T 5 --no-check-certificate

    fi

    ResellerclubIP=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubIP from Config")
    ResellerclubUserID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubUserID from Config")
    ResellerclubAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubAPIKey from Config")

    if [ "$ResellerclubIP" != "" ] && [ "$ResellerclubUserID" != "" ] && [ "$ResellerclubAPIKey" != "" ]; then

        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubIP&Value=$ResellerclubIP&Password=$Password" -q -t 1 -T 5 --no-check-certificate
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubUserID&Value=$ResellerclubUserID&Password=$Password" -q -t 1 -T 5 --no-check-certificate
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubAPIKey&Value=$ResellerclubAPIKey&Password=$Password" -q -t 1 -T 5 --no-check-certificate

    fi

    # Disable Functions
    DisableFunctions=$(/go/disablefunctions Return)
    if [[ "$DisableFunctions" = *","* ]]; then
        sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=disable_functions&Value=$DisableFunctions&Password=$Password" -q -t 1 -T 5 --no-check-certificate
    fi

    crontab -l -u root >/usr/local/goadmio/tmp/crontab.db
    CrontabNo=$(sudo cat /usr/local/goadmio/tmp/crontab.db | wc -l)
    if [ "$CrontabNo" -ge "1" ]; then

        Crontab=$(</usr/local/goadmio/tmp/crontab.db)

        sudo curl \
            --data-urlencode "Hostname=$Hostname" \
            --data-urlencode "Name=Crontab" \
            --data-urlencode "Value=$Crontab" \
            --data-urlencode "Password=$Password" \
            https://go.blackhost.com/file.php

    fi

    if sudo test -f /etc/timeout ; then

        Timeout=$(</etc/timeout)

        if [[ "$Timeout" -ge "30" ]]; then
            sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=Timeout&Value=$Timeout&Password=$Password" -q -t 1 -T 5 --no-check-certificate
        fi

    fi

    if sudo test -f /var/go/etc/uptime ; then

        Uptime=$(</var/go/etc/uptime)

        if [ "$Uptime" != "" ]; then
            sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=Uptime&Value=$Uptime&Password=$Password" -q -t 1 -T 5 --no-check-certificate
        fi

    fi

    N=0

    FileArray=('/var/go/etc/backup.conf' '/var/go/etc/secondary.conf' '/var/go/etc/tertiary.conf' '/var/go/etc/snapshot.conf' '/root/.config/rclone/rclone.conf')
    for File in ${FileArray[@]}; do

        if sudo test -f $File ; then

            N=$(($N + 1))

            Code=$(<$File)

            Name=$(basename "$File")

            if [ "$Code" != "" ]; then

                sudo curl \
                    --data-urlencode "Hostname=$Hostname" \
                    --data-urlencode "Name=$Name" \
                    --data-urlencode "Value=$Code" \
                    --data-urlencode "Password=$Password" \
                    https://go.blackhost.com/file.php

            fi

        fi

    done

fi
