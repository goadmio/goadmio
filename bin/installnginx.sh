#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo systemctl stop nginx
    sudo dnf -y remove nginx
    sudo dnf -y remove nginx-core

sudo cat > /etc/yum.repos.d/nginx.repo << 'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/9/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

    sudo dnf -y install nginx 

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    # Remove existing nginx
    sudo apt purge -y nginx nginx-common nginx-core
    sudo apt autoremove -y

    # Install dependencies for adding the repository
    sudo apt update
    sudo apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring

    # Import the nginx signing key (modern method, replaces deprecated apt-key)
    sudo curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg > /dev/null

    # Add the official nginx stable repository
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list

    # Optional: pin the nginx.org repo so its packages take priority over Debian's
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
    
    # Update and install nginx
    sudo apt update
    sudo apt install -y nginx

fi

sudo sed -i 's|/usr/share/nginx/html|/usr/local/goadmio/home|g' /etc/nginx/conf.d/default.conf

sudo mkdir -p /etc/nginx/vhost
echo "" | sudo tee /etc/nginx/vhost/go.conf >/dev/null
