#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

echo "Installing WEBP..."

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    sudo dnf -y install libwebp-tools
elif [ "$OS" = "Debian" ]; then
    sudo apt -y install webp
elif [ "$OS" = "Ubuntu" ]; then
    DEBIAN_FRONTEND='noninteractive' apt -y install webp
fi

# Install webp (another method bz it does not installed on Recky Linux Using dnf)
if sudo test -d /usr/bin ; then

    if sudo test ! -f "/usr/bin/cwebp" ; then

        # Latest Version Here https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html

        cd /usr/local/goadmio/tmp
        sudo wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.2.2-linux-x86-64.tar.gz -q -t 1 -T 20 --no-check-certificate && break

        if sudo test ! -f /usr/local/goadmio/tmp/libwebp-1.2.2-linux-x86-64.tar.gz ; then

            # Mirror
            sudo wget https://script.goadmio.com/package/libwebp-1.2.2-linux-x86-64.tar.gz -q -t 1 -T 20 --no-check-certificate >/usr/local/goadmio/tmp/libwebp-1.2.2-linux-x86-64.tar.gz && break

        fi

        sudo tar -zxf /usr/local/goadmio/tmp/libwebp-1.2.2-linux-x86-64.tar.gz -C /usr/local/goadmio/tmp
        sudo rm -rf /usr/local/goadmio/tmp/libwebp-1.2.2-linux-x86-64.tar.gz
        rsync -azlh --ignore-existing /usr/local/goadmio/tmp/libwebp-1.2.2-linux-x86-64/bin/* /usr/bin/

    fi

fi
