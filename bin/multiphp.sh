#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/multiphp "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
PHPVersion=$2

OS=$(</usr/local/goadmio/linux/os.db)

if [ "${1,,}" = "return" ]; then

    PHPVersion=""

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        cd /etc/opt/remi
        for Version in *; do

            if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

                if [ "$PHPVersion" = "" ]; then
                    PHPVersion="$Version"
                else
                    PHPVersion="$PHPVersion|$Version"
                fi
            fi

        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        cd /etc/php
        for Version in *; do

            if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

                if [ "$PHPVersion" = "" ]; then
                    PHPVersion="$Version"
                else
                    PHPVersion="$PHPVersion|$Version"
                fi
            fi

        done

    else
        echo "Unknown operating system."
        exit
    fi

    echo "$PHPVersion"

    exit 1

fi

# GET Last PHP Version
if [ "$PHPVersion" = "" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        cd /etc/opt/remi
        for Version in *; do

            if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

                PHPVersion="$Version"

            fi

        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        cd /etc/php
        for Version in *; do

            if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

                PHPVersion="$Version"

            fi

        done

    else
        echo "Unknown operating system."
        exit
    fi

fi

if sudo test ! -d /etc/opt/remi/$PHPVersion && sudo test ! -d /etc/php/$PHPVersion; then

    echo "Installed PHP Versions:"
    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        ls -1 /etc/opt/remi
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
        ls -1 /etc/php
    fi

    exit 1
fi

if [ "$1" = "all" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain ; then

            N=$(($N + 1))

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET PHPVersion='$PHPVersion' where Domain='$Domain'"

            # Create VHOST CONF
            sudo /go/apache $Domain
            sudo /go/nginx $Domain

            # Recreate POOL
            sudo /go/php-fpm $Domain

            echo "[$N/$C] PHP Version for $Domain changed to $PHPVersion"

        fi

    done

    sudo /go/reload "| Executed by $(basename "$0")"

    exit 1

fi

DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")

if [[ ! "$DomainExists" = "$Domain" ]]; then
    echo "Domain $Domain not exists"
    exit 1
fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET PHPVersion='$PHPVersion' where Domain='$Domain'"

# Create VHOST CONF
sudo /go/apache $Domain
sudo /go/nginx $Domain

# Recreate POOL
sudo /go/php-fpm $Domain

sudo /go/reload "| Executed by $(basename "$0")"

echo "PHP Version for $Domain changed to $PHPVersion"
