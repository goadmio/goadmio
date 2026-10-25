#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test -f /var/log/mysql.log ; then

    LogSize=$(stat -c %s /var/log/mysql.log)
    Seconds=$(($(date +%s) - $(stat -c %Y /var/log/mysql.log)))

    if [[ "$LogSize" -gt "10" ]] && [[ "$Seconds" -lt "3600" ]]; then

        echo "MOST FREQUENTLY EXECUTED SQL QUERIES:"
        echo "-------------------------------------"
        sudo cat /var/log/mysql.log | grep -i -oP "SELECT .*" | sort | uniq -c | sort -nr | head -n 10

    else

        echo "Start MariaDB logging..."
        sudo /go/my --log
        echo "Try again after 5 minutes."
        exit 1

    fi

else

    echo "Start MariaDB logging..."
    sudo /go/my --log
    echo "Try again after 5 minutes."
    exit 1

fi
