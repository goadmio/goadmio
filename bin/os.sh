#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo mkdir -p /usr/local/goadmio/linux

if [ "$1" = "upgrade" ] || [[ "$@" = *"--upgrade"* ]] || [ "$1" = "update" ] || [[ "$@" = *"--update"* ]]; then

    LockFile="/usr/local/goadmio/lock/os.lock"
    if sudo test -f $LockFile ; then
        if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "1800" ]]; then
            InstanceFile=$(<$LockFile)
            echo "Instance ($InstanceFile) already running."
            exit 1
        fi
    fi
    echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
    trap 'sudo rm -f "$LockFile"' EXIT

    OS=$(</usr/local/goadmio/linux/os.db)

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo /go/installmariadb
        sudo dnf -y upgrade --skip-broken --allowerasing --nobest
        sudo dnf -y remove nodejs
        sudo dnf -y remove npm
        sudo dnf -y clean all
        sudo dnf -y upgrade
        sudo /go/os
        sudo /go/welcome
        sudo /go/swap
        sudo /go/package

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo /go/installmariadb
        sudo apt update && apt upgrade -y --fix-broken
        sudo /go/os
        sudo /go/welcome
        sudo /go/package

    fi

    if sudo test -f /usr/bin/vi  && sudo test -f /usr/bin/nano ; then
        sudo rm -rf /usr/bin/vi
        sudo cp /usr/bin/nano /usr/bin/vi
    fi

    sudo rm -f $LockFile
    exit 1

fi

Command=$(sudo cat /etc/redhat-release 2>/dev/null)
if echo $Command | grep -iqF "Red Hat"; then

    OS="Red Hat"
    echo "Red Hat" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/centos-release 2>/dev/null)
if echo $Command | grep -iqF centos; then

    OS="CentOS"
    echo "CentOS" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/fedora-release 2>/dev/null)
if echo $Command | grep -iqF fedora; then

    OS="Fedora"
    echo "Fedora" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/fedora-release | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/os-release 2>/dev/null)
if echo $Command | grep -iqF debian; then

    OS="Debian"
    echo "Debian" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/os-release 2>/dev/null)
if echo $Command | grep -iqF ubuntu; then

    OS="Ubuntu"
    echo "Ubuntu" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if sudo test ! -f "/usr/local/goadmio/linux/version.db" ; then

        if [[ "$VERSION" =~ [0-9] ]]; then
            echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
        fi

    fi

fi

Command=$(sudo cat /etc/almalinux-release 2>/dev/null)
if echo $Command | grep -iqF almalinux; then

    OS="AlmaLinux"
    echo "AlmaLinux" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/almalinux-release | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/rocky-release 2>/dev/null)
if echo $Command | grep -iqF rocky; then

    OS="Rocky"
    echo "Rocky" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/rocky-release | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/os-release 2>/dev/null)
if echo $Command | grep -iqF opensuse; then

    OS="OpenSUSE"
    echo "OpenSUSE" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if sudo test ! -f "/usr/local/goadmio/linux/version.db" ; then

        if [[ "$VERSION" =~ [0-9] ]]; then
            echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
        fi

    fi

fi

Command=$(sudo cat /etc/os-release 2>/dev/null)
if echo $Command | grep -iqF freebsd; then

    OS="FreeBSD"
    echo "FreeBSD" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION=$(sudo cat /etc/os-release | grep VERSION_ID | sed "s/[^0-9\.]//g")

    if [[ "$VERSION" =~ [0-9] ]]; then
        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null
    fi

fi

Command=$(sudo cat /etc/os-release 2>/dev/null)
if echo $Command | grep -iqF archlinux; then

    OS="Arch"
    echo "Arch" | sudo tee /usr/local/goadmio/linux/os.db >/dev/null

    VERSION="Latest"

    if sudo test ! -f "/usr/local/goadmio/linux/version.db" ; then

        echo "$VERSION" | sudo tee /usr/local/goadmio/linux/version.db >/dev/null

    fi

fi
