#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
ScriptFile=$2
Directory=$3
Name=$4
User=$5
Pass=$6
ScriptID=$7

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

ScriptName=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select ScriptName from Script where ScriptID='$ScriptID'")
GithubName=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select GithubName from Script where ScriptID='$ScriptID'")
ScriptVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select ScriptVersion from Script where ScriptID='$ScriptID'")
URL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select URL from Script where ScriptID='$ScriptID'")
Folder=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select Folder from Script where ScriptID='$ScriptID'")
Command=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/script.db "select Command from Script where ScriptID='$ScriptID'")

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

if [[ "$GithubName" = *"/"* ]]; then

    sudo mkdir -p $Directory
    cd $Directory

    sudo rm -rf .git
    sudo rm -rf .gitignore
    sudo rm -rf .gitattributes

    if [ "$Command" = "" ]; then

        sudo screen -d -m bash -c "cd $Directory ; git clone https://github.com/$GithubName --depth 1 . ; /usr/bin/composer -n install ; /go/fix $Domain"

    else

        Command=$(echo "$Command" | sed "s|\[Domain\]|$Domain|g")
        Command=$(echo "$Command" | sed "s|\[Directory\]|$Directory|g")
        Command=$(echo "$Command" | sed "s|\[GithubName\]|$GithubName|g")

        sudo screen -d -m bash -c "$Command"

    fi

    URL=$(echo "https://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")

    if [ "$Folder" = "" ]; then
        echo "$ScriptName $ScriptVersion installed on URL: $URL"
    else
        echo "$ScriptName $ScriptVersion installed on URL: $URL/$Folder"
    fi

    exit 1

elif [[ "$URL" = *".tar.gz" ]]; then

    sudo curl -s -L "$URL" >$Directory/$ScriptFile.tar.gz

    cd $Directory
    sudo tar --strip 1 -zxf $Directory/$ScriptFile.tar.gz
    sudo rm -rf $Directory/$ScriptFile.tar.gz

elif [[ "$URL" = *".tar.bz2" ]]; then

    sudo curl -s -L "$URL" >$Directory/$ScriptFile.tar.bz2

    cd $Directory
    sudo tar --strip 1 -xf $Directory/$ScriptFile.tar.bz2
    sudo rm -rf $Directory/$ScriptFile.tar.bz2

elif [[ "$URL" = *".zip" ]]; then

    sudo curl -s -L "$URL" >$Directory/$ScriptFile.zip

    cd $Directory
    sudo unzip $ScriptFile.zip
    sudo rm -rf $Directory/$ScriptFile.zip

fi

if [ "$ScriptFile" = "wordpress" ]; then

    sudo cp $Directory/wp-config-sample.php $Directory/wp-config.php

    # EN & AR
    sudo sed -i "s/database_name_here/$Name/g" $Directory/wp-config.php
    sudo sed -i "s/username_here/$User/g" $Directory/wp-config.php
    sudo sed -i "s/password_here/$Pass/g" $Directory/wp-config.php

    # FR
    sudo sed -i "s/votre_nom_de_bdd/$Name/g" $Directory/wp-config.php
    sudo sed -i "s/votre_utilisateur_de_bdd/$User/g" $Directory/wp-config.php
    sudo sed -i "s/votre_mdp_de_bdd/$Pass/g" $Directory/wp-config.php

    # DE
    sudo sed -i "s/datenbankname_hier_einfuegen/$Name/g" $Directory/wp-config.php
    sudo sed -i "s/benutzername_hier_einfuegen/$User/g" $Directory/wp-config.php
    sudo sed -i "s/passwort_hier_einfuegen/$Pass/g" $Directory/wp-config.php

    # IT
    sudo sed -i "s/nome_del_database_qui/$Name/g" $Directory/wp-config.php
    sudo sed -i "s/nome_utente_qui/$User/g" $Directory/wp-config.php
    sudo sed -i "s/password_qui/$Pass/g" $Directory/wp-config.php

    # TR
    sudo sed -i "s/veritabaniismi/$Name/g" $Directory/wp-config.php
    sudo sed -i "s/kullaniciadi/$User/g" $Directory/wp-config.php
    sudo sed -i "s/parola/$Pass/g" $Directory/wp-config.php

fi

if [ "$ScriptFile" = "zen-cart" ]; then

    sudo mv $Directory/includes/dist-configure.php $Directory/includes/configure.php

    sudo sed -i "s/'DB_SERVER_User', ''/'DB_SERVER_User', '$User'/g" $Directory/includes/configure.php
    sudo sed -i "s/'DB_SERVER_Pass', ''/'DB_SERVER_Pass', '$Pass'/g" $Directory/includes/configure.php
    sudo sed -i "s/'DB_DATABASE', ''/'DB_DATABASE', '$Name'/g" $Directory/includes/configure.php

    # echo "To begin installation: http://$Username/zc_install/index.php"

    fix $Domain
    URL=$(echo "http://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")
    echo "$ScriptName $ScriptVersion To begin installation: $URL/zc_install/index.php"

    exit 1

fi

if [ "$ScriptFile" = "xmb" ]; then

    fix $Domain
    URL=$(echo "http://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")
    echo "$ScriptName $ScriptVersion To begin installation: $URL/install"

    exit 1

fi

if [ "$ScriptFile" = "htmly" ] || [ "$ScriptFile" = "cmsms" ]; then

    sudo chmod 777 -R $Directory
    URL=$(echo "http://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")
    echo "$ScriptName $ScriptVersion To begin installation: $URL/install.php"

    exit 1

fi

if [ "$ScriptFile" = "winter" ]; then

    sudo chmod 777 -R $Directory
    URL=$(echo "http://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")
    echo "$ScriptName $ScriptVersion To begin installation: $URL/install.html"

    exit 1

fi

sudo screen -d -m bash -c "/go/fix $Domain"
URL=$(echo "http://${Domain}${Directory}" | sed "s/\/home\/$Domain\/www//g")
echo "$ScriptName $ScriptVersion installed on URL: $URL"
