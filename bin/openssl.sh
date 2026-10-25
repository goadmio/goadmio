#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/openssl "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ "$Action" = "install" ]; then

    # IF PrivateKey Empty
    if sudo test ! -f /etc/ssl/$Domain/key.pem ; then

        sudo cp /etc/ssl/$Domain/$Domain.key /etc/ssl/$Domain/key.pem

    fi

    ExpireCRT=$(sudo openssl x509 -enddate -noout -in /etc/ssl/$Domain/crt.pem | sed 's/notAfter=//')

    if [ "$ExpireCRT" = "" ]; then

        echo "Invalid Certificate."
        exit 1

    fi

    ExpireBUNDLE=$(sudo openssl x509 -enddate -noout -in /etc/ssl/$Domain/bundle.pem | sed 's/notAfter=//')

    if [ "$ExpireBUNDLE" = "" ]; then

        echo "Invalid Certificate Authority Bundle."
        exit 1

    fi

    CheckCrt=$(sudo openssl x509 -modulus -noout -in /etc/ssl/$Domain/crt.pem | openssl md5)
    CheckKey=$(sudo openssl rsa -modulus -noout -in /etc/ssl/$Domain/key.pem | openssl md5)

    if [ "$CheckCrt" = "$CheckKey" ]; then

        PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")
        sudo /go/apache $Domain $PHPVersion
        sudo /go/nginx $Domain $PHPVersion

        echo "SSL Certificate installed successfully."
        echo "Certificate expires on: $ExpireCRT"

        sudo /go/reload "| Executed by $(basename "$0")"

    else

        echo "Private Key and Certificate do not match."

        sudo rm -rf /etc/ssl/$Domain/crt.pem
        sudo rm -rf /etc/ssl/$Domain/key.pem
        sudo rm -rf /etc/ssl/$Domain/bundle.pem

    fi

    exit 1

fi

if [ "$Action" = "delete" ]; then

    # Delete Paid SSL
    sudo rm -rf /etc/ssl/$Domain/cert.pem
    sudo rm -rf /etc/ssl/$Domain/privkey.pem
    sudo rm -rf /etc/ssl/$Domain/chain.pem
    sudo rm -rf /etc/ssl/$Domain/bundle.pem

    # Delete Free SSL
    sudo rm -rf /etc/letsencrypt/live/$Domain

    PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")
    sudo /go/apache $Domain
    sudo /go/nginx $Domain

    sudo /go/reload "| Executed by $(basename "$0")"

    exit 1

fi

if [ "$Domain" = "all" ]; then

    cd /home
    for Domain in *; do

        UsernameDirectory=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

        if sudo test -d "/home/$UsernameDirectory/www" ; then

            sudo /go/openssl $Domain

        fi

    done

    exit 1

fi

if sudo test ! -f /etc/ssl/$Domain/$Domain.key  || sudo test ! -f /etc/ssl/$Domain/$Domain.csr ; then

    sudo mkdir -p /etc/ssl/$Domain
    sudo chmod -R 400 /etc/ssl/$Domain
    sudo chown -R root:root /etc/ssl/$Domain

    cd /etc/ssl/$Domain
    sudo openssl req -new -newkey rsa:2048 -nodes -keyout $Domain.key -out $Domain.csr -subj "/CN=$Domain/emailAddress=info@$Domain/O=My Company Name LTD./C=EG" &>/dev/null

fi
