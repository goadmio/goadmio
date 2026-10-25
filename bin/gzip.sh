#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# For NGINX (Not Apache)

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    CONFIG="/etc/nginx/nginx.conf"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    CONFIG="/etc/nginx/nginx.conf"
else
    echo "Unknown operating system."
    exit
fi

# Remove line start with #
sudo sed -i "/^#/d" $CONFIG

Code=$(sudo grep "^        gzip " $CONFIG)

if [ "$Code" = "" ]; then
    Code=$(sudo grep "gzip " $CONFIG)

    Value=$(echo $Code | sed -e 's/gzip //g')
else
    Code=$(sudo grep "gzip " $CONFIG)

    Value=$(echo $Code | sed -e 's/gzip //g')
fi

# TRIM String
Value=$(echo $Value | sed -e 's/^[ \t]*//')

if [ "$Value" = "" ]; then
    echo "gzip not exists."
    exit 1
fi

if [ "${1,,}" = "return" ]; then

    # Remove ; from Value
    Value=$(echo "${Value/;/}")

    echo "$Value"
    exit 1

fi

if [ $# -eq 0 ]; then

    read -p "gzip: " -e -i "$Value" Value

else

    if [ "$1" = "default" ]; then
        Value="on"
    else
        Value=$@
    fi
fi

if [[ "$Value" = *";" ]]; then

    sudo sed -i "s/$Code/        gzip $Value/g" $CONFIG

else

    sudo sed -i "s/$Code/        gzip $Value;/g" $CONFIG

fi

echo "Gzip updated successfully."

sudo /go/reload "| Executed by $(basename "$0")"
