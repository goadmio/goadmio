#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/fm "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
FM=$2

TimeStamp=$(date +'%s')
FMStamp=$((TimeStamp - 7200))

LogTime=$(date +"%Y-%m-%d %H:%M:%S")

if [ $# -eq 0 ]; then

    # Logout
    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain || ',' || FMStamp from Site where FMStamp!=0 and FMStamp<$FMStamp;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        Domain="${Row[0]}"
        FMStamp="${Row[1]}"

        echo "Logout: $Domain"
        echo "$LogTime $Domain Logout" | sudo tee -a /var/log/go/fm.log >/dev/null

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FMStamp='0' where Domain='$Domain'"

        sudo /go/fix $Domain

    done

    exit 1

fi

if [ "$FM" = "login" ] || [ "$FM" = "Login" ]; then

    # Login

    echo "$LogTime $Domain Login" | sudo tee -a /var/log/go/fm.log >/dev/null

    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

    if sudo test -d "/home/$Domain/www" ; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FMStamp='$TimeStamp' where Domain='$Domain'"

        sudo chmod -R 777 /home/$Domain/www
        sudo chown -R $Username:$Username /home/$Domain/www

        # FTP Accounts
        SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "select User || ',' || Directory from Ftp where Domain='$Domain';")
        for Result in $SQL; do

            IFS=',' read -r -a Row <<<"$Result"

            User="${Row[0]}"
            Directory="${Row[1]}"

            if [[ ! "$Directory" = *"/www" ]]; then
                sudo chown -R $User:$User $Directory
            fi

        done

    fi

    exit 1

fi

if [ "$Domain" = "all" ]; then

    cd /home
    for Domain in *; do

        Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

        if sudo test -d "/home/$Domain/www" ; then

            sudo mkdir -p /usr/local/goadmio/home/go/fm/$Domain

            sudo rm -rf /usr/local/goadmio/home/go/fm/$Domain/index.php
            sudo rm -rf /usr/local/goadmio/home/go/fm/$Domain/advanced.php

            sudo cp /usr/local/goadmio/home/go/fm/index.php /usr/local/goadmio/home/go/fm/$Domain/
            sudo cp /usr/local/goadmio/home/go/fm/advanced.php /usr/local/goadmio/home/go/fm/$Domain/

            sudo chmod 755 /usr/local/goadmio/home/go/fm/$Domain
            sudo chown -R $Username:$Username /usr/local/goadmio/home/go/fm/$Domain

        fi

    done

else

    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

    if sudo test -d "/home/$Domain/www" ; then

        sudo mkdir -p /usr/local/goadmio/home/go/fm/$Domain

        sudo rm -rf /usr/local/goadmio/home/go/fm/$Domain/index.php
        sudo rm -rf /usr/local/goadmio/home/go/fm/$Domain/advanced.php

        sudo cp /usr/local/goadmio/home/go/fm/index.php /usr/local/goadmio/home/go/fm/$Domain/
        sudo cp /usr/local/goadmio/home/go/fm/advanced.php /usr/local/goadmio/home/go/fm/$Domain/

        sudo chmod 755 /usr/local/goadmio/home/go/fm/$Domain
        sudo chown -R $Username:$Username /usr/local/goadmio/home/go/fm/$Domain

    fi

fi
