#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/go "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)
IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)
SockLatest=$(sudo find /run/sock -maxdepth 1 -type d -name "[0-9]*" | xargs -I {} basename {} | sort -n | tail -1)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    ApacheGo="/etc/httpd/go.conf"
    ApachePort="/etc/httpd/port.conf"
    ApacheConf="/etc/httpd/conf/httpd.conf"
    ApachePortInclude="include /etc/httpd/port.conf"
    ApacheGoInclude="include /etc/httpd/go.conf"

    NginxGo="/etc/nginx/go.conf"
    NginxPort="/etc/nginx/port.conf"
    NginxConf="/etc/nginx/nginx.conf"
    NginxPortInclude="include /etc/nginx/port.conf"
    NginxGoInclude="include /etc/nginx/go.conf"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    ApacheGo="/etc/apache2/go.conf"
    ApachePort="/etc/apache2/port.conf"
    ApacheConf="/etc/apache2/apache2.conf"
    ApachePortInclude="include /etc/apache2/port.conf"
    ApacheGoInclude="include /etc/apache2/go.conf"

    NginxGo="/etc/nginx/go.conf"
    NginxPort="/etc/nginx/port.conf"
    NginxConf="/etc/nginx/nginx.conf"
    NginxPortInclude="include /etc/nginx/port.conf"
    NginxGoInclude="include /etc/nginx/go.conf"

    # Delete Default CustomLog (Apache2)
    sudo rm -rf /etc/apache2/conf-available/other-vhosts-access-log.conf

elif [ "$OS" = "OpenSUSE" ]; then

    ApacheGo="/etc/apache2/go.conf"
    ApachePort="/etc/apache2/port.conf"
    ApacheConf="/etc/apache2/httpd.conf"
    ApachePortInclude="include /etc/apache2/port.conf"
    ApacheGoInclude="include /etc/apache2/go.conf"

    NginxGo="/etc/nginx/go.conf"
    NginxPort="/etc/nginx/port.conf"
    NginxConf="/etc/nginx/nginx.conf"
    NginxPortInclude="include /etc/nginx/port.conf"
    NginxGoInclude="include /etc/nginx/go.conf"

