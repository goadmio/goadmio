#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

echo "Installing Microsoft Fonts"

# /usr/share/fonts
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf groupinstall -y "fonts"

elif [ "$OS" = "Debian" ]; then

    sudo apt -y install msttcorefonts

elif [ "$OS" = "Ubuntu" ]; then

    sudo apt -y install msttcorefonts

else
    echo "Unknown operating system."
    exit 1
fi
