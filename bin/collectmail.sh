#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Output=$1

if [ $# -eq 0 ]; then
    echo "Error: No output file provided."
    echo "Usage: collectmail <Output CSV File>"
    exit 1
fi

if [[ ! $Output = *".csv" ]] && [[ ! $Output = *".txt" ]]; then

    echo "Error: No output file provided."
    echo "Usage: collectmail <Output CSV File>"
    exit 1

fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

sudo rm -rf /usr/local/goadmio/tmp/mail
sudo mkdir -p /usr/local/goadmio/tmp/mail

Sql=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select CONCAT(table_schema,',',table_name) from information_schema.tables;")
for Result in $Sql; do

    IFS=',' read -r -a Row <<<"$Result"

    Data="${Row[0]}"
    Table="${Row[1]}"

    echo -ne "\rCollecting Emails from $Data.$Table...                                                  "
    sudo mariadb -N -uroot -p$MySQLRootPassword -e "select email from $Data.$Table group by email" | sudo tee /usr/local/goadmio/tmp/mail/$Data.$Table.csv 2>/dev/null

    if ! grep -q "@" /usr/local/goadmio/tmp/mail/$Data.$Table.csv; then

        sudo rm -rf /usr/local/goadmio/tmp/mail/$Data.$Table.csv

    fi

done

C=$(ls /usr/local/goadmio/tmp/mail/*.csv | wc -l)

if [ "$C" -ge "1" ]; then

    sudo cat /usr/local/goadmio/tmp/mail/*.csv | tr '[:upper:]' '[:lower:]' | sort -u >/usr/local/goadmio/tmp/mail/email.csv

    if sudo test -f /usr/local/goadmio/tmp/mail/email.csv ; then
        sudo grep -E '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' /usr/local/goadmio/tmp/mail/email.csv >$Output
    fi

    EmailNo=$(wc -l $Output | awk '{print $1}')

    echo ""
    echo "Emails: $EmailNo"

fi
