#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [[ $(free -m | grep Mem | awk '{ print $2 }') -lt "512" ]]; then

    echo "MariaDB requires at least 0.5 GB of RAM to install."
    exit 1

fi

source /go/function

Release=$(echo "${OS,,}")

MariaDBVersion=$1

if [ "$MariaDBVersion" = "" ]; then

    MariaDBVersion="12.3"

else

    sudo /go/removemariadb

fi

if sudo test -f "/usr/local/goadmio/mariadb.db" ; then
    MariaDBVersion=$(</usr/local/goadmio/mariadb.db)
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if command -v mariadb &>/dev/null; then

        echo "Upgrading MariaDB..."

        sudo dnf -y remove mariadb-server

    else

        ProgressBar "Installing MariaDB $MariaDBVersion"

    fi

    # Install MariaDB on (AlmaLinux/Rocky/CentOS ETC)
    # Create MariaDB Repository File
    echo "[mariadb]" | sudo tee /etc/yum.repos.d/mariadb.repo >/dev/null
    echo "name = MariaDB" | sudo tee -a /etc/yum.repos.d/mariadb.repo >/dev/null
    echo "baseurl = https://mirrors.gigenet.com/mariadb/yum/$MariaDBVersion/$Release/\$releasever/\$basearch" | sudo tee -a /etc/yum.repos.d/mariadb.repo >/dev/null
    echo "module_hotfixes=1" | sudo tee -a /etc/yum.repos.d/mariadb.repo >/dev/null
    echo "gpgkey = https://mirrors.gigenet.com/mariadb/yum/RPM-GPG-KEY-MariaDB" | sudo tee -a /etc/yum.repos.d/mariadb.repo >/dev/null
    echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/mariadb.repo >/dev/null

    # Clean and Update Repository Cache
    sudo dnf -y clean all

    sudo dnf -y install galera-4
    sudo dnf -y install mariadb-server
    sudo dnf -y install mariadb-backup

    if ! command -v mariadb &>/dev/null; then

        # Remove MariaDB
        sudo /go/removemariadb

        # Method 2: Using MariaDB Official Setup Script
        sudo curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=$MariaDBVersion

        # Clean and Update Repository Cache
        sudo dnf -y clean all

        sudo dnf -y install galera-4
        sudo dnf -y install mariadb-server
        sudo dnf -y install mariadb-backup

    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if command -v mariadb &>/dev/null; then

        echo "Upgrading MariaDB..."

        DEBIAN_FRONTEND='noninteractive' apt -y remove mariadb-server
        DEBIAN_FRONTEND='noninteractive' apt -y remove mariadb-client
        DEBIAN_FRONTEND='noninteractive' apt -y remove mariadb-backup

    else

        echo "Installing MariaDB $MariaDBVersion..."

    fi

    DEBIAN_FRONTEND='noninteractive' apt -y install software-properties-common
    DEBIAN_FRONTEND='noninteractive' apt -y install dirmngr
    DEBIAN_FRONTEND='noninteractive' apt -y install gnupg2

    sudo curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=$MariaDBVersion

    DEBIAN_FRONTEND='noninteractive' apt update
    DEBIAN_FRONTEND='noninteractive' apt -y install mariadb-server
    DEBIAN_FRONTEND='noninteractive' apt -y install mariadb-client
    DEBIAN_FRONTEND='noninteractive' apt -y install mariadb-backup

elif [ "$OS" = "OpenSUSE" ]; then

    echo ""

fi

sudo systemctl enable mariadb

sudo /go/my &>/dev/null
sudo /go/web

# Securing MariaDB
sudo mariadb -e "DROP DATABASE IF EXISTS test;"
sudo mariadb -e "DELETE FROM mysql.user where user='';"
sudo mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
