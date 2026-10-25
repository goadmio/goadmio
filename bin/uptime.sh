#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test ! -f "/var/go/etc/uptime" ; then

    echo "File /var/go/etc/uptime not found."
    exit 1

fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
AlternativeAdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AlternativeAdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

TimeStamp=$(date +'%s')

Line="/var/go/etc/uptime"
while IFS= read HOST; do

    N=$(($N + 1))

    # TRIM
    HOST=$(echo $HOST | xargs echo -n)

    if [[ "$HOST" = "http"* ]]; then

        for ((T = 1; T <= 5; T += 1)); do

            Source1=$(curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" $HOST/index.php?T=$TimeStamp)
            Source2=$(curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" $HOST/apartment-$TimeStamp)

            Monitor=0
            if [[ "$Source1" = *"</html>"* ]] || [[ "$Source2" = *"</html>"* ]]; then

                Monitor=1
                break

            else

                echo "$HOST: Test Again $T"
                sleep 12

            fi

        done

        if [[ "$Monitor" -eq "1" ]]; then

            echo "[$N] Web Server is up: $HOST..."

        else

            echo "[$N] Web Server is down: $HOST..."

            sudo /go/sendmail "GoAdmio (Webserver is down: $HOST)" "Webserver is down: $HOST" "Server Down"
            sudo /go/sendwhatsapp "*GoAdmio (Webserver Down)*\n\nWebserver is down: $HOST" "Server Down"

        fi

    else

        for ((T = 1; T <= 5; T += 1)); do

            Monitor=0
            if nc -z $HOST 22 2>/dev/null; then

                Monitor=1
                break

            else

                echo "$HOST: Test Again $T"
                sleep 12

            fi

        done

        if [[ "$Monitor" -eq "1" ]]; then

            echo "[$N] Monitor is up: $HOST..."

        else

            echo "[$N] Monitor is down: $HOST..."

            sudo /go/sendmail "GoAdmio (Monitor is down: $HOST)" "Monitor is down: $HOST" "Server Down"
            sudo /go/sendwhatsapp "*GoAdmio*\n\nMonitor is down: $HOST" "Server Down"

        fi

    fi

done <"$Line"
