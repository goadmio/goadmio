#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

Domain=$1

if [ $# -eq 0 ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        Command=$(clamconf --version)
        if echo $Command | grep -iqF antivirus; then

            echo "Updating ClamAV antivirus..."
            freshclam --quiet

        else

            echo "Installing ClamAV antivirus..."
            sudo yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

        fi

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        Command=$(clamconf --version)
        if echo $Command | grep -iqF antivirus; then

            echo "Updating ClamAV antivirus..."
            freshclam

        else

            echo "Installing ClamAV antivirus..."
            sudo apt -y install clamav clamav-daemon

        fi

    else
        echo "Unknown operating system."
        exit
    fi

else

    if [ "$Domain" = "all" ]; then

        echo "Scanning All Domains..."
        clamscan --infected --remove --recursive /home

    elif sudo test -d "/home/$Domain" ; then

        echo "Scanning $Domain..."
        clamscan --infected --remove --recursive /home/$Domain

    fi

fi
