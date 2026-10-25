#!/bin/bash

W=$(whoami)

if [ "$W" != "root" ]; then
    echo "Please login as root to continue."
    exit 1
fi

if [ "$1" = "update" ]; then

    sudo mkdir -p /usr/local/goadmio
    cd /usr/local/goadmio
    sudo rm -rf stable.tar.gz
    sudo wget https://download.goadmio.com/stable.tar.gz -q -t 1 -T 10 --no-check-certificate
    sudo tar -xzf stable.tar.gz

    sudo rm -f /go
    sudo ln -s /usr/local/goadmio/bin /go

    sudo /usr/local/goadmio/bin/update

    exit 1

fi

if [[ $@ = *"--force"* ]]; then
    sudo rm -rf /usr/local/goadmio
fi

Memory=$(free -m | grep Mem | awk '{ print $2 }')
if [ "$Memory" -lt "1500" ]; then

    echo "GoAdmio requires at least 2 GB of RAM to install."
    echo "Your system has low RAM (${Memory} MB). A 2 GB swap file will be added automatically to continue the installation."

    # ADD SWAP MEMORY
    Swap=$(free | awk '/Swap/ {print $2}')
    Swap=${Swap:-0}

    if [ "$Swap" -eq "0" ]; then

        echo "No swap space"

        fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile

        if ! grep -q " swap " /etc/fstab; then
            echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
        fi

    else

        echo "Swap size in KB: $Swap"

    fi

    echo "vm.swappiness=60" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
    sudo sysctl --system >/dev/null 2>&1

fi

sudo mkdir -p /usr/local/goadmio
sudo mkdir -p /usr/local/goadmio/db

if [ "$1" = "lite" ]; then

    echo "" | sudo tee /usr/local/goadmio/db/lite.db >/dev/null

fi

if command -v dnf &>/dev/null; then

    systemctl stop firewalld &>/dev/null

    sudo dnf -y upgrade
    sudo dnf -y install epel-release
    sudo crb enable

    echo -ne "Working... Please be patient"

    echo -ne "."
    sudo dnf -y install ca-certificates &>/dev/null
    echo -ne "."
    sudo dnf -y install wget &>/dev/null
    echo -ne "."
    sudo dnf -y install tar &>/dev/null
    echo -ne "."
    sudo dnf -y install gzip &>/dev/null
    echo -ne "."
    sudo dnf -y install rsync &>/dev/null
    echo -ne "."
    sudo dnf -y install net-tools &>/dev/null
    echo -ne "."
    sudo dnf -y install sudo &>/dev/null

fi

if command -v apt &>/dev/null; then

    systemctl stop ufw &>/dev/null

    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a

    sudo -E apt -y update
    sudo -E apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    sudo -E dpkg --configure -a --force-confdef --force-confold
    sudo -E apt -y autoremove
    sudo -E apt -y clean
    sudo -E apt -y autoclean

    source /etc/os-release
    if [ ! "$VERSION_ID" = "13" ]; then
        # Removed in Debian 13
        sudo -E apt -y install software-properties-common
    fi

    echo -ne "Working... Please be patient"

    echo -ne "."
    sudo apt -y install ca-certificates &>/dev/null
    echo -ne "."
    sudo apt -y install wget &>/dev/null
    echo -ne "."
    sudo apt -y install tar &>/dev/null
    echo -ne "."
    sudo apt -y install gzip &>/dev/null
    echo -ne "."
    sudo apt -y install rsync &>/dev/null
    echo -ne "."
    sudo apt -y install net-tools &>/dev/null
    echo -ne "."
    sudo apt -y install sudo &>/dev/null

fi

echo ""

if sudo test -d "/usr/local/goadmio/home/go" ; then
    echo "GoAdmio already installed on your system."
    echo "Force to reinstall GoAdmio run:"
    echo "./latest --force"
    echo "Recommended: Reinstall OS"
    exit 1
fi

cd /usr/local/goadmio
sudo rm -rf stable.tar.gz

Version=$(curl -s -k -m 10 --retry 0 https://download.goadmio.com/home/go/update/latest.txt | sed 's/[^0-9.]//g')
if [ "${#Version}" -ne 5 ]; then
    echo "A new version of GoAdmio is currently being uploaded. Please try again later."
    exit 1
fi
GoVersion=$(echo "$Version" | sed -E 's/([0-9]{2})([0-9])([0-9])([0-9])/\1.\2.\3/')

echo -e "\033[1;32mDownload GoAdmio - Latest Stable Version v${GoVersion}...\033[0m"

N=0
SiteArray=('https://download.goadmio.com' 'https://mirror.goadmio.com')
SiteArray=($(shuf -e "${SiteArray[@]}"))
for Site in "${SiteArray[@]}"; do

    N=$(($N + 1))

    if [ "$N" -ge "2" ]; then
        echo "${SiteArray[0]} Failed (Cannot download stable.tar.gz)"
        echo "Try $Site..."
    fi

    if sudo curl -f -m 60 -k -o "/usr/local/goadmio/stable.tar.gz" --progress-bar "$Site/stable.tar.gz"; then

        if gzip -t "/usr/local/goadmio/stable.tar.gz" 2>/dev/null; then
            break
        fi

    fi

done

if sudo test -f "/usr/local/goadmio/stable.tar.gz" ; then
    if ! gzip -t "/usr/local/goadmio/stable.tar.gz" 2>/dev/null; then
        sudo rm -rf "/usr/local/goadmio/stable.tar.gz"
    fi
fi

# Try with wget
if sudo test ! -f "/usr/local/goadmio/stable.tar.gz" ; then

    echo "Download is taking longer than expected. Try another mirror."

    SiteArray=('download.goadmio.com' 'mirror.goadmio.com')
    SiteArray=($(shuf -e "${SiteArray[@]}"))
    for Site in "${SiteArray[@]}"; do
        sudo wget "$Site/stable.tar.gz" -O "/usr/local/goadmio/stable.tar.gz" -t 1 -T 600 --no-check-certificate --progress=dot && break
    done

fi

if sudo test -f "stable.tar.gz" ; then

    if gzip -t stable.tar.gz; then

        sudo rm -rf /usr/local/goadmio/home/go
        sudo tar -xzf stable.tar.gz
        sudo rm -rf stable.tar.gz

    else

        echo "GoAdmio Download failed."
        exit 1

    fi

else

    sudo /go/resolver
    echo "GoAdmio Download failed. Try Again"
    exit 1

fi

echo -e "\033[1;32mDownload Completed Successfully.\033[0m"

TimeStamp=$(date +'%s')
echo "$TimeStamp" | sudo tee /usr/local/goadmio/db/elapsed.db >/dev/null

if [ ! -e /go ]; then
    sudo ln -s /usr/local/goadmio/bin /go
fi

echo -e "\033[1;33mCreating GoAdmio Directories...\033[0m"
sudo /go/mkdir
sleep 3

echo -e "\033[1;33mDetecting Current Running OS...\033[0m"
sudo /go/os
sleep 3

sudo /go/machine
sleep 3

echo -e "\033[1;33mEnabling SSH Root Access (Password auth, no key required)...\033[0m"
sudo /go/ssh
sleep 3

sudo /go/setup &
