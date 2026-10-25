#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo /go/installapache
    sudo /go/installnginx
    sudo /go/go --install

    # Temporary website to default it when access by Server IP (GoAdmio Inatalling)
    echo "<Directory /usr/local/goadmio/install>" | sudo tee /etc/httpd/go.conf >/dev/null
    echo "	  Options Indexes FollowSymLinks" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  AllowOverride All" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  Order allow,deny" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  Allow from all" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  Require all granted" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "</Directory>" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "<VirtualHost *:80>" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  ServerAdmin support@goadmio.com" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "	  DocumentRoot /usr/local/goadmio/install" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "</VirtualHost>" | sudo tee -a /etc/httpd/go.conf >/dev/null
    echo "" | sudo tee -a /etc/httpd/go.conf >/dev/null

    sudo systemctl enable httpd

    # Disable CGI (Perl)
    sudo rm -rf /etc/httpd/conf.modules.d/*-cgi.conf

    # Allow host on /home
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo /go/installapache
    sudo /go/installnginx
    sudo /go/go --install

    # Temporary website to default it when access by Server IP (GoAdmio Inatalling)
    echo "<Directory /usr/local/goadmio/install>" | sudo tee /etc/apache2/go.conf >/dev/null
    echo "	  Options Indexes FollowSymLinks" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "	  AllowOverride None" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "	  Require all granted" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "</Directory>" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "<VirtualHost *:80>" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "	  ServerAdmin support@goadmio.com" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "	  DocumentRoot /usr/local/goadmio/install" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "</VirtualHost>" | sudo tee -a /etc/apache2/go.conf >/dev/null
    echo "" | sudo tee -a /etc/apache2/go.conf >/dev/null

    sudo systemctl enable apache2

fi

sudo /go/allow 80

# Default Template
sudo /go/default

if sudo test ! -f "/etc/resolv.bak" ; then

    sudo cp /etc/resolv.conf /etc/resolv.bak
    sudo /go/resolver

fi

# Disable "You have new mail in /var/mail/root"
sudo sed -i "s/MAILTO=root/MAILTO=\"\"/g" /etc/crontab

sudo /go/web

if [[ $@ = *"--install"* ]]; then

    sleep 3

    clear
    sudo cat /go/logo.img
    IP=$(curl -s -4 checkip.amazonaws.com)
    echo "To track installation progress open IP http://$IP in browser."

    sleep 10s

else

    # After Reinstall Apache
    sudo /go/conf --force

fi
