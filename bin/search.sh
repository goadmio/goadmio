#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="mls.eg"
Database="mls"
Table="Mls"

if sudo test -d /home/$Domain/www ; then

    sudo mariadb -e "SELECT EnItem FROM $Database.$Table" | sudo tee /home/$Domain/www/title.txt >/dev/null
    sudo mariadb -e "SELECT ArItem FROM $Database.$Table" | sudo tee -a /home/$Domain/www/title.txt >/dev/null

    sudo mariadb -e "SELECT EnDistrict FROM $Database.District" | sudo tee -a /home/$Domain/www/title.txt >/dev/null
    sudo mariadb -e "SELECT ArDistrict FROM $Database.District" | sudo tee -a /home/$Domain/www/title.txt >/dev/null

    sudo mariadb -e "SELECT EnCity FROM $Database.City" | sudo tee -a /home/$Domain/www/title.txt >/dev/null
    sudo mariadb -e "SELECT ArCity FROM $Database.City" | sudo tee -a /home/$Domain/www/title.txt >/dev/null

    tr -s '[:space:]' '\n' </home/$Domain/www/title.txt | tr -d '[:punct:]' | sort -u >/home/$Domain/www/search.txt

    sudo rm -rf home/$Domain/www/title.txt

fi
