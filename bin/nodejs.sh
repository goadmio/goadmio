#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

V=$1

if [ "$V" = "" ]; then
    V="22"
fi

if [ "$OS" = "CentOS" ]; then

    if [ "$VERSION" = "7" ]; then

        sudo curl -fsSL https://rpm.nodesource.com/setup_$V.x | sudo bash -
        sudo yum -y remove nodejs
        sudo yum -y install nodejs

        sudo yum -y install git

        sudo yum -y remove npm
        sudo yum -y install npm

        sudo npm install -g mudslide

    else

        sudo curl -fsSL https://rpm.nodesource.com/setup_$V.x | sudo bash -
        sudo dnf -y remove nodejs
        sudo dnf -y install nodejs

        sudo dnf -y install git

        sudo dnf -y remove npm
        sudo dnf -y install npm

        sudo npm install -g mudslide

    fi

elif [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo curl -fsSL https://rpm.nodesource.com/setup_$V.x | sudo bash -

    sudo dnf -y module list nodejs
    sudo dnf -y module enable nodejs:$V

    sudo dnf -y upgrade

    sudo dnf -y remove nodejs
    sudo dnf -y install nodejs
    sudo dnf -y install git

    sudo dnf -y remove npm
    sudo dnf -y install npm

    sudo npm install -g mudslide
    # docker run robvanderleek/mudslide

elif [ "$OS" = "Debian" ]; then

    sudo curl -fsSL https://rpm.nodesource.com/setup_$V.x | sudo bash -
    sudo apt -y purge nodejs
    sudo apt -y install nodejs

    sudo apt -y install git

    sudo apt -y remove npm
    sudo apt -y install npm

    sudo npm install -g mudslide

elif [ "$OS" = "Ubuntu" ]; then

    sudo curl -fsSL https://rpm.nodesource.com/setup_$V.x | sudo bash -
    sudo apt -y purge nodejs
    sudo apt -y install nodejs
    sudo apt -y install git

    sudo apt -y purge npm
    sudo apt -y install npm

    sudo npm install -g mudslide

else

    echo "Unknown operating system."
    exit 1

fi
