#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

W=$(date +%a)
D=$(date +%d)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if sudo test -d /var/go/cron/daily ; then

    C=$(ls /var/go/cron/daily | wc -l)
    if [ "$C" -gt "0" ]; then

        echo "Daily Scheduling Files..."

        sudo /go/sendmail "Daily Scheduling Files Running Now" "Daily Scheduling Files Running Now" "Cron Job"
        sudo /go/sendwhatsapp "*Daily Scheduling Files Running Now*" "Cron Job"

        cd /var/go/cron/daily
        for File in *; do

            if [[ "$File" = *".sh" ]]; then

                sudo chmod +x /var/go/cron/daily/$File
                /var/go/cron/daily/$File

            fi

        done

    fi

fi

if sudo test -d /var/go/cron/weekly ; then

    C=$(ls /var/go/cron/weekly | wc -l)
    if [ "$C" -gt "0" ]; then

        if [ "$W" = "Sat" ]; then

            echo "Weekly Scheduling..."

            sudo /go/sendmail "Weekly Scheduling Files Running Now" "Weekly Scheduling Files Running Now" "Cron Job"
            sudo /go/sendwhatsapp "*Weekly Scheduling Files Running Now*" "Cron Job"

            cd /var/go/cron/weekly
            for File in *; do

                if [[ "$File" = *".sh" ]]; then

                    sudo chmod +x /var/go/cron/weekly/$File
                    /var/go/cron/weekly/$File

                fi

            done

        fi

    fi

fi

if sudo test -d /var/go/cron/monthly ; then

    C=$(ls /var/go/cron/monthly | wc -l)
    if [ "$C" -gt "0" ]; then

        if [ "$D" = "01" ]; then

            echo "Monthly Scheduling Files..."

            echo "Weekly Scheduling..."

            sudo /go/sendmail "Monthly Scheduling Files Running Now" "Monthly Scheduling Files Running Now" "Cron Job"
            sudo /go/sendwhatsapp "*Monthly Scheduling Files Running Now*" "Cron Job"

            cd /var/go/cron/monthly
            for File in *; do

                if [[ "$File" = *".sh" ]]; then

                    sudo chmod +x /var/go/cron/monthly/$File
                    /var/go/cron/monthly/$File

                fi

            done

        fi

    fi

fi
