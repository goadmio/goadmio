#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [ "$WS" = "NGINX" ]; then

        if [[ "$@" = *"reload"* ]]; then
            sudo /usr/bin/systemctl reload nginx
        else
            sudo /usr/bin/systemctl restart nginx
        fi

    else

        if [[ "$@" = *"reload"* ]]; then
            sudo /usr/bin/systemctl reload httpd
        else
            sudo /usr/bin/systemctl restart httpd
        fi

    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$WS" = "NGINX" ]; then

        if [[ "$@" = *"reload"* ]]; then
            sudo /usr/bin/systemctl reload nginx
        else
            sudo /usr/bin/systemctl restart nginx
        fi

    else

        if [[ "$@" = *"reload"* ]]; then
            sudo /usr/bin/systemctl reload apache2
        else
            sudo /usr/bin/systemctl restart apache2
        fi

    fi

fi
