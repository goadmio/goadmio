#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    
    if [[ "$VERSION" = *"9."* ]]; then
        
        sudo systemctl stop httpd
        sudo rm -rf /usr/sbin/httpd
        sudo dnf -y remove httpd
        sudo dnf -y remove httpd-core
        
        sudo dnf -y install https://repo.codeit.guru/codeit-repo-release.el9.rpm
        sudo dnf -y module reset httpd
        sudo dnf -y module enable httpd:codeit
        
        sudo dnf -y install httpd
        sudo dnf -y install httpd-core
        sudo dnf -y install mod_fcgid
        sudo dnf -y install php-fpm
        sudo /go/installssl

    fi

fi
