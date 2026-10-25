#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

# pgloader (Convert MySQL Database to PostgreSQL Database)
# pgloader mysql://username:password@localhost/your_database postgresql://username:password@localhost/your_new_database

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    sudo dnf -y install pgloader

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt -y install pgloader

fi
