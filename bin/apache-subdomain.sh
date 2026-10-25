#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Subdomain="$1"

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

IFS='.' read -r -a Array <<<"$Subdomain"
Directory="${Array[0]}"
Domain="${Subdomain/$Directory./}"
PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")

OS=$(</usr/local/goadmio/linux/os.db)

if sudo test -f "/var/go/etc/timeout" ; then

    Timeout=$(</var/go/etc/timeout)

    if ! [[ "$Timeout" =~ ^[0-9]+$ ]]; then
        Timeout="30"
    fi

else

    Timeout="30"

fi

if sudo test ! -d "/home/$Domain" ; then
    echo "Domain directory /home/$Domain not exists."
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    APACHE="/etc/httpd/vhost/$Subdomain.conf"
    APACHESSL="/etc/httpd/vhost/$Subdomain-le-ssl.conf"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    APACHE="/etc/apache2/vhost/$Subdomain.conf"
    APACHESSL="/etc/apache2/vhost/$Subdomain-le-ssl.conf"
fi

DocumentRoot=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "select DocumentRoot from Subdomain where Subdomain='$Subdomain'")
PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "select PHPVersion from Subdomain where Subdomain='$Subdomain'")
RedirectUrl=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "select RedirectUrl from Subdomain where Subdomain='$Subdomain'")

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

SockFolder=$(echo "$PHPVersion" | sed 's/[^0-9]*//g')

if sudo test ! -d "/home/$Domain/www/$DocumentRoot" ; then
    sudo mkdir -p "/home/$Domain/www/$DocumentRoot"
fi

sudo chmod 775 -R "/home/$Domain/www/$Directory"

# ============================================================
# HTTP vhost
# ============================================================
{
    echo "<VirtualHost *:80>"
    echo "	ServerAdmin webmaster@$Subdomain"
    echo "	DocumentRoot /home/$Domain/www/$DocumentRoot"
    echo "	ServerName www.$Subdomain"
    echo "	ServerAlias $Subdomain"
    echo "	<Proxy \"unix:/run/sock/$SockFolder/$Domain.sock|fcgi://localhost\">"
    echo "		ProxySet flushpackets=on"
    echo "		ProxySet disablereuse=off"
    echo "		ProxySet connectiontimeout=5 timeout=$Timeout"
    echo "	</Proxy>"
    echo ""
    echo "	<FilesMatch \.php\$>"
    echo "		SetHandler proxy:fcgi://localhost"
    echo "	</FilesMatch>"

    if sudo test -f "/etc/letsencrypt/live/$Subdomain/cert.pem" ; then
        echo "RewriteEngine on"
        echo "RewriteCond %{SERVER_NAME} =$Subdomain"
        echo "RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]"
    fi

    echo "</VirtualHost>"
} | sudo tee "$APACHE" >/dev/null

# ============================================================
# Create go.html
# ============================================================
echo "<title>Coming Soon</title><style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;line-height:30px}</style><div class='Outer'><div class='Middle'><div class='Inner'><svg height='100' width='100'><circle cx='50' cy='50' r='31' stroke='#679b08' stroke-width='9.5' fill='none' /><circle cx='50' cy='50' r='6' stroke='#679b08' stroke-width='1' fill='#679b08' /><line x1='50' y1='50' x2='35' y2='50' style='stroke:#679b08;stroke-width:6' /><line x1='65' y1='35' x2='50' y2='50' style='stroke:#679b08;stroke-width:6' /><path d='M59 65 L83 65 L75 87 Z' fill='#679b08' /><rect width='20' height='9' x='70' y='56' style='fill:#eee;stroke-width:0;' /></svg><br>Future home of something quite cool.<br>If you're the site owner, <a href='/go'>log in</a> to launch this site<br>If you are a visitor, check back soon.</div></div></div>" | sudo tee "/home/$Domain/www/$DocumentRoot/go.html" >/dev/null

# ============================================================
# Config SSL
# ============================================================
if sudo test -f "/etc/letsencrypt/live/$Subdomain/cert.pem" ; then

    {
        echo "<IfModule mod_ssl.c>"
        echo "<VirtualHost *:443>"
        echo "	ServerAdmin webmaster@$Subdomain"
        echo "	DocumentRoot /home/$Domain/www/$DocumentRoot"
        echo "	ServerName www.$Subdomain"
        echo "	ServerAlias $Subdomain"
        echo ""
        echo "	<Proxy \"unix:/run/sock/$SockFolder/$Domain.sock|fcgi://localhost\">"
        echo "		ProxySet flushpackets=on"
        echo "		ProxySet disablereuse=off"
        echo "		ProxySet connectiontimeout=5 timeout=$Timeout"
        echo "	</Proxy>"
        echo ""
        echo "	<FilesMatch \.php\$>"
        echo "		SetHandler proxy:fcgi://localhost"
        echo "	</FilesMatch>"
        echo ""
        echo "Include /etc/letsencrypt/options-ssl-apache.conf"
        echo "SSLCertificateFile /etc/letsencrypt/live/$Subdomain/cert.pem"
        echo "SSLCertificateKeyFile /etc/letsencrypt/live/$Subdomain/privkey.pem"
        echo "SSLCertificateChainFile /etc/letsencrypt/live/$Subdomain/chain.pem"
        echo ""
        echo "</VirtualHost>"
        echo "</IfModule>"
    } | sudo tee "$APACHESSL" >/dev/null

fi

if [ "$RedirectUrl" != "" ] && [ "$RedirectUrl" != "-" ] && [ "$RedirectUrl" != "http://" ] && [ "$RedirectUrl" != "https://" ]; then

    echo "<?php header(\"Location: $RedirectUrl\"); ?>" | sudo tee "/home/$Domain/www/$DocumentRoot/index.php" >/dev/null

fi