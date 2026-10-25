#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

Block=0
Date=$(date +'%Y-%m-%d')
TimeStamp=$(date +'%s')
QueueNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select QueueNo from Config where  ConfigID=1")

if [ "$1" = "delete" ]; then

    echo "Deleting mail queue..."

    sudo /usr/sbin/postsuper -d ALL
    sudo /usr/sbin/postsuper -d ALL deferred

    exit 1

fi

if [ "$1" = "count" ]; then

    C=$(sudo /usr/bin/mailq | grep -c "^[A-F0-9]")
    echo "$C"
    exit 1

fi

SPAM=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SPAM from Config where ConfigID=1")

if [ "$SPAM" -eq 0 ]; then

    echo "Tracking setting is disabled."

    exit 1

fi

# Detect SPAM Mail Count
C=$(sudo /usr/bin/mailq | grep -c "^[A-F0-9]")
echo "Queue Count: $C"

Today=$(date '+%b %e')
SentToday=$(sudo cat /var/log/maillog | grep "^$Today " | grep "status=sent" | wc -l)
echo "Total Emails Sent Today $Today: $SentToday"

if [ "$C" -gt "$QueueNo" ]; then

    UserLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT UserLimit From Config where ConfigID=1")

    if [ "$UserLimit" -gt "0" ]; then

        Block=1

        sudo /go/sendmail "GoAdmio Tracking - Mail Queue Count ($C)" "Mail queue has been deleted to prevent SPAM issues on your server. More details /var/log/go/mail/spam-$Date.log" "Outbound SPAM"
        sudo /go/sendwhatsapp "*GoAdmio Tracking - Mail Queue Count ($C)*\n\nMail queue has been deleted to prevent SPAM issues on your server. More details /var/log/go/mail/spam-$Date.log" "Outbound SPAM"

        sudo /go/mailtop --force | sudo tee /var/log/go/mail/spam-$Date.log
        sudo /go/smtp block

    else

        sudo /go/sendmail "Mail Queue Count: $C" "No Action Taken" "Outbound SPAM"
        sudo /go/sendwhatsapp "*Mail Queue Count: $C*\n\nNo Action Taken" "Outbound SPAM"

    fi

fi

if [ "$Block" -eq "1" ]; then
    sudo postsuper -d ALL
fi
