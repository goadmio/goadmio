#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    Code=$(dnf search php | grep -oP 'PHP \d+\.\d+' | sort -u)

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    Code=$(apt-cache search php | grep -Eo '^php[0-9]+\.[0-9]+' | sort | uniq)

fi

if [[ "$Code" = *"5.6"* ]]; then
    echo "5.6"
fi

if [[ "$Code" = *"7.0"* ]]; then
    echo "7.0"
fi

if [[ "$Code" = *"7.1"* ]]; then
    echo "7.1"
fi

if [[ "$Code" = *"7.2"* ]]; then
    echo "7.2"
fi

if [[ "$Code" = *"7.3"* ]]; then
    echo "7.3"
fi

if [[ "$Code" = *"7.4"* ]]; then
    echo "7.4"
fi

if [[ "$Code" = *"8.0"* ]]; then
    echo "8.0"
fi

if [[ "$Code" = *"8.1"* ]]; then
    echo "8.1"
fi

if [[ "$Code" = *"8.2"* ]]; then
    echo "8.2"
fi

if [[ "$Code" = *"8.3"* ]]; then
    echo "8.3"
fi

if [[ "$Code" = *"8.4"* ]]; then
    echo "8.4"
fi

if [[ "$Code" = *"8.5"* ]]; then
    echo "8.5"
fi

if [[ "$Code" = *"8.6"* ]]; then
    # Skip Beta
    Skip=1
    # echo "8.6"
fi

if [[ "$Code" = *"8.7"* ]]; then
    echo "8.7"
fi

if [[ "$Code" = *"8.8"* ]]; then
    echo "8.8"
fi

if [[ "$Code" = *"8.9"* ]]; then
    echo "8.9"
fi

if [[ "$Code" = *"9.0"* ]]; then
    echo "9.0"
fi

if [[ "$Code" = *"9.1"* ]]; then
    echo "9.1"
fi

if [[ "$Code" = *"9.2"* ]]; then
    echo "9.2"
fi

if [[ "$Code" = *"9.3"* ]]; then
    echo "9.3"
fi

if [[ "$Code" = *"9.4"* ]]; then
    echo "9.4"
fi

if [[ "$Code" = *"9.5"* ]]; then
    echo "9.5"
fi

if [[ "$Code" = *"9.6"* ]]; then
    echo "9.6"
fi

if [[ "$Code" = *"9.7"* ]]; then
    echo "9.7"
fi

if [[ "$Code" = *"9.8"* ]]; then
    echo "9.8"
fi

if [[ "$Code" = *"9.9"* ]]; then
    echo "9.9"
fi

if [[ "$Code" = *"10.0"* ]]; then
    echo "10.0"
fi
