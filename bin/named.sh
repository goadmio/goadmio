#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/named "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1
OS=$(</usr/local/goadmio/linux/os.db)

if [ "$Action" = "restart" ]; then

    if sudo test ! -f /etc/nameservers ; then

        echo "Please Setup a Nameserver."

        exit 1

    fi

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo systemctl daemon-reload
        sudo systemctl restart named

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo systemctl daemon-reload
        sudo systemctl restart bind9

    fi

    exit 1

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y remove bind bind-utils
    sudo dnf -y install bind bind-utils

    sudo systemctl enable named
    sudo systemctl restart named

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt-get remove -y bind9

    sudo apt-get install -y bind9
    sudo systemctl enable bind9
    sudo systemctl restart bind9

fi

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "DELETE from Zone where Domain='$Domain'"

        sudo /go/zone $Domain

    fi

done
