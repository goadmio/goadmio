#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    APACHE="/etc/httpd/conf/httpd.conf"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    APACHE="/etc/apache2/apache2.conf"
fi

Value=$(sudo grep -E "[[:space:]]*KeepAlive[[:space:]]" $APACHE | head -1 | cut -d' ' -f2 | tr -d "\"';" | xargs echo -n)

if [ "${1,,}" = "return" ]; then

    echo "$Value"
    exit 1

fi

if [ $# -eq 0 ] || [ "$1" = "--noreload" ]; then

    Value="On"

else

    Value=$@

fi

if grep -q "^[[:space:]]*KeepAlive[[:space:]]" $APACHE; then
    sudo sed -i "s/\(^[[:space:]]*\)KeepAlive[[:space:]].*/\1KeepAlive $Value/g" $APACHE
else
    echo "KeepAlive $Value" >>$APACHE
fi

echo "KeepAlive updated successfully."

if [[ ! "@" = *"--noreload"* ]]; then
    sudo /go/reload "| Executed by $(basename "$0")"
fi
