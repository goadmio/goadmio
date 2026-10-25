#!/bin/bash
# Run in background
if [[ " $* " != *" --bg "* ]]; then
    sudo nohup /go/sendwhatsapp --bg "$@" >>/var/log/go/background/whatsapp.log 2>&1 &
    exit 0
fi
# Drop --bg so "$@" is the real arguments again
shift   
# End Run in background

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ServerIP=$(curl -s -4 checkip.amazonaws.com)
Hostname=$(</etc/hostname)

AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Message=$1
Keyword=$2

W=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "SELECT count(*) FROM Notify WHERE Keyword='$Keyword' and Whatsapp='1'")
M=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "SELECT count(*) FROM Notify WHERE Keyword='$Keyword' and Missed='1'")

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "UPDATE Notify SET Alert=Alert+1 WHERE Keyword='$Keyword';"

if [ "$W" -ge "1" ]; then

    IFS=',' read -ra MobileArray <<<"$AdminMobile"
    for Mobile in "${MobileArray[@]}"; do

        # urlencode
        Text=$(printf %s "$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nType: $Keyword" | jq -sRr @uri)
        sudo curl --max-time 3 -s "https://www.crmrealty.net/api/whatsapp/send.php?To=${Mobile}&Message=$Text&APIKey=$WAAPIKey" >/dev/null

    done

fi

if [ "$M" -ge "1" ]; then

    MisswdCall=1
    LockFile="/usr/local/goadmio/lock/missed.lock"
    if sudo test -f $LockFile ; then
        if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
            MisswdCall=0
        fi
    fi

    if [ "$MisswdCall" -eq "1" ]; then

        IFS=',' read -ra MobileArray <<<"$AdminMobile"
        for Mobile in "${MobileArray[@]}"; do

            # Misswd Call
            sudo curl --max-time 3 -s "https://www.crmrealty.net/api/twilio/missed.php?To=${Mobile}" >/dev/null

        done

        echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

    fi

fi
