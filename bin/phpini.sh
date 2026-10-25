#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1

OS=$(</usr/local/goadmio/linux/os.db)

if [ "$Action" = "backup" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        Dir="/etc"
        cd /etc/opt/remi
        for Version in *; do
            Dir="$Dir|/etc/opt/remi/$Version"
        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        Dir="/etc"
        cd /etc/php
        for Version in *; do
            Dir="$Dir|/etc/php/$Version/fpm|/etc/php/$Version/cli|/etc/php/$Version/apache2"
        done

    elif [ "$OS" = "OpenSUSE" ]; then

        Dir="/etc"
        cd /etc/php
        for Version in *; do
            Dir="$Dir|/etc/$Vesrion/cli"
        done

    else
        echo "Unknown operating system."
        exit
    fi

    DirArray=$(echo $Dir | tr "|" "\n")

    for Dir in $DirArray; do

        if sudo test -d "$Dir" ; then

            if sudo test -f "$Dir/php.ini" ; then

                sudo cp $Dir/php.ini $Dir/php.bak

            fi

        fi

    done

    exit 1

fi

if [ "$Action" = "restore" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        Dir="/etc"
        cd /etc/opt/remi
        for Version in *; do
            Dir="$Dir|/etc/opt/remi/$Version"
        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        Dir="/etc"
        cd /etc/php
        for Version in *; do
            Dir="$Dir|/etc/php/$Version/fpm|/etc/php/$Version/cli|/etc/php/$Version/apache2"
        done

    else
        echo "Unknown operating system."
        exit
    fi

    DirArray=$(echo $Dir | tr "|" "\n")

    for Dir in $DirArray; do

        if sudo test -d "$Dir" ; then

            if sudo test -f "$Dir/php.bak" ; then

                sudo rm -rf $Dir/php.ini
                sudo cp $Dir/php.bak $Dir/php.ini

            fi

        fi

    done

    sudo /go/reload "| Executed by $(basename "$0")"

    exit 1

fi

# php.ini default values
sudo /go/disablefunctions
sudo /go/displayerrors On
sudo /go/mailaddxheader On
sudo /go/memorylimit
sudo /go/errorreporting
sudo /go/postmaxsize 64M
sudo /go/maxexecutiontime 600
sudo /go/maxinputtime 600
sudo /go/maxinputvars 3000
sudo /go/uploadmaxfilesize 64M
sudo /go/maxfileuploads 100
sudo /go/sessiongcmaxlifetime
sudo /go/sessioncookielifetime
sudo /go/directoryindex default.html index.html index.php go.html

# Secure Cron Jobs (php)
sudo /go/disablefunctions-cli

# Disable custom php.ini
sudo /go/userini

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    Dir="/etc"
    cd /etc/opt/remi
    for Version in *; do

        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            Session=$(echo "$Version" | sed 's/[^0-9]*//g')
            PHPSESSID="PHP${Session}SESSID"
            # UPPERCASE
            PHPSESSID="${PHPSESSID^^}"

            sudo sed -i "s/session.name = PHPSESSID/session.name = $PHPSESSID/g" /etc/opt/remi/$Version/php.ini

            if ! grep -q "/usr/local/goadmio/includes" /etc/opt/remi/$Version/php.ini; then

                echo "include_path = /usr/local/goadmio/includes" | sudo tee -a /etc/opt/remi/$Version/php.ini >/dev/null

            fi

            if sudo test ! -f "/etc/opt/remi/$Version/php.bak" ; then
                sudo cp /etc/opt/remi/$Version/php.ini /etc/opt/remi/$Version/php.bak
            fi

        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    Dir="/etc"
    cd /etc/php
    for Version in *; do

        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            Session=$(echo "$Version" | sed 's/[^0-9]*//g')
            PHPSESSID="PHP${Session}SESSID"
            # UPPERCASE
            PHPSESSID="${PHPSESSID^^}"

            sudo sed -i "s/session.name = PHPSESSID/session.name = $PHPSESSID/g" /etc/php/$Version/fpm/php.ini

            if ! grep -q "/usr/local/goadmio/includes" /etc/php/$Version/fpm/php.ini; then

                echo "include_path = /usr/local/goadmio/includes" | sudo tee -a /etc/php/$Version/fpm/php.ini >/dev/null

            fi

            if sudo test ! -f "/etc/php/$Version/fpm/php.ini" ; then
                sudo cp /etc/php/$Version/fpm/php.ini /etc/php/$Version/fpm/php.bak
            fi

        fi

    done

fi

# Install Go SO Decoder (decoder.so)
sudo /go/so