else
    echo "Unknown operating system."
    exit
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # Creating /etc/httpd/conf/httpd.conf file
    {
        echo "ServerRoot \"/etc/httpd\""
        echo "Listen 80"
        echo "Include conf.modules.d/*.conf"
        echo "User apache"
        echo "Group apache"
        echo "ServerAdmin root@localhost"
        echo ""
        echo "<Directory />"
        echo "    AllowOverride none"
        echo "    Require all denied"
        echo "</Directory>"
        echo ""
        echo "DocumentRoot \"/var/www/html\""
        echo ""
        echo "<Directory \"/var/www\">"
        echo "    AllowOverride None"
        echo "    # Allow open access:"
        echo "    Require all granted"
        echo "</Directory>"
        echo ""
        echo "<Directory \"/var/www/html\">"
        echo "    Options Indexes FollowSymLinks"
        echo "    AllowOverride None"
        echo "    Require all granted"
        echo "</Directory>"
        echo ""
        echo "<IfModule dir_module>"
        echo "    DirectoryIndex default.html index.html index.php go.html"
        echo "</IfModule>"
        echo ""
        echo "<Files \".ht*\">"
        echo "    Require all denied"
        echo "</Files>"
        echo ""
        echo "ErrorLog \"logs/error.log\""
        echo ""
        echo "LogLevel warn"
        echo ""
        echo "<IfModule log_config_module>"
        echo "    <IfModule logio_module>"
        echo "        LogFormat \"%P|%V|%h|%{CF-Connecting-IP}i|%{CF-IPCountry}i|%{%s}t|%{%Y-%m-%dT%H:%M:%S%z}t|%>s|%I|%b|%r%q|%{Referer}i|%{User-Agent}i\" combined"
        echo "    </IfModule>"
        echo "    CustomLog logs/access.log combined"
        echo "</IfModule>"
        echo ""
        echo "<IfModule alias_module>"
        echo "    ScriptAlias /cgi-bin/ \"/var/www/cgi-bin/\""
        echo "</IfModule>"
        echo ""
        echo "<Directory \"/var/www/cgi-bin\">"
        echo "    AllowOverride None"
        echo "    Options None"
        echo "    Require all granted"
        echo "</Directory>"
        echo ""
        echo "<IfModule mime_module>"
        echo "    TypesConfig /etc/mime.types"
        echo "    AddType application/x-compress .Z"
        echo "    AddType application/x-gzip .gz .tgz"
        echo "    AddType text/html .shtml"
        echo "    AddOutputFilter INCLUDES .shtml"
        echo "</IfModule>"
        echo ""
        echo "AddDefaultCharset UTF-8"
        echo ""
        echo "<IfModule mime_magic_module>"
        echo "    MIMEMagicFile conf/magic"
        echo "</IfModule>"
        echo ""
        echo "<FilesMatch \"^\\.env\$|\\.inc\$\">"
        echo "    Order allow,deny"
        echo "    Deny from all"
        echo "</FilesMatch>"
        echo ""
        echo "EnableSendfile on"
        echo ""
        echo "IncludeOptional conf.d/*.conf"
        echo "ServerSignature Off"
        echo "ServerTokens Prod"
        echo "ErrorDocument 404 /404.shtml"
        echo "ErrorDocument 500 /500.shtml"
        echo "ErrorDocument 502 /502.shtml"
        echo "ErrorDocument 503 /503.shtml"
        echo "ErrorDocument 504 /504.shtml"
        echo "include /etc/httpd/go.conf"
        echo "include /etc/httpd/vhost/*.conf"
        echo "include /etc/httpd/port.conf"
    } | sudo tee /etc/httpd/conf/httpd.conf >/dev/null

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    {
        echo "DefaultRuntimeDir \${APACHE_RUN_DIR}"
        echo "PidFile \${APACHE_PID_FILE}"
        echo "Timeout 300"
        echo "KeepAlive On"
        echo "MaxKeepAliveRequests 100"
        echo "KeepAliveTimeout 5"
        echo "User \${APACHE_RUN_USER}"
        echo "Group \${APACHE_RUN_GROUP}"
        echo "HostnameLookups Off"
        echo "ErrorLog \${APACHE_LOG_DIR}/error.log"
        echo "LogLevel warn"
        echo "IncludeOptional mods-enabled/*.load"
        echo "IncludeOptional mods-enabled/*.conf"
        echo "Include ports.conf"
        echo ""
        echo "<Directory />"
        echo "    Options FollowSymLinks"
        echo "    AllowOverride None"
        echo "    Require all denied"
        echo "</Directory>"
        echo ""
        echo "<Directory /usr/share>"
        echo "    AllowOverride None"
        echo "    Require all granted"
        echo "</Directory>"
        echo ""
        echo "<Directory /var/www/>"
        echo "    Options Indexes FollowSymLinks"
        echo "    AllowOverride None"
        echo "    Require all granted"
        echo "</Directory>"
        echo ""
        echo "AccessFileName .htaccess"
        echo ""
        echo "<FilesMatch \"^\.ht\">"
        echo "    Require all denied"
        echo "</FilesMatch>"
        echo ""
        echo "<IfModule log_config_module>"
        echo "    <IfModule logio_module>"
        echo "        LogFormat \"%P|%V|%h|%{CF-Connecting-IP}i|%{CF-IPCountry}i|%{%s}t|%{%Y-%m-%dT%H:%M:%S%z}t|%>s|%I|%b|%r%q|%{Referer}i|%{User-Agent}i\" combined"
        echo "    </IfModule>"
        echo "    CustomLog \${APACHE_LOG_DIR}/access.log combined"
        echo "</IfModule>"
        echo ""
        echo "IncludeOptional conf-enabled/*.conf"
        echo ""
        echo "ServerSignature Off"
        echo "ServerTokens Prod"
        echo "ErrorDocument 404 /404.shtml"
        echo "ErrorDocument 500 /500.shtml"
        echo "ErrorDocument 502 /502.shtml"
        echo "ErrorDocument 503 /503.shtml"
        echo "ErrorDocument 504 /504.shtml"
        echo "include /etc/apache2/go.conf"
        echo "include /etc/apache2/vhost/*.conf"
        echo "include /etc/apache2/port.conf"
    } | sudo tee /etc/apache2/apache2.conf >/dev/null

