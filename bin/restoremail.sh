#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/restoremail "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if sudo test ! -d "/home/$Domain/mail" ; then
    echo "Domain $Domain not exists."
    exit 1
fi

if sudo test ! -d "/home/$Domain/mail" ; then
    echo "Directory /home/$Domain/mail not exists."
    exit 1
fi

Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

sudo chown vmail:vmail -R /home/$Domain/mail

cd /home/$Domain/mail
for Username in *; do

    Email="$Username@$Domain"

    EmailExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail where Email='$Email'")
    if [[ ! "$EmailExists" = "$Email" ]]; then

        sudo /go/mail --email "$Email" --pass "$Pass" --forwardto "$ForwardTo" --reject "$Reject" --rejectmessage "$RejectMessage" --keepcopy "$KeepCopy" --domain "$Domain" --defaultaddress "$DefaultAddress" --suspend "$Suspend" --admin "$Admin" --description "$Description" --timestamp "$TimeStamp" --action add

    fi

done
