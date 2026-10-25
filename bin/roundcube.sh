#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

V=$1

Hostname=$(</etc/hostname)

if sudo test -f "/var/lib/sqlite/config.db" ; then
    IMAPHostname=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select IMAPHostname from Config where ConfigID=1")
fi

RoundcubeDBPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
sudo mariadb -e "GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost' IDENTIFIED BY '$RoundcubeDBPassword';"

if [ "$V" = "" ] || [ "$V" = "--silent" ] || [ "$V" = "--ssl" ] || [ "$V" = "--mysql" ] || [ "$V" = "--sqlite" ]; then
    V="1.6.19"
fi

ProgressBar "Installing Roundcube $V Webmail"

sudo rm -rf /usr/local/goadmio/home/go/webmail/roundcube
sudo mkdir -p /usr/local/goadmio/home/go/webmail
cd /usr/local/goadmio/home/go/webmail
sudo rm -rf *.tar.gz
sudo curl -s -L "https://github.com/roundcube/roundcubemail/releases/download/$V/roundcubemail-$V-complete.tar.gz" | sudo tee /usr/local/goadmio/home/go/webmail/roundcube-latest.tar.gz >/dev/null
sudo rm -rf roundcubemail*
sudo tar -zxf roundcube-latest.tar.gz
sudo rm -rf roundcube-latest.tar.gz
sudo mv roundcubemail* roundcube

sudo mariadb -e "CREATE DATABASE IF NOT EXISTS roundcube"
sudo mariadb -uroundcube -p"$RoundcubeDBPassword" roundcube < /usr/local/goadmio/home/go/webmail/roundcube/SQL/mysql.initial.sql 2>/dev/null

# sqlite3 -init /usr/local/goadmio/home/go/webmail/roundcube/SQL/sqlite.initial.sql /usr/local/goadmio/home/go/webmail/roundcube/roundcube.db <<< ".quit"

echo "<?php" | sudo tee /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config = [];" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

if [[ $@ = *"--sqlite"* ]]; then
    echo "\$config['db_dsnw'] = 'sqlite:////usr/local/goadmio/home/go/webmail/roundcube/roundcube.db?mode=0646';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
else
    echo "\$config['db_dsnw'] = 'mysql://roundcube:$RoundcubeDBPassword@localhost/roundcube';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
fi

if [ "$IMAPHostname" = "" ]; then

    echo "\$config['default_host'] = 'localhost';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_user'] = '%u';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_pass'] = '%p';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

elif [ "$IMAPHostname" = "[Domain]" ]; then

    echo "\$config['default_host'] = '%s';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_user'] = '';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_pass'] = '';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

elif [[ "$IMAPHostname" = *"."* ]]; then

    echo "\$config['default_host'] = '%s';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_user'] = '';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_pass'] = '';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

else

    echo "\$config['default_host'] = 'localhost';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_user'] = '%u';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_pass'] = '%p';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

fi

if sudo test -d "/etc/letsencrypt/live/$Hostname"  && [[ $@ = *"--ssl"* ]]; then

    echo "\$config['smtp_server'] = 'ssl://$Hostname';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_port'] = 465;" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

else

    echo "\$config['smtp_server'] = 'localhost';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
    echo "\$config['smtp_port'] = 587;" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

fi

echo "\$config['support_url'] = '';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['product_name'] = 'Roundcube Webmail';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['des_key'] = 'rcmail-!24ByteDESkey*Str';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['plugins'] = ['archive','zipdownload',];" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['skin'] = 'elastic';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

echo "\$config['drafts_mbox'] = 'Drafts';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['junk_mbox'] = 'Junk';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['sent_mbox'] = 'Sent';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['trash_mbox'] = 'Trash';" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null
echo "\$config['create_default_folders'] = true;" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

echo "include \"/usr/local/goadmio/home/go/webmail/brevo.php\";" | sudo tee -a /usr/local/goadmio/home/go/webmail/roundcube/config/config.inc.php >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo chown 755 -R /usr/local/goadmio/home/go/webmail/roundcube
    sudo chown apache:apache -R /usr/local/goadmio/home/go/webmail/roundcube

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo chown 755 -R /usr/local/goadmio/home/go/webmail/roundcube
    sudo chown www-data:www-data -R /usr/local/goadmio/home/go/webmail/roundcube

fi

sudo rm -rf /usr/local/goadmio/home/go/webmail/roundcube/login.php
sudo cp /usr/local/goadmio/home/go/webmail/roundcube-login.php /usr/local/goadmio/home/go/webmail/roundcube/login.php

sudo rm -rf /usr/local/goadmio/home/go/webmail/roundcube/installer
