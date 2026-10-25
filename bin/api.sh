#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

File=$1

TimeStamp=$(date +'%s')

Child=$(sudo xmlstarlet sel -t -v "name(/*/*[1])" $File)
Count=$(sudo xmlstarlet sel -t -v "count(//$Child)" $File)

for ((i = 1; i <= Count; i++)); do

    while IFS=$'\t' read -r Element Value; do
        Variable=$(echo "$Element" | sed 's/[^a-zA-Z0-9_]/_/g')
        declare "$Variable=$Value"
    done < <(xmlstarlet sel -t -m "//$Child[$i]/*" -v "name(.)" -o $'\t' -v "." -n $File)

    if [ "$Child" = "API" ]; then

        if [[ ${#APIKey} -eq 16 ]] || [[ ${#APIKey} -eq 59 ]]; then

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/api.db "DELETE FROM API WHERE Name='$Name'"
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/api.db "INSERT INTO API (Name,APIKey,Command,IP,TimeStamp) ValueS ('$Name','$APIKey','$Command','$IP','$TimeStamp')"

            Name=$(printf %s "$Name" | jq -sRr @uri)
            URL="https://go.domain.com/api/api.php?Name=$Name&APIKey=$APIKey"

            echo "API URL: $URL"

        else
            echo "ERROR: API key length ${#APIKey} must be either 16 or 50 characters"
        fi

    fi

done
