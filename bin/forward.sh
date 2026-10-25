#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Email=$1
ForwardTo=$2
Domain=$3
Action=$4

if [ $# -eq 0 ]; then
    exit 1
fi

if [ "$Action" = "delete" ]; then

    # Remove line start with $Email
    sudo sed -i "/^$Email /d" /etc/postfix/custom_replies

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET ForwardTo='' where Email='$Email'"

    echo "Mail for $Email will no longer be forwarded"

else

    if [[ "$Email" = *"@"* ]]; then

        TimeStamp=$(date +'%s')

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET ForwardTo='$ForwardTo' WHERE Email='$Email'"
        echo "All email sent to $Email will now be moved to $ForwardTo."

    fi

fi

sudo screen -d -m bash -c "/go/vmail"