fi

# Creating /etc/nginx/nginx.conf file
{
    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        echo "user nginx;"
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
        echo "user www-data;"
    fi

    echo "worker_processes auto;"
    echo "pid /run/nginx.pid;"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        echo "error_log /var/log/nginx/error.log;"
        echo "include /usr/share/nginx/modules/*.conf;"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        echo "include /etc/nginx/modules-enabled/*.conf;"

    fi

    echo "events"
    echo "{"
    echo "    worker_connections 1024;"
    echo "}"
    echo "http"
    echo "{"
    echo "    log_format main '\$pid|\$server_name|\$remote_addr|\$http_cf_connecting_ip|\$http_cf_ipcountry|\$msec|\$time_iso8601|\$status|\$request_length|\$bytes_sent|\$request|\$http_referer|\$http_user_agent';"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        echo "    access_log  /var/log/nginx/access.log  main;"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        echo "    access_log /var/log/nginx/access.log;"
        echo "    error_log /var/log/nginx/error.log;"

    fi

    Dots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)
    if [ "$Dots" -lt "2" ]; then
        ServerName="_"
    else
        ServerName="$Hostname"
    fi

    echo "    gzip                  on;"
    echo "    sendfile              on;"
    echo "    tcp_nopush            on;"
    echo "    tcp_nodelay           on;"
    echo "    keepalive_timeout     65;"
    echo "    types_hash_max_size   4096;"
    echo "    client_max_body_size  128M;"
    echo "    client_body_timeout   3000;"
    echo "    client_header_timeout 3000;"
    echo "    fastcgi_read_timeout  3000;"
    echo "    proxy_read_timeout    600;"
    echo "    proxy_connect_timeout 600;"
    echo "    proxy_send_timeout    600;"
    echo "    large_client_header_buffers 4 32k;"
    echo "    include /etc/nginx/mime.types;"
    echo "	  include /etc/nginx/go.conf;"
    echo "	  include /etc/nginx/port.conf;"
    echo "    default_type        application/octet-stream;"
    echo "    include /etc/nginx/conf.d/*.conf;"
    echo "    server"
    echo "	  {"
    echo "    listen       80;"
    echo "    listen       [::]:80;"
    echo "    server_name  $Hostname $IPv4;"
    echo "    root         /usr/local/goadmio/home;"
    echo "    index index.html index.php;"
    echo "    error_page 404 /s404.html;"
    echo "    location = /404.shtml {}"
    echo "    error_page 500 502 503 504 /50x.shtml;"
    echo "    location = /50x.shtml {}"
    echo "    if (\$host = $Hostname)"
    echo "    {"
    echo "    return 301 https://\$host\$request_uri;"
    echo "    }"
    echo ""
    echo "    location ~ \.php$"
    echo "    {"
    echo "        try_files \$uri =404;"
    echo ""
    echo "        include fastcgi_params;"
    echo "        fastcgi_pass unix:/run/sock/85/go.sock;"
    echo "        fastcgi_index index.php;"
    echo ""
    echo "        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;"
    echo "        fastcgi_param SCRIPT_NAME     \$fastcgi_script_name;"
    echo "        fastcgi_param DOCUMENT_ROOT   \$document_root;"
    echo "    }"
    echo "}"
    echo ""

    # Hostname SSL (NGINX)
    if sudo test -f "/etc/letsencrypt/live/$Hostname/fullchain.pem"  && sudo test -f "/etc/letsencrypt/live/$Hostname/privkey.pem" ; then

        echo "server"
        echo "{"
        echo "    listen 443 ssl default_server;"
        echo "    listen [::]:443 ssl default_server;"
        echo "    http2 on;"
        echo "    root /usr/local/goadmio/home;"
        echo "    index index.html index.php;"
        echo "    server_name $Hostname;"
        echo "    location ~ \.php$ {include fastcgi_params;fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; fastcgi_pass unix:/run/sock/$SockLatest/go.sock;}"
        echo "    ssl_certificate /etc/letsencrypt/live/$Hostname/fullchain.pem;"
        echo "    ssl_certificate_key /etc/letsencrypt/live/$Hostname/privkey.pem;"
        echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
        echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
        echo ""
        echo "}"
        echo ""

    fi

    echo "    include /etc/nginx/vhost/*.conf;"
    echo "}"
} | sudo tee "$NginxConf" >/dev/null

