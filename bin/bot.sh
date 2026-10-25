#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

if [ "$Domain" = "all" ]; then

    if [ "$Action" = "1" ] || [ "$Action" = "Enable" ]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Bot=1"

    else

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Bot=0"

    fi

    sudo /go/conf

else

    if sudo test -d "/home/$Domain/www" ; then

        if [ "$Action" = "1" ] || [ "$Action" = "Enable" ]; then

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Bot=1 where Domain='$Domain'"

        else

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Bot=0 where Domain='$Domain'"

        fi

        sudo /go/apache $Domain
        sudo /go/nginx $Domain

        sudo /go/reload "| Executed by $(basename "$0")"

    fi

fi
