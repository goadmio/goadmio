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

# Install Elasticsearch
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[Elasticsearch-7]" | sudo tee /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "name=Elasticsearch repository for 7.xpackages" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo >/dev/null
sudo yum -y install elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

cd $Directory

if [ "$Theme" = "Minimog" ]; then

    # Install Magento2.4.4 + Minimog Theme
    sudo wget https://script.goadmio.com/magento2.4.4-minimog-theme.zip
    sudo unzip magento2.4.4-minimog-theme.zip
    rsync -azlh $Directory/magento/ $Directory/

    sudo /go/fix $Username

    # $Directory/app/etc/env.php

    mysql magento <db.sql
    sudo mariadb -e "SET @salt = MD5(UNIX_TIMESTAMP());UPDATE magento.admin_user SET password=CONCAT(SHA2(CONCAT(@salt, 'dragon4U'), 256), ':', @salt, ':1') WHERE username = 'admin';"
    sudo mariadb -e "SET @salt = MD5(UNIX_TIMESTAMP());UPDATE magento.admin_user SET password=CONCAT(SHA2(CONCAT(@salt, 'dragon4U'), 256), ':', @salt, ':1') WHERE username = 'admin123';"
    sudo mariadb -e "SET @salt = MD5(UNIX_TIMESTAMP());UPDATE magento.admin_user SET password=CONCAT(SHA2(CONCAT(@salt, 'dragon4U'), 256), ':', @salt, ':1') WHERE username = 'admin_dev';"

    echo "Domain=\"$Domain\"" >setup.sh
    echo "mariadb -e \"update magento.core_config_data set value='http://\$Domain/' where path='web/unsecure/base_url';\"" >>setup.sh
    echo "mariadb -e \"update magento.core_config_data set value='https://\$Domain/' where path='web/secure/base_url';\"" >>setup.sh
    echo "php bin/magento cache:flush" >>setup.sh
    echo "php bin/magento indexer:reindex" >>setup.sh
    echo "php bin/magento setup:upgrade" >>setup.sh
    echo "php bin/magento setup:static-content:deploy -f" >>setup.sh
    echo "chmod 777 -R pub var generated" >>setup.sh
    echo "" >>setup.sh
    echo "Version=\$(</home/\$Domain/www/pub/static/deployed_version.txt)" >>setup.sh
    echo "" >>setup.sh
    echo "mkdir -p /home/\$Domain/www/pub/static/version\$Version/frontend" >>setup.sh
    echo "mkdir -p /home/\$Domain/www/pub/static/version\$Version/adminhtml" >>setup.sh
    echo "" >>setup.sh
    echo "rsync -azlh /home/\$Domain/www/pub/static/frontend/ /home/\$Domain/www/pub/static/version\$Version/frontend/" >>setup.sh
    echo "rsync -azlh /home/\$Domain/www/pub/static/adminhtml/ /home/\$Domain/www/pub/static/version\$Version/adminhtml/" >>setup.sh

else

    sudo wget https://github.com/magento/magento2/archive/2.4.5.zip
    sudo unzip 2.4.5.zip
    rsync -azlh $Directory/magento2-2.4.5/ $Directory/

    composer install
    sudo mariadb -e "drop database magento"
    sudo mariadb -e "create database magento"
    sudo php bin/magento setup:install --admin-firstname="Khaled" --admin-lastname="Mamdouh" --admin-email="info@mls.eg" --admin-user="admin" --admin-password="dragon4@" --db-name="magento" --db-host="localhost" --db-user="root" --db-password="izxgTVIRJkT5XFv"
    # php bin/magento deploy:mode:set developer

    sudo /go/fix $Username

    sudo chmod 777 -R var generated app/etc
    sudo rm -rf var/cache/* var/page_cache/* var/generation/*

    sudo mariadb -e "SET @salt = MD5(UNIX_TIMESTAMP());UPDATE magento.admin_user SET $(password) = CONCAT(SHA2(CONCAT(@salt, 'dragon4U'), 256), ':', @salt, ':1') WHERE username = 'admin';"
    sudo mariadb -e "SET @salt = MD5(UNIX_TIMESTAMP());UPDATE magento.admin_user SET $(password) = CONCAT(SHA2(CONCAT(@salt, 'dragon4U'), 256), ':', @salt, ':1') WHERE username = 'admin_dev';"

fi

if [ "$Home" = "y" ]; then

    rsync -azlh $Directory/magento/ $Directory/
    sudo rm -rf $Directory/magento

    sudo chmod 777 -R $Directory

    echo "magento installed on URL http://$Domain"

else

    if [ "$Path" = "magento" ]; then

        sudo chmod 777 -R $Directory/magento

        echo "magento installed on URL http://$Domain/magento"

    else

        sudo mv $Directory/magento $Directory/$Path

        sudo chmod 777 -R $Directory/$Path

        echo "magento installed on URL http://$Domain/$Path"

    fi

fi
