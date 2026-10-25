#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Name=$2
User=$3
Pass=$4
Directory=$5
ScriptLanguage=$6

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

sudo curl -L "https://www.drupal.org/download-latest/tar.gz" >$Directory/drupal.tar.gz
sudo tar -zxf $Directory/drupal.tar.gz -C $Directory
sudo rm -f $Directory/drupal.tar.gz

sudo mv $Directory/drupal-* $Directory/drupal

sudo cp $Directory/drupal/sites/default/default.settings.php $Directory/drupal/sites/default/settings.php
sudo chmod 777 $Directory/drupal/sites/default/settings.php
sudo chmod 777 $Directory/drupal/sites/default

if [ "$Home" = "y" ]; then

    sudo mv $Directory/drupal/* $Directory
    sudo rm -rf $Directory/drupal

    sudo chmod 777 -R $Directory

    echo "drupal installed on URL http://$Username"

else

    if [ "$Path" = "drupal" ]; then

        sudo chmod 777 -R $Directory/drupal

        echo "drupal installed on URL http://$Username/drupal"

    else

        sudo mv $Directory/drupal $Directory/$Path

        sudo chmod 777 -R $Directory/$Path

        echo "drupal installed on URL http://$Domain/$Path"

    fi

fi
