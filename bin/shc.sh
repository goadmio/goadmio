#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

ProgressBar "Installing SHC"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y install shc
    sudo dnf -y install glibc-static

elif [ "$OS" = "Debian" ]; then

    sudo apt -y install shc

elif [ "$OS" = "Ubuntu" ]; then

    DEBIAN_FRONTEND='noninteractive' apt -y install shc

fi

# Install SHC Another method
if sudo test -d /usr/bin ; then

    if ! command -v shc &>/dev/null; then

        cd /tmp

        # 1. Download the source package
        sudo wget https://deb.debian.org/debian/pool/main/s/shc/shc_4.0.3.orig.tar.gz

        # 2. Extract the archive
        sudo tar -xzvf shc_4.0.3.orig.tar.gz
        cd shc-4.0.3

        # 3. Compile and install
        ./configure
        sudo make
        sudo make install

    fi

fi
