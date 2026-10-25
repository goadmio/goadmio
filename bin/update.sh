#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/update "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$@" = *"beta"* ]]; then
    VersionFile="beta.tar.gz"
else
    VersionFile="stable.tar.gz"
fi

Version=$(curl -s -k -m 10 --retry 0 https://download.goadmio.com/home/go/update/latest.txt | sed 's/[^0-9.]//g')
if [ "${#Version}" -ne 5 ]; then
    echo "A new version of GoAdmio is currently being uploaded. Please try again later."
    exit 1
fi
GoVersion=$(echo "$Version" | sed -E 's/([0-9]{2})([0-9])([0-9])([0-9])/\1.\2.\3/')

echo "GoAdmio v${GoVersion} update in progress:"
echo "[1/5] Pausing firewall service..."
sudo /go/firewall stop

sudo rm -rf "/usr/local/goadmio/$VersionFile"
sudo rm -rf /usr/local/goadmio/cache/*

echo "[2/5] Downloading GoAdmio v${GoVersion}..."

N=0
SiteArray=('https://download.goadmio.com' 'https://mirror.goadmio.com')
SiteArray=($(shuf -e "${SiteArray[@]}"))
for Site in "${SiteArray[@]}"; do

    N=$(($N + 1))

    if [ "$N" -ge "2" ]; then
        echo "${SiteArray[0]} Failed (Cannot download $VersionFile)"
        echo "Try $Site..."
    fi

    if sudo curl -f -m 30 -k -o "/usr/local/goadmio/$VersionFile" --progress-bar "$Site/$VersionFile"; then

        if gzip -t "/usr/local/goadmio/$VersionFile" 2>/dev/null; then
        
            if [[ "$Site" = *"mirror"* ]]; then
                Type="Mirror"
            else
                Type="Official"
            fi

            break
        
        fi

    fi

done

if sudo test -f "/usr/local/goadmio/$VersionFile" ; then
    if ! gzip -t "/usr/local/goadmio/$VersionFile" 2>/dev/null; then
        sudo rm -rf "/usr/local/goadmio/$VersionFile"
    fi
fi

# Try with wget
if sudo test ! -f "/usr/local/goadmio/$VersionFile" ; then

    echo "Download is taking longer than expected. Try another mirror."

    SiteArray=('download.goadmio.com' 'mirror.goadmio.com')
    SiteArray=($(shuf -e "${SiteArray[@]}"))
    for Site in "${SiteArray[@]}"; do

        if [[ "$Site" = *"mirror"* ]]; then
            Type="Mirror"
        else
            Type="Official"
        fi

        sudo wget "$Site/$VersionFile" -O "/usr/local/goadmio/$VersionFile" -t 1 -T 600 --no-check-certificate --progress=dot && break

    done

fi

if sudo test -f "/usr/local/goadmio/$VersionFile" ; then

    echo "[3/5] Verifying package checksum [$Type]..."
    if gzip -t "/usr/local/goadmio/$VersionFile" 2>/dev/null; then

        echo "[4/5] Extracting GoAdmio v${GoVersion}..."

        sudo rm -rf /usr/local/goadmio/go/*
        sudo rm -rf /usr/local/goadmio/home/go/*.php
        sudo rm -rf /usr/local/goadmio/home/go/*.html
        cd /usr/local/goadmio || exit
        sudo tar -xzf "$VersionFile"
        sudo rm -rf "$VersionFile"

    else

        echo "GoAdmio Update failed."
        exit 1

    fi

else

    sudo /go/resolver
    echo "GoAdmio Update failed. Try Again"
    exit 1

fi

if [ "$Version" != "" ]; then
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set Version='$Version'"
fi

if sudo test -f /go/tmp; then
    sudo /go/tmp
fi

MinIO=0
if sudo test -f /usr/local/goadmio/minio/minio.conf ; then

    if grep -q ":443 " /usr/local/goadmio/minio/minio.conf; then
        MinIO=1
    fi

fi

if [ "$MinIO" = "0" ]; then

    sudo /go/start
    sudo /go/go
    sudo /go/userini
    sudo /go/include
    sudo /go/os
    sudo /go/database
    sudo /go/control
    sudo /go/session
    sudo /go/fm all
    sudo /go/checkphpini &>/dev/null
    sudo /go/upgrade

fi

sudo rm -rf /etc/cron.d/*.save*
sudo /go/cron

# Recreate Missing Log Files
sudo systemctl restart rsyslog

sudo /go/sqliterc
sudo /go/profile
sudo /go/end
sudo /go/firewall start

echo "[5/5] Update complete."