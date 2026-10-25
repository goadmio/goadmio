#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

echo "Installing Apache..."
echo "Apache" | sudo tee /usr/local/goadmio/linux/ws.db >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if [[ "$VERSION" = *"9."* ]]; then
        sudo dnf -y install https://repo.codeit.guru/codeit-repo-release.el9.rpm epel-release
        sudo dnf -y module enable -y httpd:codeit
    fi

    sudo dnf -y install httpd
    sudo dnf -y install mod_fcgid

    sudo mkdir -p /etc/httpd/vhost
    echo "" | sudo tee /etc/httpd/vhost/go.conf >/dev/null

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    DEBIAN_FRONTEND='noninteractive' apt -y install apache2
    sudo systemctl enable apache2

    sudo mkdir -p /etc/apache2/vhost
    echo "" | sudo tee /etc/apache2/vhost/go.conf >/dev/null

fi

