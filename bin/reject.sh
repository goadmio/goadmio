#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Email=$1
Domain=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

RejectMessage=$@
RejectMessage=${RejectMessage/$1 $2/}
RejectMessage=$(echo $RejectMessage | sed -e 's/^[ \t]*//')

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET RejectMessage='$RejectMessage' WHERE Email='$Email'"

# Remove line start with $Email
sudo sed -i "/^$Email /d" /etc/postfix/vmail_aliases
sudo sed -i "/^$Email /d" /etc/postfix/custom_replies

TimeStamp=$(date +'%s')
echo "$Email REJECT $RejectMessage" | sudo tee -a /etc/postfix/custom_replies >/dev/null

echo "All email sent to $Email will now be copied to ':Recipient address rejected: $RejectMessage'."

sudo /go/mail restart
