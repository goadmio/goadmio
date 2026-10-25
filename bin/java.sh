#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)

V=$1

if [ "$V" = "" ]; then
    V="17"
fi

ProgressBar "Installing Java $V"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y install java-$V-openjdk-devel
    alternatives --set java /usr/lib/jvm/java-$V-openjdk-*/bin/java

elif [[ "$OS" == "Debian" || "$OS" = "Ubuntu" ]]; then

    sudo apt -y install openjdk-$V-jdk
    sudo apt -y install default-jre
    sudo apt -y install default-jdk

fi
