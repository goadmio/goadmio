#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test -f /var/log/mysql.log ; then

    LogSize=$(stat -c %s /var/log/mysql.log)
    Seconds=$(($(date +%s) - $(stat -c %Y /var/log/mysql.log)))

    if [[ "$LogSize" -gt "10" ]] && [[ "$Seconds" -lt "3600" ]]; then

        sudo rm -rf /usr/local/goadmio/tmp/mysql.log
        sudo cp /var/log/mysql.log /usr/local/goadmio/tmp/

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

sudo sed -i "s/ WHERE / where /g" /usr/local/goadmio/tmp/mysql.log
sudo sed -i "s/ AND / and /g" /usr/local/goadmio/tmp/mysql.log
sudo sed -i "s/ OR / or /g" /usr/local/goadmio/tmp/mysql.log
sudo sed -i "s/ ORDER BY / order by /g" /usr/local/goadmio/tmp/mysql.log

sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $3}' | sort -u >/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $5}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $7}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $9}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) and [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $11}' | sort -u >>/usr/local/goadmio/tmp/index.db

sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $5}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $7}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $9}' | sort -u >>/usr/local/goadmio/tmp/index.db
sudo grep -oP "[a-zA-Z0-9_]+ where [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+=(\'[^']+\'|''|[0-9]+) or [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $11}' | sort -u >>/usr/local/goadmio/tmp/index.db

# Index ORDER BY
sudo grep -oP "[a-zA-Z0-9_]+ where [^#]+ order by [a-zA-Z0-9_]+" /usr/local/goadmio/tmp/mysql.log | awk '{print $1 "|" $NF}' | sort -u >/usr/local/goadmio/tmp/index.db

# Remove Dublcates
sort -u /usr/local/goadmio/tmp/index.db >/usr/local/goadmio/tmp/columns.db

SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name!='mysql' and schema_name!='sys' and schema_name!='information_schema' and schema_name!='performance_schema' and schema_name!='roundcube' and schema_name!='opendmarc';")
for Database in $SQL; do

    File="/usr/local/goadmio/tmp/columns.db"
    while IFS= read String; do

        IFS='|' read -r -a Array <<<"$String"

        Table="${Array[0]}"
        Field="${Array[1]}"

        Table=$(echo "$Table" | sed "s/[^a-zA-Z0-9]//g")
        Field=$(echo "$Field" | sed "s/[^a-zA-Z0-9]//g")

        IndexName=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT INDEX_NAME FROM information_schema.statistics WHERE table_schema = '$Database' AND table_name = '$Table' AND column_name = '$Field';")
        TableExists=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT TABLE_NAME from information_schema.columns where table_schema = '$Database' AND table_name = '$Table' AND column_name = '$Field';")

        if [ "$IndexName" = "" ] && [ "$TableExists" != "" ]; then

            if [ "$Table" = "$TableExists" ]; then

                echo "ALTER TABLE $Database.$Table ADD INDEX $Field ($Field)"
                sudo mariadb -e "ALTER TABLE $Database.$Table ADD INDEX $Field ($Field)"

            fi

        fi

    done <"$File"

done
