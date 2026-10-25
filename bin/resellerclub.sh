#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/resellerclub "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ResellerclubIP=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubIP from Config")
ResellerclubUserID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubUserID from Config")
ResellerclubAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubAPIKey from Config")

if [ "$ResellerclubIP" = "" ] || [ "$ResellerclubUserID" = "" ] || [ "$ResellerclubAPIKey" = "" ]; then
    echo "Please Setup ResellerClub API."
    exit 1
fi

C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

if [[ "$@" = *"--auth code"* ]] || [[ "$@" = *"--authcode"* ]] || [[ "$@" = *"--auth-code"* ]]; then

    Domain=$1
    AuthCode=$2

    if [ "$Domain" = "all" ]; then

        cd /home
        for Domain in *; do

            if [[ ! $Domain = "m."* ]]; then

                if sudo test -d "/home/$Domain/www" ; then

                    N=$(($N + 1))

                    echo -ne "[$N/$C] Modification of Domain Secret of $Domain..."
                    echo ""

                    Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/auth-code.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey&AuthCode=$AuthCode")
                    echo "$Result"

                fi

            fi

        done

    else

        echo -ne "Modification of Domain Secret of $Domain..."
        echo ""

        Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/auth-code.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey&AuthCode=$AuthCode")
        echo "$Result"

    fi

fi

if [[ "$@" = *"--unlock"* ]]; then

    Domain=$1

    if [ "$Domain" = "all" ]; then

        cd /home
        for Domain in *; do

            if [[ ! $Domain = "m."* ]]; then

                if sudo test -d "/home/$Domain/www" ; then

                    N=$(($N + 1))

                    echo -ne "[$N/$C] Unlock $Domain..."
                    echo ""

                    Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/unlock.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey")
                    echo "$Result"

                fi

            fi

        done

    else

        echo -ne "Unlock $Domain..."
        echo ""

        Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/unlock.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey")
        echo "$Result"

    fi

fi

if [[ "$@" = *"--lock"* ]]; then

    Domain=$1

    if [ "$Domain" = "all" ]; then

        cd /home
        for Domain in *; do

            if [[ ! $Domain = "m."* ]]; then

                if sudo test -d "/home/$Domain/www" ; then

                    N=$(($N + 1))

                    echo -ne "[$N/$C] Lock $Domain..."
                    echo ""

                    Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/lock.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey")
                    echo "$Result"

                fi

            fi

        done

    else

        echo -ne "Lock $Domain..."
        echo ""

        Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/lock.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey")
        echo "$Result"

    fi

fi