if ! grep -q "port.conf" "$ApacheConf"; then

    echo "$ApachePortInclude" | sudo tee -a "$ApacheConf" >/dev/null

fi

if ! grep -q "go.conf" "$ApacheConf"; then

    echo "$ApacheGoInclude" | sudo tee -a "$ApacheConf" >/dev/null

fi

# Log Format + go.conf (Apache) — written as one block
{
    echo "LogFormat \"%P|%V|%h|%{CF-Connecting-IP}i|%{CF-IPCountry}i|%{%s}t|%{%Y-%m-%dT%H:%M:%S%z}t|%>s|%I|%b|%r%q|%{Referer}i|%{User-Agent}i\" go"
    echo ""

    # Allow .htaccess (All Sites)
    echo "<Directory /home>"
    echo "    Options Indexes FollowSymLinks"
    echo "    AllowOverride All"
    echo "    Order allow,deny"
    echo "    Allow from all"
    echo "    Require all granted"
    echo "</Directory>"
    echo ""

    # Allow PHP and Browsing
    echo "<Directory /usr/local/goadmio/home>"
    echo "    Options Indexes FollowSymLinks"
    echo "    AllowOverride All"
    echo "    Order allow,deny"
    echo "    Allow from all"
    echo "    Require all granted"
    echo "    <IfModule mod_proxy_fcgi.c>"
    echo "         <Files ~ (\.php$)>"
    echo "             SetHandler proxy:unix:/run/sock/$SockLatest/go.sock|fcgi://localhost"
    echo "         </Files>"
    echo "     </IfModule>"
    echo "     Options -Includes -ExecCGI"
    echo "</Directory>"
    echo ""

    # Hostname (Apache)
    echo "<VirtualHost *:80>"
    echo "    ServerAdmin support@goadmio.com"
    echo "	  DocumentRoot /usr/local/goadmio/home"
    echo "    ServerName $Hostname"
    echo "    <Directory />"
    echo "        Options Indexes FollowSymLinks"
    echo "        AllowOverride All"
    echo "        Order allow,deny"
    echo "        Allow from all"
    echo "        Require all granted"
    echo "        <IfModule mod_proxy_fcgi.c>"
    echo "            <Files ~ (\.php$)>"
    echo "            SetHandler proxy:unix:/run/sock/$SockLatest/go.sock|fcgi://localhost"
    echo "            </Files>"
    echo "        </IfModule>"
    echo "        Options -Includes -ExecCGI"
    echo "    </Directory>"
    echo "</VirtualHost>"
    echo ""

    # Hostname SSL (Apache)
    if sudo test -f "/etc/letsencrypt/live/$Hostname/cert.pem" ; then

        if sudo test -f /etc/httpd/conf.d/ssl.conf ; then
            # Remove VirtualHost Block from /etc/httpd/conf.d/ssl.conf (Conflict with Current Block)
            sudo sed -i '/<VirtualHost _default_:443>/,/<\/VirtualHost>/d' /etc/httpd/conf.d/ssl.conf
        fi

        echo "<IfModule mod_ssl.c>"
        echo "<VirtualHost *:443>"
        echo "    Protocols h2 http/1.1"
        echo "    ServerAdmin webmaster@$Hostname"
        echo "    DocumentRoot /usr/local/goadmio/home"
        echo "    ServerName $Hostname"
        echo ""
        echo "    <Proxy \"unix:/run/sock/$SockLatest/go.sock|fcgi://localhost\">"
        echo "        ProxySet disablereuse=off"
        echo "        ProxySet connectiontimeout=5 timeout=900"
        echo "    </Proxy>"
        echo ""
        echo "    <FilesMatch \.php\$>"
        echo "        SetHandler proxy:fcgi://localhost"
        echo "    </FilesMatch>"
        echo ""
        echo "    Include /etc/letsencrypt/options-ssl-apache.conf"
        echo "    SSLCertificateFile /etc/letsencrypt/live/$Hostname/cert.pem"
        echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$Hostname/privkey.pem"
        echo "    SSLCertificateChainFile /etc/letsencrypt/live/$Hostname/chain.pem"
        echo "</VirtualHost>"
        echo "</IfModule>"
        echo ""

    fi

    echo "Alias /go /usr/local/goadmio/home/go"
    echo "Alias /webmail /usr/local/goadmio/home/go/webmail"
    echo "Alias /roundcube /usr/local/goadmio/home/go/webmail/roundcube"
    echo "Alias /rainloop /usr/local/goadmio/home/go/webmail/rainloop"
    echo "Alias /phpmyadmin /usr/local/goadmio/home/go/phpmyadmin"
    echo ""

    echo "# Alias Domains"
    cd /home || exit
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            echo "Alias /$Domain /home/$Domain/www"

        fi

    done
} | sudo tee "$ApacheGo" >/dev/null

