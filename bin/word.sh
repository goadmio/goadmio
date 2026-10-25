#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Domain="mls.eg"
Database="mls"
Table="Mls"

sudo mkdir -p /home/$Domain/www/word

sudo mariadb -uroot -p$MySQLRootPassword -e "SELECT EnItem FROM $Database.$Table" | sudo tee /home/$Domain/www/word/temp-en.txt >/dev/null
sudo mariadb -uroot -p$MySQLRootPassword -e "SELECT ArItem FROM $Database.$Table" | sudo tee /home/$Domain/www/word/temp-ar.txt >/dev/null

tr -s '[:space:]' '\n' </home/$Domain/www/word/temp-en.txt | tr -d '[:punct:]' | sort -u >/home/$Domain/www/word/en.txt
tr -s '[:space:]' '\n' </home/$Domain/www/word/temp-ar.txt | tr -d '[:punct:]' | sort -u >/home/$Domain/www/word/ar.txt
