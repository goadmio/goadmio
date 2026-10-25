#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

sudo rm -rf /usr/local/ioncube
sudo rm -rf ioncube_loaders_lin_x86-64.tar.gz
sudo wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz &>/dev/null
sudo tar xzf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local

# GET All PHP INI PATH (Used to get cuurent timezone next)
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    cd /etc/opt/remi
    for Version in *; do

        # Keep Numbers Only
        V=$(echo "$Version" | sed 's/[^0-9]*//g')

        # first Character & Second Character
        F=${V:0:1}
        S=${V:1:1}

        ionCubeVersion="$F.$S"

        # FPM
        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            PHPINI="/etc/opt/remi/$Version/php.ini"

            if sudo test -f /usr/local/ioncube/ioncube_loader_lin_$ionCubeVersion.so ; then

                if grep -q "ioncube_loader_lin_$ionCubeVersion.so" $PHPINI; then

                    echo "ionCube loader PHP $ionCubeVersion already installed (FPM)."

                else

                    Restart=1

                    echo "Installing ionCube loader PHP $ionCubeVersion (FPM)..."
                    echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_$ionCubeVersion.so" >>$PHPINI

                fi

            fi

        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php
    for Version in *; do

        # FPM
        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            PHPINI="/etc/php/$Version/fpm/php.ini"

            if sudo test -f /usr/local/ioncube/ioncube_loader_lin_$Version.so ; then

                if grep -q "ioncube_loader_lin_$Version.so" $PHPINI; then

                    echo "ionCube loader PHP $Version already installed (FPM)."

                else

                    Restart=1

                    echo "Installing ionCube loader PHP $Version (FPM)..."
                    echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_$Version.so" >>$PHPINI

                fi

            fi

        fi

        # CLI
        if sudo test -f "/etc/php/$Version/cli/php.ini" ; then

            PHPINI="/etc/php/$Version/cli/php.ini"

            if sudo test -f /usr/local/ioncube/ioncube_loader_lin_$Version.so ; then

                if grep -q "ioncube_loader_lin_$Version.so" $PHPINI; then

                    echo "ionCube loader PHP $Version already installed (CLI)."

                else

                    Restart=1

                    echo "Installing ionCube loader PHP $Version (CLI)..."
                    echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_$Version.so" >>$PHPINI

                fi

            fi

        fi

    done

elif [ "$OS" = "OpenSUSE" ]; then

    cd /etc/php
    for Version in *; do

        if sudo test -f "/etc/$Version/cli/php.ini" ; then

            PHPINI="/etc/$Version/cli/php.ini"

        fi

    done

fi

sudo rm -rf ioncube_loaders_lin_x86-64.tar.gz

if [ "$Restart" = "1" ]; then

    sudo /go/fpm "| Executed by $(basename "$0")"

fi
