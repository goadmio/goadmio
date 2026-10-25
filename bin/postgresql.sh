#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)

ProgressBar "Installing PostgreSQL"

echo "Installing PostgreSQL..."

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Install PostgreSQL
    sudo dnf -y install postgresql-server
    sudo dnf -y install postgresql-contrib
    postgresql-setup initdb

    sudo sed -i "s/#port = 5432/port = 5432/g" /var/lib/pgsql/data/postgresql.conf

    sudo systemctl start postgresql
    sudo systemctl enable postgresql

    sudo firewall-cmd --zone=public --add-service=postgresql --permanent

    if sudo test ! -f /var/lib/pgsql/data/postgresql.bak ; then
        sudo cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.bak
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt -y install postgresql
    sudo apt -y install postgresql-contrib

    sudo systemctl start postgresql
    sudo systemctl enable postgresql

fi
