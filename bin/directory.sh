#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Username=$1
Directory=$2
User=$3
Pass=$4

TimeStamp=$(date +'%s')

if sudo test -d "$Directory" ; then

    if [ "$User" = "delete" ]; then

        sudo rm -rf $Directory/.htaccess
        sudo rm -rf $Directory/.htpasswd

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "DELETE FROM Directory where Directory='$Directory'"

        echo "Directory privacy has been deleted"

    else

        sudo htpasswd -b -c $Directory/.htpasswd $User $Pass

        echo "AuthName \"Enter Password\"" | sudo tee $Directory/.htaccess >/dev/null
        echo "AuthType Basic" | sudo tee -a $Directory/.htaccess >/dev/null
        echo "AuthUserFile $Directory/.htpasswd" | sudo tee -a $Directory/.htaccess >/dev/null
        echo "Require valid-user" | sudo tee -a $Directory/.htaccess >/dev/null

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "INSERT INTO Directory (Name,Directory,User,Pass,Username,TimeStamp) VALUES ('$Name','$Directory','$User','$Pass','$Username','$TimeStamp')"

        echo "Directory $Directory has been protected"

    fi

fi