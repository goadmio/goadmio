#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Name=$2
Action=$3

TimeStamp=$(date +'%s')

Username=$(sudo /usr/bin/sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ "$Action" = "delete" ]; then

    sudo /usr/bin/sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "DELETE FROM SQLite where Name='$Name' and Domain='$Domain'"

    echo "SQLite Access deleted successfully."

else

    sudo /usr/bin/mkdir -p /home/$Domain/sqlite

    if sudo test ! -f /home/$Domain/sqlite/$Name.db ; then
        SQLiteVersion=$(sudo /usr/bin/sqlite3 --version | /usr/bin/awk '{print $1}')
        sudo /usr/bin/sqlite3 /home/$Domain/sqlite/$Name.db "CREATE TABLE IF NOT EXISTS SQLite (ID INTEGER PRIMARY KEY ASC,Version TEXT NOT NULL DEFAULT '',TimeStamp INT NOT NULL DEFAULT '0')"
        sudo /usr/bin/sqlite3 /home/$Domain/sqlite/$Name.db "INSERT INTO SQLite (Version,TimeStamp) VALUES ('$SQLiteVersion','$TimeStamp')"
    fi

    sudo /usr/bin/chmod -R 777 /home/$Domain/sqlite
    sudo /usr/bin/chown -R $Username:$Username /home/$Domain/sqlite

    Pass=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

    sudo /usr/bin/sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "INSERT INTO SQLite (Name,Domain,Username,Pass,TimeStamp) VALUES ('$Name','$Domain','$Username','$Pass','$TimeStamp')"

    echo "Database $Name created successfully..."

fi
