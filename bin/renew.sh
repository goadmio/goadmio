#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if sudo test -d "/home/$Domain/www" ; then

    ExpiresOn=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ExpiresOn from Site where Domain='$Domain';")

    echo "Domain: $Domain"
    echo "Expires On: $ExpiresOn"

    ExpiresOn=$(date -d "$ExpiresOn +1 year" +"%Y-%m-%d")

    echo "Expires On (Renew 1 Year): $ExpiresOn"

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site set ExpiresOn='$ExpiresOn' where Domain='$Domain'"

    sudo /go/unsuspend $Domain

    sudo /go/ssl $Domain

fi
