#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/fix "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

CHMOD() {
    Domain=$1

    if [ "$2" = "777" ] || [ "$2" = "755" ] || [ "$2" = "555" ]; then
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Permission='$2' where Domain='$Domain'"
    fi

    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
    Permission=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Permission from Site where Domain='$Domain'")

    if sudo test -d "/home/$Domain/www" ; then

        echo "Checking $Domain ($Username) [$Permission]...                                                  "

        sudo mkdir -p /var/cache/$Domain
        sudo chmod 755 -R /var/cache/$Domain
        sudo chown -R $Username:$Username /var/cache/$Domain

        sudo mkdir -p /backup/$Domain
        sudo chmod 755 /backup/$Domain
        sudo chown -R $Username:$Username /backup/$Domain

        sudo mkdir -p /home/$Domain/mail
        sudo chmod 755 /home/$Domain/mail
        sudo chown -R vmail:vmail /home/$Domain/mail

        sudo mkdir -p /home/$Domain/sqlite
        sudo chmod -R 755 /home/$Domain/sqlite
        sudo chown -R $Username:$Username /home/$Domain/sqlite

        sudo mkdir -p /home/$Domain/.trash
        sudo chmod -R 755 /home/$Domain/.trash
        sudo chown -R $Username:$Username /home/$Domain/.trash

        sudo chmod 711 /home/$Domain
        # Required for OpenSSH SFTP
        sudo chown root:root /home/$Domain

        sudo chmod 755 -R /home/$Domain/mail
        sudo chown -R $Username:$Username /home/$Domain/www
        sudo chown -R $Username:$Username /home/$Domain/log

        if [ "$Permission" = "777" ]; then

            sudo find /home/$Domain/www -type d | xargs chmod 777 >/dev/null 2>&1
            sudo find /home/$Domain/www -type f | xargs chmod 777 >/dev/null 2>&1

        elif [ "$Permission" = "555" ]; then

            sudo chown -R root:root /home/$Domain/www

            sudo find /home/$Domain/www -type d | xargs chmod 555 >/dev/null 2>&1
            sudo find /home/$Domain/www -type f | xargs chmod 555 >/dev/null 2>&1

        else

            sudo find /home/$Domain/www -type d | xargs chmod 755 >/dev/null 2>&1
            sudo find /home/$Domain/www -type f | xargs chmod 644 >/dev/null 2>&1

        fi

    fi

    # FTP Accounts
    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "select User || ',' || Directory from Ftp where Domain='$Domain';")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        User="${Row[0]}"
        Directory="${Row[1]}"

        if [[ ! "$Directory" = *"/www" ]]; then
            echo "Checking FTP $User (Directory: $Directory)...                                                  "
            sudo chown -R $User:$User $Directory
        fi

    done

}

# chmod 1777 /tmp
sudo chmod 777 /tmp

sudo mkdir -p /tmp/s3
sudo chmod 777 /tmp/s3

if [ $# -eq 0 ] || [ "$1" = "all" ]; then

    cd /home
    for Domain in *; do
        CHMOD "$Domain" "$2"
    done

else

    if sudo test -d "/home/$1" ; then

        CHMOD "$1" "$2"

    else

        echo "FIX: Domain Directory /home/$1 not Exists"

    fi

fi

sudo chmod 711 /home

# GoAdmio SQLite Database
sudo chown -R go:go /var/lib/sqlite
sudo chown -R go:go /var/log/go

sudo chown 555 -R /usr/local/goadmio/includes

# Wrong permissions on configuration file, should not be world writable!
sudo chmod 775 /usr/local/goadmio/home/phpmyadmin/config.inc.php >/dev/null 2>&1

# Session Problems
sudo /go/session
