#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="$1"
PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")
Hostname=$(</etc/hostname)

ServerIP=$(curl -s -4 checkip.amazonaws.com)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

SockLatest=$(sudo find /run/sock -maxdepth 1 -type d -name "[0-9]*" | xargs -I {} basename {} | sort -n | tail -1)

if [ $# -eq 0 ]; then

    echo "Switching from Apache to NGINX..."

    sudo /go/removessl

    # Switch to NGINX
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/control.db "DELETE FROM Control"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        echo "NGINX" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

        sudo /go/installssl

        sudo systemctl disable httpd
        sudo systemctl enable nginx
        sudo systemctl stop httpd
        sudo systemctl start nginx

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        echo "NGINX" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

        sudo /go/installssl

        sudo systemctl disable apache2
        sudo systemctl enable nginx
        sudo systemctl stop apache2
        sudo systemctl start nginx

    else
        echo "Unknown operating system."
        exit 1
    fi

    sudo /go/conf --force

    exit 1

fi

if sudo test ! -d "/home/$Domain" ; then
    echo "NGINX: Domain Directory /home/$Domain not exists."
    exit 1
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    NGINX="/etc/nginx/vhost/$Domain.conf"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    NGINX="/etc/nginx/vhost/$Domain.conf"
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

if [ "$WS" = "NGINX" ]; then

    if sudo test -f "/etc/letsencrypt/live/$Domain/fullchain.pem"  && sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem" ; then

        if sudo test ! -f "/etc/letsencrypt/options-ssl-nginx.conf" ; then

            echo "File /etc/letsencrypt/options-ssl-nginx.conf not exists. Please wait..."
            sudo cp /usr/lib/python2.7/site-packages/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf

        fi

    fi

fi

if sudo test -f "/etc/letsencrypt/live/$Domain/fullchain.pem"  && sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem"  && sudo test -f "/etc/letsencrypt/options-ssl-nginx.conf" ; then

    # ============================================================
    # Config With SSL
    # ============================================================

    {
        echo "server"
        echo "{"
        echo "    listen 443 ssl;"
        echo "    listen [::]:443 ssl;"
        echo "    http2 on;"

        if [ "$Bot" = "1" ] && [[ "$Bots" = *"|"* ]]; then
            echo "    if (\$http_user_agent ~* ($Bots)) {return 403;}"
        fi

        if [ "$Suspend" = "1" ]; then
            echo "        return 301 https://$Hostname/suspend;"
        fi

        echo "    root $DocumentRoot;"
        echo "    index index.html index.php go.html;"
        echo "    server_name $Domain www.$Domain;"
        echo "    location ~ \.inc$ {deny all;return 403;}"
        echo "    location ~ /\.env {deny all;return 403;}"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockFolder/$Domain.sock;}"
        echo "    location = /go {return 301 https://$Hostname/go;}"
        echo "    location = /webmail {return 301 https://$Hostname/go/installmail;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"

        if sudo test -f "/home/$Domain/www/nginx.conf" ; then
            echo "    include /home/$Domain/www/nginx.conf;"
        fi

        if sudo test -d /goserver ; then
            echo ""
            echo "    location ~ ^/goserver(/?)(.*) {"
            echo "    proxy_pass http://$ServerIP:8080/\$2\$is_args\$args;"
            echo "    proxy_set_header Host \$host;"
            echo "    proxy_set_header X-Real-IP \$remote_addr;"
            echo "    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
            echo "    proxy_set_header X-Forwarded-Proto \$scheme;"
            echo "    proxy_http_version 1.1;"
            echo "    proxy_set_header Upgrade \$http_upgrade;"
            echo "    proxy_set_header Connection \"upgrade\";"
            echo "}"
        fi

        echo "}"
        echo ""

        echo "server"
        echo "{"
        echo "    listen 80;"
        echo "    listen [::]:80;"

        if [ "$Bot" = "1" ] && [[ "$Bots" = *"|"* ]]; then
            echo "    if (\$http_user_agent ~* ($Bots)) {return 403;}"
        fi

        if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  && [ "$SSLRedirect" = "1" ]; then
            echo "    if (\$host = $Domain)"
            echo "    {"
            echo "        return 301 https://\$host\$request_uri;"
            echo "    }"
            echo ""
        fi

        if [ "$Suspend" = "1" ]; then
            echo "        return 301 https://$Hostname/suspend;"
        fi

        echo "    root $DocumentRoot;"
        echo "    index index.html index.php go.html;"
        echo "    server_name $Domain www.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockFolder/$Domain.sock;}"

        if sudo test -f "/home/$Domain/www/nginx.conf" ; then
            echo "    include /home/$Domain/www/nginx.conf;"
        fi

        echo "}"
        echo ""

        # Go SSL
        echo "server"
        echo "{"
        echo "    listen 443 ssl;"
        echo "    listen [::]:443 ssl;"
        echo "    http2 on;"
        echo "    root /usr/local/goadmio/home/go;"
        echo "    index index.html index.php;"
        echo "    server_name go.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo "}"
        echo ""

        echo "server"
        echo "{"

        if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  && [ "$SSLRedirect" = "1" ]; then
            echo "    if (\$host = go.$Domain)"
            echo "    {"
            echo "        return 301 https://\$host\$request_uri;"
            echo "    }"
            echo ""
        fi

        echo "    listen 80;"
        echo "    listen [::]:80;"
        echo "    root /usr/local/goadmio/home/go;"
        echo "    index index.html index.php;"
        echo "    server_name go.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "}"
        echo ""

        # Go SSL On PORT 2021
        echo "server"
        echo "{"
        echo "    listen 2021 ssl;"
        echo "    http2 on;"
        echo "    root /usr/local/goadmio/home/go;"
        echo "    server_name $Domain www.$Domain;"
        echo "    index index.html index.php;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo "}"
        echo ""

        # Firewall SSL On PORT 2080
        echo "server"
        echo "{"
        echo "    listen 2080 ssl;"
        echo "    http2 on;"
        echo "    root /usr/local/goadmio/home/firewall;"
        echo "    server_name $Domain www.$Domain;"
        echo "    location / {try_files \$uri \$uri/ /index.php;}"
        echo "    index index.html index.php;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo "}"
        echo ""

        # Go Webmail SSL On PORT 2025
        echo "server"
        echo "{"
        echo "    listen 2025 ssl;"
        echo "    listen 2096 ssl;"
        echo "    root /usr/local/goadmio/home/go/webmail;"
        echo "    server_name $Domain www.$Domain;"
        echo "    index index.html index.php;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo "}"
        echo ""

        # Webmail SSL
        echo "server"
        echo "{"
        echo "    listen 443 ssl;"
        echo "    listen [::]:443 ssl;"
        echo "    http2 on;"
        echo "    root /usr/local/goadmio/home/go/webmail;"
        echo "    index index.html index.php;"
        echo "    server_name webmail.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Domain/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Domain/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo "}"
        echo ""

        echo "server"
        echo "{"

        if sudo test -f "/etc/letsencrypt/live/$Domain/cert.pem"  && [ "$SSLRedirect" = "1" ]; then
            echo "    if (\$host = webmail.$Domain)"
            echo "    {"
            echo "        return 301 https://\$host\$request_uri;"
            echo "    }"
            echo ""
        fi

        echo "    listen 80;"
        echo "    listen [::]:80;"
        echo "    root /usr/local/goadmio/home/go/webmail;"
        echo "    index index.html index.php;"
        echo "    server_name webmail.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "}"
        echo ""
    } | sudo tee "$NGINX" >/dev/null

