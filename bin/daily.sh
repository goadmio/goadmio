#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $(date +%w) -eq 0 ]; then

    sudo /go/weekly

else

    sudo /go/cronjob
    sudo /go/sitemap

    sudo /go/quota
    sudo /go/fixquota

    sudo /go/ssl all
    sudo /go/mailssl

    sudo /go/checksmtp
    sudo /go/checkimap
    sudo /go/checkssl
    sudo /go/checkfirewall
    sudo /go/checkid

    sudo /go/antivirus
    sudo /go/expire
    sudo /go/bots
    sudo /go/scan

    PrayerTimes=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "SELECT Missed FROM Notify WHERE Keyword='Prayer Times'")
    if [ "$PrayerTimes" -eq "1" ]; then
        sudo /go/prayer
    fi

    if sudo test -d /GoAdmio ; then
        sudo /go/backup go
    fi

fi
