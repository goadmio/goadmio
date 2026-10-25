#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

LockFile="/usr/local/goadmio/lock/mailtop.lock"
if [[ ! "$@" = *"--cron"* ]] || [[ ! "$@" = *"--force"* ]]; then
    if sudo test -f "$LockFile" ; then
        if [[ $(($(date +%s) - $(stat -c %Y "$LockFile" 2>/dev/null))) -le "1800" ]]; then
            InstanceFile=$(<"$LockFile")
            echo "Instance ($InstanceFile) already running."
            exit 1
        fi
    fi

    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

	# Run When Click Ctrl+C
	trap 'sudo rm -f "$LockFile"' EXIT

fi

Ago=$(($(echo "$1" | tr -cd '0-9')))

Site=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site;" | tr '\n' ' ' | xargs echo -n)
Alias=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias;" | tr '\n' ' ' | xargs echo -n)
Hostname=$(</etc/hostname)

TimeStamp=$(date +'%s')

ServerLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT ServerLimit FROM Config WHERE ConfigID=1")

if [ "$Ago" -eq 0 ]; then
    Date=$(date +"%Y-%m-%d")
    Today=$(date +"%b %e")
    WeekField="Sent"$(date +"%A")
    TodayString=$(date +"%A, %B %-d")
else
    Date=$(date -d "$Ago days ago" +"%Y-%m-%d")
    Today=$(date -d "$Ago days ago" +"%b %e")
    WeekField="Sent"$(date -d "$Ago days ago" +"%A")
    TodayString=$(date -d "$Ago days ago" +"%A, %B %-d")
fi

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config" | sed 's/,/|/g')
if [[ "$AdminEmail" = *"@"* ]]; then
    E=$(sudo cat /var/log/maillog | grep "^$Today " | sed -E "/$AdminEmail/d" | sed '/smtp\[/!d' | sed '/@/!d' | wc -l)
else
    E=$(sudo cat /var/log/maillog | grep "^$Today " | sed '/smtp\[/!d' | sed '/@/!d' | wc -l)
fi

if sudo test -f /usr/local/goadmio/cache/mailtop.db ; then
    if [[ $(</usr/local/goadmio/cache/mailtop.db) = "$E" ]]; then
        if [[ "$@" = *"--cron"* ]]; then
            sudo rm -rf "$LockFile"
            exit 1
        fi
    fi
fi
echo "$E" | sudo tee /usr/local/goadmio/cache/mailtop.db >/dev/null

Q=$(sudo /usr/bin/mailq | grep -c "^[A-F0-9]")

if [ "$Q" -ne 0 ]; then
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
    echo "Queue Count ($Q)"
fi

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
echo "$TodayString ($E Emails)"

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

EmailString=""
EmailIDs=$(sudo cat /var/log/maillog | grep "^$Today " | sed '/smtp\[/!d' | sed '/@/!d' | awk {'print $6'} | sed 's/://')

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET SentToday=0,${WeekField}=0"

if [ "$E" -le "5000" ] || [ "$Ago" -ge 1 ] || [[ "$@" = *"--force"* ]]; then

    while IFS= read -r EmailID; do

        Email=$(sudo cat /var/log/maillog | grep "$EmailID:" | grep -oE 'from=<[^>]+>' | sed 's/from=<//; s/>//' | head -1)

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET SentToday=SentToday+1,${WeekField}=${WeekField}+1 where Email='$Email'"

        if [[ "$Email" = *"@"* ]]; then
            if [ "$EmailString" = "" ]; then
                EmailString="$Email"
            else
                EmailString="$EmailString\n$Email"
            fi
        fi

    done <<<"$EmailIDs"

else

    echo "Too many emails (RUN: /go/mailtop --force)"
    exit 1

fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET SentThisWeek=SentSunday+SentMonday+SentTuesday+SentWednesday+SentThursday+SentFriday+SentSaturday"

OUTPUT="Sent Today|Email|Domain"
OUTPUT="$OUTPUT\n----------|-----|------"

DATA=$(sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/mail.db "SELECT IFNULL(SentToday,'0') || '|' || IFNULL(Email,'') || '|' || IFNULL(Domain,'') FROM Mail WHERE SentToday>0 ORDER BY SentToday DESC")
while IFS='|' read -r SentToday Email Domain; do
    OUTPUT="$OUTPUT\n$SentToday|$Email|$Domain"
done <<<"$DATA"

echo -e "$OUTPUT" | column -t -s "|"

T=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "SELECT SUM(SentToday) FROM Mail")
T=${T:-0}

if [ "$E" -ne $T ]; then
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
    echo -e "$EmailString" | sort | uniq -c | sort -nr | head -n 10
fi

printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

if [ "$E" -gt "$ServerLimit" ] && [ "$Ago" -eq 0 ]; then

    if sudo test ! -f "/var/log/go/mail/mailtop-$Date.log" ; then

        UserLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT UserLimit From Config where ConfigID=1")

        if [ "$ServerLimit" -gt "0" ] && [ "$UserLimit" -gt "0" ]; then

            echo "Email Limit Exceeded ($E/$ServerLimit)"

            sudo /go/sendmail "Email Limit Exceeded ($E/$ServerLimit)" "Mail queue has been deleted to prevent SPAM issues on your server. More details /var/log/go/mail/mailtop-$Date.log" "Outbound SPAM"
            sudo /go/sendwhatsapp "*Email Limit Exceeded ($E/$ServerLimit)*\n\nMail queue has been deleted to prevent SPAM issues on your server. More details /var/log/go/mail/mailtop-$Date.log" "Outbound SPAM"

            sudo /go/mailtop --force | sudo tee "/var/log/go/mail/mailtop-$Date.log"
            sudo /usr/sbin/postsuper -d ALL
            sudo /usr/sbin/postsuper -d ALL deferred
            sudo /go/smtp block

        fi

    fi

fi

sudo rm -rf "$LockFile"