#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    APACHE="/etc/httpd/conf/httpd.conf"
elif [ "$OS" = "Debian" ]; then
    APACHE="/etc/apache2/apache2.conf"
    sudo rm -rf /etc/apache2/vhost/port.conf
elif [ "$OS" = "Ubuntu" ]; then
    APACHE="/etc/apache2/apache2.conf"
else
    echo "Unknown operating system."
    exit
fi

Value=$(sudo grep -E "[[:space:]]*MaxKeepAliveRequests[[:space:]]" $APACHE | head -1 | cut -d' ' -f2 | tr -d "\"';" | xargs echo -n)

if [ "${1,,}" = "return" ]; then

    echo "$Value"
    exit 1

fi

if [ $# -eq 0 ] || [[ "$1" = --* ]]; then
    Value=100
else
    Value=$@
fi

if grep -q "^[[:space:]]*MaxKeepAliveRequests[[:space:]]" $APACHE; then
    sudo sed -i "s/\(^[[:space:]]*\)MaxKeepAliveRequests[[:space:]].*/\1MaxKeepAliveRequests $Value/g" $APACHE
else
    echo "MaxKeepAliveRequests $Value" >>$APACHE
fi

echo "MaxKeepAliveRequests updated successfully."

if [[ ! "@" = *"--noreload"* ]]; then
    sudo /go/reload "| Executed by $(basename "$0")"
fi
