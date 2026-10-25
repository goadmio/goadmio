#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" != "" ]; then

    sudo rm -rf /usr/local/goadmio/db/load.db
    Password=$(echo -n "[$1]" | md5sum | awk '{print $1}')
    history -c

elif sudo test -f /etc/config ; then
    Password=$(</etc/config)
else
    exit 1
fi

if [ "$2" != "" ]; then
    Hostname=$2
else
    Hostname=$(</etc/hostname)
fi

Dots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)

if [ "$Dots" -ge "2" ] && [ "$Password" != "" ]; then

    if sudo test ! -f /usr/local/goadmio/db/load.db ; then

        echo "" | sudo tee /usr/local/goadmio/db/load.db >/dev/null

        AdminEmail=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=AdminEmail&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
        if [[ "$AdminEmail" = *"@"* ]]; then

            CronEmail=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CronEmail&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            AdminMobile=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=AdminMobile&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            QueueNo=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=QueueNo&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            WAInstanceID=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=WAInstanceID&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            WAAPIKey=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=WAAPIKey&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            SSHAlert=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=SSHAlert&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            IMAPAlert=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=IMAPAlert&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET AdminEmail='$AdminEmail',CronEmail='$CronEmail',AdminMobile='$AdminMobile',QueueNo='$QueueNo',WAInstanceID='$WAInstanceID',WAAPIKey='$WAAPIKey',SSHAlert='$SSHAlert',IMAPAlert='$IMAPAlert' WHERE AdminEmail=''"

        fi

        CloudflareAccountID=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CloudflareAccountID&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)

        # TRIM
        CloudflareAccountID=$(echo $CloudflareAccountID | xargs echo -n)

        if [ "$CloudflareAccountID" != "" ]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET CloudflareAccountID='$CloudflareAccountID' WHERE CloudflareAccountID=''"
        fi

        CloudflareAPIToken=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=CloudflareAPIToken&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)

        # TRIM
        CloudflareAPIToken=$(echo $CloudflareAPIToken | xargs echo -n)

        if [ "$CloudflareAPIToken" != "" ] && [ "$AdminEmail" != "" ]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET CloudflareAPIToken='$CloudflareAPIToken' WHERE CloudflareAPIToken=''"
        fi

        # Reseller Club

        ResellerclubIP=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubIP&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
        ResellerclubIP=$(echo $ResellerclubIP | xargs echo -n)
        if [ "$ResellerclubIP" != "" ]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET ResellerclubIP='$ResellerclubIP' WHERE ResellerclubIP=''"
        fi

        ResellerclubUserID=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubUserID&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
        ResellerclubUserID=$(echo $ResellerclubUserID | xargs echo -n)
        if [ "$ResellerclubUserID" != "" ]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET ResellerclubUserID='$ResellerclubUserID' WHERE ResellerclubUserID=''"
        fi

        ResellerclubAPIKey=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=ResellerclubAPIKey&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
        ResellerclubAPIKey=$(echo $ResellerclubAPIKey | xargs echo -n)
        if [ "$ResellerclubAPIKey" != "" ]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET ResellerclubAPIKey='$ResellerclubAPIKey' WHERE ResellerclubAPIKey=''"
        fi

        DisableFunctions=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=disable_functions&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
        if [[ "$DisableFunctions" = *","* ]]; then
            sudo /go/disablefunctions $DisableFunctions
        fi

        # Crontab
        CrontabNo=$(crontab -l -u root | wc -l)
        if [ "$CrontabNo" -le "1" ]; then

            Crontab=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=Crontab&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)

            if [ "$Crontab" != "" ]; then

                echo "$Crontab" | sudo tee /usr/local/goadmio/tmp/crontab.db >/dev/null

                # Install new cron file
                crontab /usr/local/goadmio/tmp/crontab.db -u root

            fi

        fi

        # Timeout
        if sudo test ! -f /etc/timeout ; then

            Timeout=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=Timeout&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            Timeout=$(echo $Timeout | xargs echo -n)
            if [[ "$Timeout" -ge "30" ]]; then
                echo "$Timeout" | sudo tee /etc/timeout >/dev/null
            fi

        fi

        # Uptime
        if sudo test ! -f /var/go/etc/uptime ; then

            Uptime=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=Uptime&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)
            if [ "$Uptime" != "" ]; then
                echo "$Uptime" | sudo tee /var/go/etc/uptime >/dev/null
            fi

        fi

        sudo /go/basic

    fi

    N=0
    FileArray=('/var/go/etc/backup.conf' '/var/go/etc/secondary.conf' '/var/go/etc/tertiary.conf' '/var/go/etc/snapshot.conf' '/root/.config/rclone/rclone.conf')
    for File in ${FileArray[@]}; do

        if sudo test ! -f $File ; then

            Name=$(basename "$File")

            Code=$(sudo wget "https://go.blackhost.com/file.php?Hostname=$Hostname&Name=$Name&Password=$Password" -q -t 1 -T 5 --no-check-certificate -O -)

            if [ "$Code" != "" ]; then

                echo "$Code" >$File

            fi

        fi

    done

fi
