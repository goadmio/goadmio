#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/conf "$@"
fi

echo "$(date +'[%b %d %H:%M:%S]#') $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [[ $@ = *"--force"* ]]; then
    # Correct Web Server (Apache|NHINX)
    sudo /go/ws
fi

if [[ "$1" = *"."* ]]; then

    Domain=$1

    if sudo test -d /home/$Domain/www ; then

        sudo /go/apache $Domain
        sudo /go/nginx $Domain
        sudo /go/php-fpm $Domain
        sudo /go/reload

    fi

    exit 1

fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [[ $@ = *"--schedule"* ]]; then

    At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
    if [[ ! "$At" = *"conf"* ]]; then
        echo "/go/conf" | sudo at now + 3 minute >/dev/null 2>&1
    fi

    exit 1

fi

if [[ $@ = *"--installwebserver"* ]]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo /usr/bin/dnf -y install httpd
        sudo /usr/bin/dnf -y install nginx
        sudo /usr/bin/dnf -y install mod_fcgid

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        DEBIAN_FRONTEND='noninteractive' apt -y install apache2
        DEBIAN_FRONTEND='noninteractive' apt -y install nginx

    fi

fi

if [[ $@ = *"--force"* ]]; then
    Parameter="--force"
fi

if [[ $@ = *"--limit"* ]]; then
    Parameter="$Parameter --limit"
fi

if [[ $@ = *"--skip ssl"* ]]; then
    Parameter="$Parameter --skip ssl"
fi

if [[ $@ = *"--skip mailssl"* ]]; then
    Parameter="$Parameter --skip mailssl"
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo mkdir -p /var/log/httpd
    DIR="/etc/httpd/vhost"
    
    sudo rm -rf /etc/httpd/vhost/*
    sudo rm -rf /etc/nginx/vhost/*

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo mkdir -p /var/log/apache2
    DIR="/etc/apache2/vhost"

    sudo rm -rf /etc/apache2/vhost/*
    sudo rm -rf /etc/nginx/vhost/*

fi

echo "" | sudo tee "$DIR/go.conf"

if [[ $@ = *"--force"* ]]; then

    # Delete All Pool Files except www.conf (AlmaLinux)
    if sudo test -d "/etc/opt/remi" ; then
        sudo find /etc/opt/remi/*/php-fpm.d -type f -not -name "www.conf" -print0 | xargs -0 -I {} rm {}
    fi

    # Delete All Pool Files except www.conf (Debian)
    if sudo test -d "/etc/php" ; then
        sudo find /etc/php/*/fpm/pool.d -type f -not -name "www.conf" -print0 | xargs -0 -I {} rm {}
    fi

    sudo rm -rf /etc/letsencrypt/*

else

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo sh -c "find /etc/opt/remi/*/php-fpm.d -type f -printf '%f\n' > /usr/local/goadmio/tmp/pool.db"

        F="/usr/local/goadmio/tmp/pool.db"
        while IFS= read CFile; do

            Domain=${CFile/.conf/}

            if [ "$CFile" != "www.conf" ] && [ "$CFile" != "go.conf" ]; then

                if sudo test ! -d "/home/$Domain" ; then

                    echo "Deleting $CFile Pool..."
                    sudo find /etc/opt/remi/*/php-fpm.d -type f -name "$CFile" -delete

                fi

            fi

        done <"$F"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo sh -c "find /etc/php/*/fpm/pool.d -type f -printf '%f\n' > /usr/local/goadmio/tmp/pool.db"

        F="/usr/local/goadmio/tmp/pool.db"
        while IFS= read CFile; do

            Domain=${CFile/.conf/}

            if [ "$CFile" != "www.conf" ] && [ "$CFile" != "go.conf" ]; then

                if sudo test ! -d "/home/$Domain" ; then

                    echo "Deleting $CFile Pool..."
                    sudo find /etc/php/*/fpm/pool.d -type f -name "$CFile" -delete

                fi

            fi

        done <"$F"

    fi

fi

if [ "$WS" = "Apache" ]; then

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            if sudo test ! -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test ! -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test ! -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                sudo rm -rf /etc/httpd/vhost/$Domain-le-ssl.conf

            fi

        fi

    done

fi

if ! id "go" >/dev/null 2>&1; then

    # Pool Full Access
    FTPPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
    sudo /go/adduser go $FTPPassword

fi

echo "Domains Configuration..."

# Count Websites
C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
N=0

cd /home
for Domain in *; do

    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

    if [ "$Username" != "" ]; then

        if sudo test -d "/home/$Domain/www" ; then

            PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Username='$Username'")
            FPM=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select FPM from Site where Username='$Username'")

            if ! id "$Username" >/dev/null 2>&1; then
                sudo /go/adduser $Username
            fi

            # Create VHOST CONF
            sudo /go/apache $Domain
            sudo /go/nginx $Domain

            N=$(($N + 1))

            if [ "$FPM" = "1" ]; then
                echo "[$N/$C] Configuration completed for $Domain ($PHPVersion)"
            else
                echo "[$N/$C] Configuration completed for $Domain ($PHPVersion). FPM Diabled (INSCURE)"
            fi

            # Recreate POOL
            sudo /go/php-fpm $Domain

        fi

    fi

done

sudo /go/go

echo "Sub-Domains Configuration..."

sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/subdomain.db "select Subdomain || ',' || PHPVersion from Subdomain" | sudo tee /usr/local/goadmio/tmp/conf-subdomain.db > /dev/null >/dev/null

N=0
C=$(sudo cat /usr/local/goadmio/tmp/conf-subdomain.db | wc -l)
File="/usr/local/goadmio/tmp/conf-subdomain.db"
while IFS= read String; do

    N=$(($N + 1))

    IFS=',' read -r -a Array <<<"$String"

    Subdomain="${Array[0]}"
    PHPVersion="${Array[1]}"

    if sudo test ! -f "/etc/letsencrypt/live/$Subdomain/cert.pem" ; then

        sudo /go/ssl $Subdomain

    else

        sudo /go/apache-subdomain $Subdomain
        sudo /go/nginx-subdomain $Subdomain

    fi

    echo "[$N/$C] Configuration completed for $Subdomain ($PHPVersion)"

done <"$File"
echo "."

echo "Creating GoAdmio PHP-FPM Pool..."
sudo /go/php-fpm go go
echo "."

if [[ $@ = *"--force"* ]]; then

    sudo /go/installssl $Parameter

    if [[ ! $@ = *"--skip ssl"* ]]; then
        sudo /go/ssl all $Parameter
    fi

else

    if [[ ! $@ = *"--skip ssl"* ]]; then
        echo "Installing Missing SSL Certificates..."
        sudo /go/ssl all $Parameter
        echo "."
    fi

fi

if [[ ! $@ = *"--skip mailssl"* ]]; then
    sudo /go/mailssl $Parameter
fi

# Remove invalid .htaccess Files (Invalid Path)
sudo rm -rf /home/.htaccess
sudo rm -rf /home/*/.htaccess

echo "Restarting Web Server and PHP-FPM..."
sudo /go/restart
echo "."