# PORTS (Apache)
{
    echo "Listen 2020"
    echo "Listen 2021"
    echo "Listen 2024"
    echo "Listen 2025"
    echo "Listen 2080"
    echo "Listen 2082"
    echo "Listen 2086"
    echo "Listen 2095"
    echo "Listen 2096"

    echo "<VirtualHost *:2020 *:2082 *:2086>"
    echo "    DocumentRoot /usr/local/goadmio/home/go"
    echo "	  CustomLog /var/log/2020.log combined env=DISABLED"
    echo "	  <Directory />"
    echo "        Options Indexes FollowSymLinks"
    echo "		  AllowOverride All"
    echo "		  Order allow,deny"
    echo "		  Allow from all"
    echo "		  Require all granted"
    echo "	      <IfModule mod_proxy_fcgi.c>"
    echo "	          <Files ~ (\.php$)>"
    echo "	              SetHandler proxy:unix:/run/sock/$SockLatest/go.sock|fcgi://localhost"
    echo "	          </Files>"
    echo "	      </IfModule>"
    echo "	      Options -Includes -ExecCGI"
    echo "    </Directory>"
    echo "</VirtualHost>"

    echo "<VirtualHost *:2024 *:2095>"
    echo "	DocumentRoot /usr/local/goadmio/home/go/webmail"
    echo "	<Directory />"
    echo "		Options Indexes FollowSymLinks"
    echo "		AllowOverride All"
    echo "		Order allow,deny"
    echo "		Allow from all"
    echo "		Require all granted"
    echo "	</Directory>"
    echo "</VirtualHost>"
} | sudo tee "$ApachePort" >/dev/null

# go.conf (Empty for NGINX)
echo "" | sudo tee "$NginxGo" >/dev/null

# Ports (NGINX)
{
    echo "server"
    echo "{"
    echo "    listen 2020;"
    echo "    listen 2082;"
    echo "    server_name $Hostname;"
    echo "    root /usr/local/goadmio/home/go;"
    echo "    index index.html index.php;"
    echo "    location ~ \.php$"
    echo "    {"
    echo "        include fastcgi_params;"
    echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;"
    echo "        fastcgi_split_path_info ^(.+\.php)(/.+)$;"
    echo "        fastcgi_pass unix:/run/sock/$SockLatest/go.sock;"
    echo "        fastcgi_index index.php;"
    echo "    }"
    echo "}"
    echo ""

    echo "server"
    echo "{"
    echo "    listen 2024;"
    echo "    listen 2095;"
    echo "    server_name $Hostname;"
    echo "    root /usr/local/goadmio/home/go/webmail;"
    echo "    index index.html index.php;"
    echo "    location ~ \.php$"
    echo "    {"
    echo "        include fastcgi_params;"
    echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;"
    echo "        fastcgi_split_path_info ^(.+\.php)(/.+)$;"
    echo "        fastcgi_pass unix:/run/sock/$SockLatest/go.sock;"
    echo "        fastcgi_index index.php;"
    echo "    }"
    echo "}"
    echo ""
} | sudo tee "$NginxPort" >/dev/null

if [[ ! "$@" = *"--install"* ]]; then
    # Create Go Socket
    sudo /go/php-fpm go go
fi