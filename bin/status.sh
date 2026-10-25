#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/status.db "DELETE FROM Status"

sudo systemctl | grep .service >/usr/local/goadmio/tmp/status.db
sudo sed -i "s/.service/|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/loaded /loaded|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/active /active|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/failed /failed|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/running /running|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/exited /exited|/g" /usr/local/goadmio/tmp/status.db
sudo sed -i "s/●/ /g" /usr/local/goadmio/tmp/status.db

N=20

File="/usr/local/goadmio/tmp/status.db"
while IFS= read Line; do

    N=$(($N + 1))

    IFS='|' read -r -a Array <<<"$Line"
    Service="${Array[0]}"

    # TRIM String
    Service=$(echo $Service | sed -e 's/^[ \t]*//')

    Status="${Array[1]} ${Array[2]} ${Array[3]}"

    Description="${Array[4]}"

    # TRIM String
    Service=$(echo $Service | sed -e 's/^[ \t]*//')
    Status=$(echo $Status | sed -e 's/^[ \t]*//')
    Description=$(echo $Description | sed -e 's/^[ \t]*//')

    echo "$Service | $Status | $Description"

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/status.db "INSERT INTO Status (Service,Status,Description,Sort) VALUES ('$Service','$Status','$Description','$N')"

done <"$File"
