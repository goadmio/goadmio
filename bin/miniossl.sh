#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/minio)
OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

Code=$(sudo /usr/bin/certbot certificates -d $Hostname 2>/dev/null | grep days | awk '{print $6}')
Days=$(echo "$Code" | tail -1)
Days=$((Days))

if [[ "$Days" =~ ^[0-9]+$ ]]; then

    echo "SSL certificate for $Hostname expires in $Days days."

    if [ "$Days" -lt "30" ]; then

        sudo /usr/bin/certbot delete --noninteractive --quiet --cert-name $Hostname &>/dev/null
        sudo /usr/bin/certbot delete --noninteractive --quiet --cert-name $Hostname-* &>/dev/null
        sudo rm -rf /etc/letsencrypt/live/$Hostname
        sudo rm -rf /etc/letsencrypt/archive/$Hostname

    fi

fi

sudo /usr/bin/rm -rf /usr/local/goadmio/minio/.minio/certs/public.crt
sudo /usr/bin/rm -rf /usr/local/goadmio/minio/.minio/certs/private.key

if grep -q ":443 " /usr/local/goadmio/minio/minio.conf; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl stop nginx
            sudo systemctl disable nginx
        else
            sudo systemctl stop httpd
            sudo systemctl disable httpd
        fi

        cd /etc/opt/remi
        for Version in *; do
            if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then
                sudo systemctl stop $Version-php-fpm
                sudo systemctl disable $Version-php-fpm
            fi
        done

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl stop nginx
            sudo systemctl disable nginx
        else
            sudo systemctl stop apache2
            sudo systemctl disable apache2
        fi

        cd /etc/php
        for Version in *; do

            if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then
                sudo systemctl stop php$Version-fpm
                sudo systemctl disable php$Version-fpm
            fi

        done

    fi

fi

if sudo test ! -d "/etc/letsencrypt/live/$Hostname" || [[ $@ = *"--force"* ]]; then

    sudo /usr/bin/certbot delete --noninteractive --quiet --cert-name $Hostname &>/dev/null
    sudo /usr/bin/certbot delete --noninteractive --quiet --cert-name $Hostname-* &>/dev/null

    if [[ $@ = *"--buypass"* ]]; then
        sudo /usr/bin/certbot certonly --standalone --server https://api.buypass.com/acme/directory --noninteractive --agree-tos --email info@$Hostname -d $Hostname --cert-name $Hostname
    else
        sudo /usr/bin/certbot certonly --standalone --noninteractive --agree-tos --email info@$Hostname -d $Hostname --cert-name $Hostname
    fi

fi

if sudo test -d "/etc/letsencrypt/live/$Hostname" ; then

    echo "Installing SSL Certificates on MinIO Server Hostname $Hostname..."

    sudo mkdir -p /backup/s3
    sudo mkdir -p /usr/local/goadmio/minio/.minio/certs

    sudo /usr/bin/cp /etc/letsencrypt/live/$Hostname/fullchain.pem /usr/local/goadmio/minio/.minio/certs/public.crt
    sudo /usr/bin/cp /etc/letsencrypt/live/$Hostname/privkey.pem /usr/local/goadmio/minio/.minio/certs/private.key

    sudo chown -R minio:minio /usr/local/goadmio/minio
    sudo chown -R minio:minio /usr/local/goadmio/minio/.minio/certs
    sudo chown minio:minio /backup/s3

    sudo /usr/sbin/setcap 'cap_net_bind_service=+ep' /usr/local/goadmio/minio/bin/minio

    sudo systemctl restart minio

else

    echo "Can not install SSL ($Hostname)"

fi
