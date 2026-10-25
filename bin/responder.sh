#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Email=$1
Action=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

TimeStamp=$(date +'%s')

if [ "$Action" = "delete" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "DELETE from Responder where Email='$Email'"

    if sudo test -f "/var/spool/autoresponse/responses/$Email" ; then
        sudo rm -rf /var/spool/autoresponse/responses/$Email}
    fi

    if sudo test -f "/var/spool/autoresponse/responses/${Email}_DISABLED" ; then
        sudo rm -rf /var/spool/autoresponse/responses/${Email}_DISABLED
    fi

    echo "The autoresponder $Email was deleted."

elif [ "$Action" = "add" ]; then

    Subject=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select Subject from Responder where Email='$Email'")
    Message=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select Message from Responder where Email='$Email'")
    Active=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select Active from Responder where Email='$Email'")

    if sudo test -f "/var/spool/autoresponse/responses/${Email}_DISABLED" ; then

        sudo rm -rf /var/spool/autoresponse/responses/${Email}_DISABLED

    fi

    echo "From: $Email" | sudo tee /var/spool/autoresponse/responses/$Email >/dev/null
    echo "To: THIS GETS REPLACED" | sudo tee -a /var/spool/autoresponse/responses/$Email >/dev/null
    echo "Subject: $Subject" | sudo tee -a /var/spool/autoresponse/responses/$Email >/dev/null
    echo "" | sudo tee -a /var/spool/autoresponse/responses/$Email >/dev/null
    echo "" | sudo tee -a /var/spool/autoresponse/responses/$Email >/dev/null
    echo "$Message" | sudo tee -a /var/spool/autoresponse/responses/$Email >/dev/null

    sudo chmod 600 /var/spool/autoresponse/responses/$Email
    sudo chown -R autoresponse:autoresponse /var/spool/autoresponse/responses/$Email

    if [ "$Active" = "0" ]; then
        autoresponse -d $Email &>/dev/null
    else
        autoresponse -E $Email &>/dev/null
    fi

    echo "The autoresponder $Email was successfully created."

fi

# Check Start Date and End Date (Enable/Disable) based on date [RUN BY CRON JOB Every day at 00:00]
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

cd /var/spool/autoresponse/responses
for File in *; do

    Email=${File/_DISABLED/}

    StartDate=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select StartDate from Responder where Email='$Email'")
    EndDate=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select EndDate from Responder where Email='$Email'")

    Active=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/responder.db "select Active from Responder where Email='$Email'")

    StartDateStamp=$(date -d "$StartDate 00:00:00" +"%s")
    EndDateStamp=$(date -d "$EndDate 00:00:00" +"%s")

    if [ "$TimeStamp" -ge "$StartDateStamp" ] && [ "$TimeStamp" -le "$EndDateStamp" ]; then
        # Enable

        if [ "$Active" = "1" ]; then

            if [[ "$File" = *"_DISABLED"* ]]; then

                # Enable $Email
                autoresponse -E $Email

            fi
        fi

    else
        # DISABLE

        if [ "$Active" = "1" ]; then

            if [[ "$File" != *"_DISABLED"* ]]; then

                # Disable $Email
                autoresponse -d $Email

            fi
        fi

    fi

done

sudo postmap /etc/postfix/custom_replies
sudo postmap /etc/postfix/vmail_domains
sudo postmap /etc/postfix/vmail_mailbox
sudo postmap /etc/postfix/vmail_aliases

sudo systemctl restart postfix
sudo systemctl restart dovecot
sudo systemctl restart saslauthd
