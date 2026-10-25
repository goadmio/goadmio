#!/bin/sh

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

echo "Change Multiple Email Account Passwords"

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

AccountExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain' and Trash=0")
if [[ ! "$AccountExists" = "$Domain" ]]; then
    echo "Account Domain $Domain not exists"
    exit 1
fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail where Domain='$Domain'" | sudo tee /usr/local/goadmio/$Domain.email >/dev/null

File="/usr/local/goadmio/$Domain.email"
while IFS= read Email; do

    if [ "$2" = "" ]; then
        Pass=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
    else
        Pass=$2
    fi

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail set Pass='$Pass' where Email='$Email'"

    echo "$Email | $Pass"

    # Remove line start with $Email
    sudo sed -i "/^$Email/d" /etc/dovecot/passwd

    Pass=$(doveadm pw -s sha1 -p $Pass | cut -d '}' -f2)
    echo "$Email:$Pass" | sudo tee -a /etc/dovecot/passwd >/dev/null

done <"$File"

sudo postmap /etc/postfix/custom_replies
sudo postmap /etc/postfix/vmail_domains
sudo postmap /etc/postfix/vmail_mailbox
sudo postmap /etc/postfix/vmail_aliases

sudo systemctl restart postfix
sudo systemctl restart dovecot
sudo systemctl restart saslauthd
sudo systemctl restart opendkim
