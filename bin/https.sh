#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/https "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

if [ "$Domain" = "all" ]; then

    if [ "$Action" = "1" ] || [ "$Action" = "Enable" ]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1"

    else

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0"

    fi

    sudo /go/conf

elif [ "$Domain" = "live" ]; then

    cd /etc/letsencrypt/live
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            if [ "$Action" = "1" ] || [ "$Action" = "Enable" ]; then

                echo "Redirecting HTTP to HTTPS Enabled for $Domain."
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1 where Domain='$Domain'"

            else

                echo "Redirecting HTTP to HTTPS Disabled for $Domain."
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0 where Domain='$Domain'"

            fi

            sudo /go/apache $Domain
            sudo /go/nginx $Domain

        fi

    done

else

    if [ "$Action" = "1" ] || [ "$Action" = "Enable" ]; then

        echo "Redirecting HTTP to HTTPS Enabled for $Domain."
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1 where Domain='$Domain'"

    else

        echo "Redirecting HTTP to HTTPS Disabled for $Domain."
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0 where Domain='$Domain'"

    fi

    sudo /go/apache $Domain
    sudo /go/nginx $Domain

fi
