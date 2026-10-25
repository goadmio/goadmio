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

sudo curl -K -L "https://script.goadmio.com/litecart-2.2.zip" >$Directory/litecart-2.2.zip
sudo unzip -q $Directory/litecart-2.2.zip -d $Directory
sudo rm -f $Directory/litecart-2.2.zip
sudo mv $Directory/litecart-* $Directory/litecart

sudo find $Directory/litecart -type d | xargs chmod 777 &>/dev/null
sudo find $Directory/litecart -type f | xargs chmod 777 &>/dev/null

echo "MySQL Hostname: localhost"
echo "MySQL Database Name: $Name"
echo "MySQL Database User: $User"
echo "MySQL Database Pass: $Pass"

if [ "$Home" = "y" ]; then

    sudo mv $Directory/litecart/* $Directory
    sudo rm -rf $Directory/litecart

    sudo chmod 777 -R $Directory

    echo "litecart installed on URL http://$Username"

else

    if [ "$Path" = "litecart" ]; then

        sudo chmod 777 -R $Directory/litecart

        echo "litecart installed on URL http://$Username/litecart"

    else

        sudo mv $Directory/litecart $Directory/$Path

        sudo chmod 777 -R $Directory/$Path

        echo "litecart installed on URL http://$Domain/$Path"

    fi

fi
