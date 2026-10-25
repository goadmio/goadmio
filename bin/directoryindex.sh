#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    APACHE="/etc/httpd/conf/httpd.conf"
    NGINX="/etc/nginx/nginx.conf"
elif [ "$OS" = "Debian" ]; then
    APACHE="/etc/apache2/mods-enabled/dir.conf"
    NGINX="/etc/nginx/sites-available/default"
elif [ "$OS" = "Ubuntu" ]; then
    APACHE="/etc/apache2/mods-enabled/dir.conf"
    NGINX="/etc/nginx/sites-available/default"
else
    echo "Unknown operating system."
    exit
fi

ApacheValue=$(sed -n 's/^.*DirectoryIndex\s*//p' $APACHE | head -1)
NginxValue=$(sed -n '/^\s*index\s/s/^\s*index\s*//p' /etc/nginx/nginx.conf | sed 's/;//')

if [ "${1,,}" = "return" ]; then
    echo "$ApacheValue"
    exit 1
fi

if [ $# -eq 0 ] || [[ "$1" = --* ]]; then
    ApacheValue="default.html index.html index.htm index.php go.html"
    NginxValue="default.html index.html index.htm index.php go.html"
else
    if [ "$1" = "default" ]; then
        ApacheValue="default.html index.html index.php go.html"
        NginxValue="default.html index.html index.php go.html"
    else
        ApacheValue=$@
        NginxValue=$@
    fi
fi

# Apache
sudo sed -i "s/\(^[[:space:]]*\)DirectoryIndex.*/\1DirectoryIndex $ApacheValue/g" $APACHE

# NGINX
sudo sed -i "s/\(^[[:space:]]*\)index.*/\1index $NginxValue;/g" /etc/nginx/nginx.conf

if [[ ! "@" = *"--noreload"* ]]; then
    sudo /go/reload "| Executed by $(basename "$0")"
fi
