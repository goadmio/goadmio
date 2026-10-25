#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="$1"
PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")
Hostname=$(</etc/hostname)

ServerIP=$(curl -s -4 checkip.amazonaws.com)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

GoSocket=0

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

SockLatest=$(sudo find /run/sock -maxdepth 1 -type d -name "[0-9]*" | xargs -I {} basename {} | sort -n | tail -1)

if [ $# -eq 0 ]; then

    echo "Switching from NGINX to Apache..."

    sudo rm -rf /etc/httpd/vhost/*-le-ssl.conf
    sudo /go/removessl

    # Switch to Apache
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/control.db "DELETE FROM Control"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

        sudo /go/installssl

        sudo systemctl disable nginx
        sudo systemctl enable httpd
        sudo systemctl stop nginx
        sudo systemctl start httpd

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

        sudo /go/installssl

        sudo systemctl disable nginx
        sudo systemctl enable apache2
        sudo systemctl stop nginx
        sudo systemctl start apache2

    else
        echo "Unknown operating system."
        exit 1
    fi

    sudo /go/conf --force

    exit 1

fi

if sudo test -f "/var/go/etc/timeout" ; then

    Timeout=$(</var/go/etc/timeout)

    if ! [[ "$Timeout" =~ ^[0-9]+$ ]]; then
        Timeout="30"
    fi

else

    Timeout="30"

fi

if sudo test ! -d "/home/$Domain" ; then
    echo "APACHE: Domain Directory /home/$Username not exists."
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    APACHE="/etc/httpd/vhost/$Domain.conf"
    APACHESSL="/etc/httpd/vhost/$Domain-le-ssl.conf"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    APACHE="/etc/apache2/vhost/$Domain.conf"
    APACHESSL="/etc/apache2/vhost/$Domain-le-ssl.conf"
fi

# GET Last PHP Version
if [ "$PHPVersion" = "" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        cd /etc/opt/remi || exit
        for Version in *; do

            if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

                PHPVersion="$Version"

            fi

        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        cd /etc/php || exit
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

FPM=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select FPM from Site where Domain='$Domain'")
Bot=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Bot from Site where Domain='$Domain'")
Bots=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "select Name from Bot where Block='1' and Name not like '% %';" | tr '\n' '|' | sed -e 's/^|//' -e 's/|$//')
Suspend=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Suspend from Site where Domain='$Domain'")
OpenBasedir=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select OpenBasedir from Site where Domain='$Domain'")

SockFolder=$(echo "$PHPVersion" | sed 's/[^0-9]*//g')
SSLRedirect=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select SSLRedirect from Site where Domain='$Domain'")
DocumentRoot=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select DocumentRoot from Site where Domain='$Domain'")
DocumentRoot=$(echo "$DocumentRoot" | sed "s/ //g")

if [ "$DocumentRoot" = "" ]; then

    DocumentRoot="/home/$Domain/www"

else

    DocumentRoot="/home/$Domain/www/$DocumentRoot"
    sudo mkdir -p "$DocumentRoot"

fi

# Website (HTTP)
{
    echo "<VirtualHost *:80>"
    echo "    Protocols h2 http/1.1"
    echo "    ServerAdmin webmaster@$Domain"
    echo "    DocumentRoot $DocumentRoot"
    echo "    ServerName $Domain"
    echo "    ServerAlias www.$Domain"
    echo ""

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where Domain='$Domain';")
    for AliasDomain in $SQL; do

        echo "    ServerAlias $AliasDomain"
        echo "    ServerAlias www.$AliasDomain"
        echo ""

    done

    echo "    Redirect 301 /go http://$Hostname/go"
    echo "    Redirect 301 /webmail http://$Hostname/go/installmail"
    echo ""

    if [ "$FPM" = "1" ]; then

        if [ "$OpenBasedir" = "/" ]; then

            echo "    <Proxy \"unix:/run/sock/$SockFolder/go.sock|fcgi://localhost\">"

        else

            echo "    <Proxy \"unix:/run/sock/$SockFolder/$Domain.sock|fcgi://localhost\">"

        fi

        echo "        ProxySet flushpackets=on"
        echo "        ProxySet disablereuse=off"
        echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
        echo "    </Proxy>"
        echo ""
        echo "    <FilesMatch \.php\$>"
        echo "        SetHandler proxy:fcgi://localhost"
        echo "    </FilesMatch>"

    fi

    if sudo test -d /goserver ; then

        echo ""
        echo "    ProxyPreserveHost On"
        echo "    ProxyPass /goserver http://$ServerIP:8080"
        echo "    ProxyPassReverse /goserver http://$ServerIP:8080"

    fi

    echo ""
    echo "    RewriteEngine on"

    if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  && [ "$SSLRedirect" = "1" ]; then

        echo "    RewriteCond %{SERVER_NAME} =www.$Domain [OR]"
        echo "    RewriteCond %{SERVER_NAME} =$Domain"

        if [ "$Suspend" = "1" ]; then

            echo "    RewriteRule ^ https://$Hostname/suspend [END,NE,R=permanent]"
            echo ""

        else

            echo "    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]"
            echo ""

        fi

    else

        if [ "$Suspend" = "1" ]; then

            echo "    RewriteCond %{SERVER_NAME} =www.$Domain [OR]"
            echo "    RewriteCond %{SERVER_NAME} =$Domain"
            echo "    RewriteRule ^ https://$Hostname/suspend [END,NE,R=permanent]"
            echo ""

        fi

    fi

    if [ "$Bot" = "1" ] && [[ "$Bots" = *"|"* ]]; then
        # Block Bad Bots
        echo "    RewriteCond %{HTTP_USER_AGENT} ($Bots) [NC]"
        echo "    RewriteRule .* - [F]"
    fi

    echo "</VirtualHost>"
} | sudo tee "$APACHE" >/dev/null

# Go (HTTP)
{
    echo ""
    echo "<VirtualHost *:80>"
    echo "    Protocols h2 http/1.1"
    echo "    ServerAdmin webmaster@$Domain"
    echo "    DocumentRoot /usr/local/goadmio/home/go"
    echo "    ServerName go.$Domain"
    echo ""

    if [ "$FPM" = "1" ]; then

        if [[ "$GoSocket" -eq 1 ]]; then

            echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
            echo "        ProxySet flushpackets=on"
            echo "        ProxySet disablereuse=off"
            echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
            echo "    </Proxy>"
            echo ""
            echo "    <FilesMatch \.php\$>"
            echo "        SetHandler proxy:fcgi://localhost"
            echo "    </FilesMatch>"

        fi

    fi

    if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" && [ "$SSLRedirect" = "1" ]; then
        echo ""
        echo "    RewriteEngine on"
        echo "    RewriteCond %{SERVER_NAME} =go.$Domain"
        echo "    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]"
    fi

    echo "</VirtualHost>"
} | sudo tee -a "$APACHE" >/dev/null

# Webmail (HTTP)
{
    echo ""
    echo "<VirtualHost *:80>"
    echo "    Protocols h2 http/1.1"
    echo "    ServerAdmin webmaster@$Domain"
    echo "    DocumentRoot /usr/local/goadmio/home/go/webmail"
    echo "    ServerName webmail.$Domain"
    echo ""

    if [ "$FPM" = "1" ]; then

        if [[ "$GoSocket" -eq 1 ]]; then

            echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
            echo "        ProxySet flushpackets=on"
            echo "        ProxySet disablereuse=off"
            echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
            echo "    </Proxy>"
            echo ""
            echo "    <FilesMatch \.php\$>"
            echo "        SetHandler proxy:fcgi://localhost"
            echo "    </FilesMatch>"

        fi

    fi

    if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  && [ "$SSLRedirect" = "1" ]; then
        echo ""
        echo "    RewriteEngine on"
        echo "    RewriteCond %{SERVER_NAME} =webmail.$Domain"
        echo "    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]"
    fi

    echo "</VirtualHost>"
} | sudo tee -a "$APACHE" >/dev/null

# SSL

FreePEM=0
if sudo test -d "/etc/letsencrypt/live/$Domain" ; then
    FreePEM=$(sudo find "/etc/letsencrypt/live/$Domain" -name "*.pem" | wc -l)
fi

PaidPEM=0
if sudo test -d "/etc/ssl/$Domain" ; then
    PaidPEM=$(sudo find "/etc/ssl/$Domain" -name "*.pem" | wc -l)
fi

if [ "$FreePEM" -ge "3" ] || [ "$PaidPEM" -ge "3" ]; then

    # Website SSL
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:443>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot $DocumentRoot"
            echo "    ServerName $Domain"
            echo "    ServerAlias www.$Domain"
            echo ""

            SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where Domain='$Domain';")
            for AliasDomain in $SQL; do

                echo "    ServerAlias $AliasDomain"
                echo "    ServerAlias www.$AliasDomain"
                echo ""

            done

            echo "    Redirect 301 /go https://$Hostname/go"
            echo "    Redirect 301 /webmail https://$Hostname/go/installmail"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [ "$OpenBasedir" = "/" ]; then

                    echo "    <Proxy \"unix:/run/sock/$SockFolder/go.sock|fcgi://localhost\">"

                else

                    echo "    <Proxy \"unix:/run/sock/$SockFolder/$Domain.sock|fcgi://localhost\">"

                fi

                echo "        ProxySet flushpackets=on"
                echo "        ProxySet disablereuse=off"
                echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                echo "    </Proxy>"
                echo ""
                echo "    <FilesMatch \.php\$>"
                echo "        SetHandler proxy:fcgi://localhost"
                echo "    </FilesMatch>"

            fi

            if sudo test -d /goserver ; then

                echo ""
                echo "    ProxyPreserveHost On"
                echo "    ProxyPass /goserver http://$ServerIP:8080"
                echo "    ProxyPassReverse /goserver http://$ServerIP:8080"

            fi

            if [ "$Bot" = "1" ] && [[ "$Bots" = *"|"* ]]; then
                # Block Bad Bots
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTP_USER_AGENT} ($Bots) [NC]"
                echo "    RewriteRule .* - [F]"
            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$Suspend" = "1" ]; then

                echo ""
                echo "    RewriteEngine on"
                echo "    RewriteCond %{SERVER_NAME} =www.$Domain [OR]"
                echo "    RewriteCond %{SERVER_NAME} =$Domain"
                echo "    RewriteRule ^ https://$Hostname/suspend [END,NE,R=permanent]"

            elif [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee "$APACHESSL" >/dev/null

    fi

    # Go SSL
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo ""
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:443>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot /usr/local/goadmio/home/go"
            echo "    ServerName go.$Domain"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [[ "$GoSocket" -eq 1 ]]; then

                    echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
                    echo "        ProxySet flushpackets=on"
                    echo "        ProxySet disablereuse=off"
                    echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                    echo "    </Proxy>"
                    echo ""
                    echo "    <FilesMatch \.php\$>"
                    echo "        SetHandler proxy:fcgi://localhost"
                    echo "    </FilesMatch>"

                fi

            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee -a "$APACHESSL" >/dev/null

    fi

    # Go SSL ON PORT 2021
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo ""
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:2021 *:2083 *:2087>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot /usr/local/goadmio/home/go"
            echo "    ServerName $Domain"
            echo "    ServerAlias www.$Domain"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [[ "$GoSocket" -eq 1 ]]; then

                    echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
                    echo "        ProxySet flushpackets=on"
                    echo "        ProxySet disablereuse=off"
                    echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                    echo "    </Proxy>"
                    echo ""
                    echo "    <FilesMatch \.php\$>"
                    echo "        SetHandler proxy:fcgi://localhost"
                    echo "    </FilesMatch>"

                fi

            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee -a "$APACHESSL" >/dev/null

    fi

    # Firewall SSL ON PORT 2080
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo ""
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:2080>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot /usr/local/goadmio/home/firewall"
            echo "    ServerName $Domain"
            echo "    ServerAlias www.$Domain"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [[ "$GoSocket" -eq 1 ]]; then

                    echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
                    echo "        ProxySet flushpackets=on"
                    echo "        ProxySet disablereuse=off"
                    echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                    echo "    </Proxy>"
                    echo ""
                    echo "    <FilesMatch \.php\$>"
                    echo "        SetHandler proxy:fcgi://localhost"
                    echo "    </FilesMatch>"

                fi

            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee -a "$APACHESSL" >/dev/null

    fi

    # Webmail SSL
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo ""
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:443>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot /usr/local/goadmio/home/go/webmail"
            echo "    ServerName webmail.$Domain"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [[ "$GoSocket" -eq 1 ]]; then

                    echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
                    echo "        ProxySet flushpackets=on"
                    echo "        ProxySet disablereuse=off"
                    echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                    echo "    </Proxy>"
                    echo ""
                    echo "    <FilesMatch \.php\$>"
                    echo "        SetHandler proxy:fcgi://localhost"
                    echo "    </FilesMatch>"

                fi

            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee -a "$APACHESSL" >/dev/null

    fi

    # Webmail SSL ON PORT 2025
    if sudo test -f "/etc/ssl/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem" ; then

        {
            echo ""
            echo "<IfModule mod_ssl.c>"
            echo "<VirtualHost *:2025 *:2096>"
            echo "    Protocols h2 http/1.1"
            echo "    ServerAdmin webmaster@$Domain"
            echo "    DocumentRoot /usr/local/goadmio/home/go/webmail"
            echo "    ServerName $Domain"
            echo "    ServerAlias www.$Domain"
            echo ""

            if [ "$FPM" = "1" ]; then

                if [[ "$GoSocket" -eq 1 ]]; then

                    echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
                    echo "        ProxySet flushpackets=on"
                    echo "        ProxySet disablereuse=off"
                    echo "        ProxySet connectiontimeout=5 timeout=$Timeout"
                    echo "    </Proxy>"
                    echo ""
                    echo "    <FilesMatch \.php\$>"
                    echo "        SetHandler proxy:fcgi://localhost"
                    echo "    </FilesMatch>"

                fi

            fi

            if sudo test -f "/etc/ssl/$Domain/cert.pem"  && sudo test -f "/etc/ssl/$Domain/privkey.pem"  && sudo test -f "/etc/ssl/$Domain/bundle.pem" ; then

                echo ""
                echo "    SSLCertificateFile /etc/ssl/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/ssl/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/ssl/$Domain/bundle.pem"

            elif sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  || sudo test -f "/etc/letsencrypt/live/$Domain/chain.pem" ; then

                echo ""
                echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
                echo "    SSLCertificateFile /etc/letsencrypt/live/$Domain/cert.pem"
                echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Domain/privkey.pem"
                echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Domain/chain.pem"

            fi

            if [ "$SSLRedirect" = "-1" ]; then

                # Redirect HTTPS to HTTP
                echo ""
                echo "    RewriteEngine On"
                echo "    RewriteCond %{HTTPS} on"
                echo "    RewriteRule (.*) http://%{HTTP_HOST}%{REQUEST_URI}"

            fi

            echo "</VirtualHost>"
            echo "</IfModule>"
        } | sudo tee -a "$APACHESSL" >/dev/null

    fi

fi