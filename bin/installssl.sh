#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null
source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

ProgressBar "Installing Let's Encrypt"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [ "$WS" = "Apache" ]; then

        # Install Let's Encrypt on AlmaLinux (Apache)
        sudo dnf -y install mod_ssl openssl
        sudo dnf -y install certbot python3-certbot-apache

    else

        # Install Let's Encrypt on AlmaLinux (NGINX)
        sudo dnf -y install mod_ssl openssl
        sudo dnf -y install certbot python3-certbot-nginx

    fi

elif [ "$OS" = "Debian" ]; then

    if [ "$WS" = "Apache" ]; then

        dpkg --configure -a
        sudo apt -y purge certbot python3-certbot-apache
        sudo apt -y install certbot python3-certbot-apache

    else

        dpkg --configure -a
        sudo apt -y purge certbot python3-certbot-nginx
        sudo apt -y install certbot python3-certbot-nginx

    fi

elif [ "$OS" = "Ubuntu" ]; then

    if [ "$WS" = "Apache" ]; then

        dpkg --configure -a
        DEBIAN_FRONTEND='noninteractive' apt -y purge certbot python3-certbot-apache
        DEBIAN_FRONTEND='noninteractive' apt -y install certbot python3-certbot-apache

    else

        dpkg --configure -a
        DEBIAN_FRONTEND='noninteractive' apt -y purge certbot python3-certbot-nginx
        DEBIAN_FRONTEND='noninteractive' apt -y install certbot python3-certbot-nginx

    fi

fi