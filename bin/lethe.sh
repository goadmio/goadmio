#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Name=$2
User=$3
Pass=$4
Directory=$5
ScriptLanguage=$6

Pass=$(echo "${Pass//\[DollarSign\]/$}")
Pass=$(echo "${Pass//\[AndSign\]/&}")
Pass=$(echo "${Pass//\[EqualSign\]/=}")
Pass=$(echo "${Pass//\[HashSign\]/#}")

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ $# -eq 0 ]; then

    exit 1

fi

DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
if [ "$Name" = "$DatabaseExists" ]; then
    echo "Database '$Name' already exists."
    exit 1
fi

if [[ "$Directory" = *"/www" ]] && sudo test -f "$Directory/index.php" ; then

    echo "Home directory is not empty."
    exit 1

fi

# Create Database
sudo /go/mysql $Domain $Name $User $Pass

sudo curl -K -L "https://script.goadmio.com/lethe.zip" >$Directory/lethe.zip
sudo unzip -q $Directory/lethe.zip -d $Directory
sudo rm -f $Directory/lethe.zip
# mv $Directory/lethe-* $Directory/lethe

sudo find $Directory/lethe -type d | xargs chmod 777 &>/dev/null
sudo find $Directory/lethe -type f | xargs chmod 777 &>/dev/null

sudo mariadb -uroot -p$MySQLRootPassword $Name <$Directory/lethe/lethe_v2_2.sql

if [ "$Home" = "y" ]; then

    sudo mv $Directory/lethe/* $Directory
    sudo rm -rf $Directory/lethe

    sudo chmod 777 -R $Directory

    echo "Click Here to Install Lethe Mailing System: http://$Username/install.php"

else

    if [ "$Path" = "lethe" ]; then

        sudo chmod 777 -R $Directory/lethe

        echo "Click Here to Install Lethe Mailing System: http://$Username/lethe/install.php"

    else

        sudo mv $Directory/lethe $Directory/$Path

        sudo chmod 777 -R $Directory/$Path

        echo "Click Here to Install Lethe Mailing System: http://$Domain/$Path/install.php"

    fi

fi
