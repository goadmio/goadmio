#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

cd /tmp

https://sqlite.org/2026/sqlite-amalgamation-3530400.zip

sudo wget https://www.sqlite.org/2026/sqlite-src-3530400.zip -q -t 1 -T 20 --no-check-certificate
sudo unzip sqlite-src-3530400.zip
cd sqlite-src-3530400

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    ./configure
    sudo make
    sudo make install

    if sudo test -f sqlite3 ; then
        sudo /usr/bin/install sqlite3 "/usr/bin"
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    ./configure
    sudo make
    sudo make install

    if sudo test -f sqlite3 ; then
        sudo /usr/bin/install sqlite3 "/usr/bin"
    fi

fi
