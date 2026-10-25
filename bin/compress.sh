#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

ProgressBar "Installing FUSE & Compressed Filesystem Tools"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf install -y fuse
    sudo dnf install -y fuse-zip
    sudo dnf install -y fuse-compress

    if ! command -v fusecompress &>/dev/null; then

        sudo dnf -y install autoconf
        sudo dnf -y install libtool
        sudo dnf -y install fuse-devel
        sudo dnf -y install zlib-devel
        sudo dnf -y install bzip2-devel
        sudo dnf -y install lz4-devel
        sudo dnf -y install lzo-devel
        sudo dnf -y install xz-devel

        sudo mkdir -p /usr/local/goadmio/tmp/fusecompress
        cd /usr/local/goadmio/tmp/fusecompress
        git clone https://github.com/FS-make-simple/fusecompress.git
        cd fusecompress
        ./autogen.sh
        ./configure --prefix=/usr/local
        sudo make -j$(nproc)
        sudo make install
        sudo ldconfig

    fi

    # Mount with auto-compression (using fuse-compress)
    # fusecompress -o allow_other /backup

    # To make it permanent, add to /etc/fstab:
    # /backup /backup fuse.fusecompress allow_other,defaults 0 0

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if [ "$OS" = "Debian" ]; then
        sudo apt update
        APTCMD="apt -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install"
    elif [ "$OS" = "Ubuntu" ]; then
        export DEBIAN_FRONTEND='noninteractive'
        sudo apt -y update
        APTCMD="apt -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install"
    fi

    # Install FUSE and compressed filesystem tools
    $APTCMD fuse
    $APTCMD libfuse-dev

    # Install compression tools (optional, depending on what fusecompress needs)
    $APTCMD zlib1g-dev
    $APTCMD libbz2-dev
    $APTCMD liblz4-dev
    $APTCMD lzo2-dev
    $APTCMD libxz-dev

fi