else

    # ============================================================
    # Config Without SSL
    # ============================================================

    {
        echo "server"
        echo "{"
        echo "    listen 80;"
        echo "    listen [::]:80;"

        if [ "$Bot" = "1" ] && [[ "$Bots" = *"|"* ]]; then
            echo "    if (\$http_user_agent ~* ($Bots)) {return 403;}"
        fi

        echo "    root $DocumentRoot;"
        echo "    index index.html index.php go.html;"
        echo "    server_name $Domain www.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockFolder/$Domain.sock;}"

        if sudo test -f "/home/$Domain/www/nginx.conf" ; then
            echo "    include /home/$Domain/www/nginx.conf;"
        fi

        echo "}"
        echo ""

        # Go
        echo "server"
        echo "{"
        echo "    listen 80;"
        echo "    listen [::]:80;"
        echo "    root /usr/local/goadmio/home/go;"
        echo "    index index.html index.php;"
        echo "    server_name go.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "}"
        echo ""

        # Webmail
        echo "server"
        echo "{"
        echo "    listen 80;"
        echo "    listen [::]:80;"
        echo "    root /usr/local/goadmio/home/go/webmail;"
        echo "    index index.html index.php;"
        echo "    server_name webmail.$Domain;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "}"
        echo ""
    } | sudo tee "$NGINX" >/dev/null

fi

# Create go.html
echo "<title>Coming Soon</title><style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;line-height:30px}</style><div class='Outer'><div class='Middle'><div class='Inner'><svg height='100' width='100'><circle cx='50' cy='50' r='31' stroke='#679b08' stroke-width='9.5' fill='none' /><circle cx='50' cy='50' r='6' stroke='#679b08' stroke-width='1' fill='#679b08' /><line x1='50' y1='50' x2='35' y2='50' style='stroke:#679b08;stroke-width:6' /><line x1='65' y1='35' x2='50' y2='50' style='stroke:#679b08;stroke-width:6' /><path d='M59 65 L83 65 L75 87 Z' fill='#679b08' /><rect width='20' height='9' x='70' y='56' style='fill:#eee;stroke-width:0;' /></svg><br>Future home of something quite cool.<br>If you're the site owner, <a href='/go'>log in</a> to launch this site<br>If you are a visitor, check back soon.</div></div></div>" | sudo tee "$DocumentRoot/go.html" >/dev/null
