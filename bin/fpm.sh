#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

Memory=$(($(echo "$1" | tr -cd '0-9')))

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    VersionPath="/etc/opt/remi"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    VersionPath="/etc/php"
fi

if [ "$Memory" -ge "1" ]; then

    # Check Memory Usage
    MemoryUsage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    MemoryUsage=${MemoryUsage%.*}

    if [ ! "$MemoryUsage" -ge "$Memory" ]; then
        exit 1
    fi

fi

if [ $# -eq 0 ]; then

    sudo /go/checknginx
    sudo /go/checkapache

    cd $VersionPath
    for Version in *; do

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
            PoolDir="/etc/opt/remi/$Version/php-fpm.d"
        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
            PoolDir="/etc/php/$Version/fpm/pool.d"
        fi

        if sudo test -d "$PoolDir" ; then

            cd $PoolDir
            for File in *; do

                Domain=${File/.conf/}

                if [[ "$Domain" = *"."* ]]; then

                    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                        if sudo test ! -f "/etc/httpd/vhost/$File" ; then
                            sudo /go/php-fpm $Domain delete
                        fi

                    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                        if sudo test ! -f "/etc/apache2/vhost/$File" ; then
                            sudo /go/php-fpm $Domain delete
                        fi

                    fi

                    if sudo test ! -d "/home/$Domain" ; then
                        sudo /go/php-fpm $Domain delete
                    fi

                fi

            done

        fi

    done

    if [ "$WS" = "Apache" ]; then

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
            VHOST="/etc/httpd/vhost"
        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
            VHOST="/etc/apache2/vhost"
        fi

        cd $VHOST

        for File in *; do

            if [[ "$File" = *"-le-ssl.conf"* ]]; then

                Domain=$(echo "$File" | sed 's/-le-ssl.conf//')

                if sudo test ! -f "/etc/letsencrypt/live/$Domain/cert.pem"  && sudo test ! -f "/etc/ssl/$Domain/cert.pem" ; then

                    sudo rm -rf $VHOST/$Domain-le-ssl.conf

                fi

            fi

        done

    fi

    sudo /go/checkphpini &>/dev/null

    # Create Sock Folders
    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        sudo find /etc/opt/remi -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sed 's/[^0-9]//g' | while read Dir; do [ -n "$Dir" ] && sudo mkdir -p "/run/sock/$Dir"; done
    else
        sudo find /etc/php -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sed 's/[^0-9]//g' | while read Dir; do [ -n "$Dir" ] && sudo mkdir -p "/run/sock/$Dir"; done
    fi
    sudo chmod 755 -R /run/sock

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [[ "$@" = *"reload"* ]]; then
        sudo systemctl reload php-fpm
    else
        sudo systemctl restart php-fpm
    fi

    cd /etc/opt/remi
    for Version in *; do

        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

            if [[ "$@" = *"enable"* ]]; then

                sudo mkdir -p /etc/systemd/system/$Version-php-fpm.service.d
                echo "[Service]" | sudo tee /etc/systemd/system/$Version-php-fpm.service.d/override.conf >/dev/null
                echo "RuntimeDirectory=sock/$SockFolder" | sudo tee -a /etc/systemd/system/$Version-php-fpm.service.d/override.conf >/dev/null
                echo "RuntimeDirectoryMode=0755" | sudo tee -a /etc/systemd/system/$Version-php-fpm.service.d/override.conf >/dev/null

                sudo systemctl daemon-reload
                sudo systemctl enable ${Version}-php-fpm
                sudo systemctl restart ${Version}-php-fpm

            elif [[ "$@" = *"reload"* ]]; then

                sudo systemctl reload ${Version}-php-fpm

            else

                sudo systemctl restart ${Version}-php-fpm

            fi

        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # Restart FPM
    cd /etc/php
    for Version in *; do

        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

            if [[ "$@" = *"enable"* ]]; then

                sudo mkdir -p /etc/systemd/system/php$Version-fpm.service.d
                echo "[Service]" | sudo tee /etc/systemd/system/php$Version-fpm.service.d/override.conf >/dev/null
                echo "RuntimeDirectory=sock/$SockFolder" | sudo tee -a /etc/systemd/system/php$Version-fpm.service.d/override.conf >/dev/null
                echo "RuntimeDirectoryMode=0755" | sudo tee -a /etc/systemd/system/php$Version-fpm.service.d/override.conf >/dev/null

                sudo systemctl daemon-reload
                sudo systemctl enable php${Version}-fpm
                sudo systemctl restart php${Version}-fpm

            elif [[ "$@" = *"reload"* ]]; then

                sudo systemctl reload php$Version-fpm

            else

                sudo systemctl restart php${Version}-fpm

            fi

        fi

    done

fi
