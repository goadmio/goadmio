#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

Action=$1

if sudo test -f /var/lib/sqlite/config.db ; then
    RemoteMariaDB=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT RemoteMariaDB from Config")
    SSHPort=$(($(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT SSHPort FROM Config WHERE ConfigID=1")))
fi

RemoteMariaDB=${RemoteMariaDB:-0}
SSHPort=${SSHPort:-22}

if command -v sqlite3 &>/dev/null; then

    AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
    APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

fi

if [ "$Action" = "start" ] || [ "$Action" = "stop" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo systemctl $Action firewalld >/dev/null 2>&1
        sudo systemctl $Action fail2ban >/dev/null 2>&1

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo systemctl $Action ufw >/dev/null 2>&1
        sudo systemctl $Action fail2ban >/dev/null 2>&1

    fi

    exit 1

fi

if [ "$Action" = "reset" ]; then

    sudo rm -rf /var/log/go/block/*

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo firewall-cmd --reset-to-defaults
        sudo firewall-cmd --reload

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        yes | ufw reset
        sudo ufw reload

    fi

fi

ProgressBar "Installing Firewall"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y install firewalld

    sudo systemctl start firewalld
    sudo systemctl enable firewalld

    sudo firewall-cmd --zone=public --add-service=ssh --permanent
    sudo firewall-cmd --zone=public --add-service=http --permanent
    sudo firewall-cmd --zone=public --add-service=https --permanent
    sudo firewall-cmd --zone=public --add-service=postgresql --permanent
    sudo firewall-cmd --zone=public --add-service=ftp --permanent
    sudo firewall-cmd --zone=public --add-service=smtp --permanent
    sudo firewall-cmd --zone=public --add-service=smtps --permanent
    sudo firewall-cmd --zone=public --add-service=pop3 --permanent
    sudo firewall-cmd --zone=public --add-service=pop3s --permanent
    sudo firewall-cmd --zone=public --add-service=imap --permanent
    sudo firewall-cmd --zone=public --add-service=imaps --permanent
    sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8005/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8070/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=9090/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8443/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=25/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=26/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=587/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=465/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=110/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=143/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=993/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=995/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=11211/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=20/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=21/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=33/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=44/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=53/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=53/udp --permanent
    sudo firewall-cmd --zone=public --add-port=1080/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=1194/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=1194/udp --permanent
    sudo firewall-cmd --zone=public --add-port=1883/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2000/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2001/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2002/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2003/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2004/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2005/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2020/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2021/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2022/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2023/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2024/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2025/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2026/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2027/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2030/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2080/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2082/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2083/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2086/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2087/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2095/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2096/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=2222/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=4433/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8891/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8893/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=10040/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=22222/tcp --permanent

    if [ "$RemoteMariaDB" -eq "1" ]; then
        sudo firewall-cmd --zone=public --add-service=mysql --permanent
        sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
    fi

    if [ ! "$SSHPort" -eq "22" ] && [ "$SSHPort" -ge "0" ]; then
        sudo firewall-cmd --zone=public --add-port=$SSHPort/tcp --permanent
    fi

    sudo firewall-cmd --zone=public --add-port=4444/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=4567/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=4568/tcp --permanent

    # MiniO S3
    sudo firewall-cmd --zone=public --add-port=3333/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=3334/tcp --permanent

    # Passive FTP
    sudo firewall-cmd --zone=public --add-port=30000-31000/tcp --permanent

    sudo firewall-cmd --reload

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo apt -y purge ufw
    sudo apt -y install ufw

    sudo ufw allow 'Nginx HTTP'

    # FTP
    sudo ufw allow 20/tcp
    sudo ufw allow 21/tcp

    # FTP Passive
    sudo ufw allow 30000:31000/tcp

    # TLS FTP
    sudo ufw allow 990/tcp

    sudo ufw allow Postfix
    sudo ufw allow OpenSSH

    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw allow postgresql
    sudo ufw allow ftp
    sudo ufw allow smtp
    sudo ufw allow pop3
    sudo ufw allow pop3s
    sudo ufw allow imap
    sudo ufw allow imaps

    sudo ufw allow 80/tcp
    sudo ufw allow 8005/tcp
    sudo ufw allow 8070/tcp
    sudo ufw allow 8080/tcp
    sudo ufw allow 9090/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 25/tcp
    sudo ufw allow 587/tcp
    sudo ufw allow 465/tcp
    sudo ufw allow 110/tcp
    sudo ufw allow 143/tcp
    sudo ufw allow 993/tcp
    sudo ufw allow 995/tcp
    sudo ufw allow 11211/tcp
    sudo ufw allow 20/tcp
    sudo ufw allow 21/tcp
    sudo ufw allow 22/tcp
    sudo ufw allow 33/tcp
    sudo ufw allow 44/tcp

    # named
    sudo ufw allow 53/tcp
    sudo ufw allow 53/udp

    sudo ufw allow 1080/tcp

    sudo ufw allow 1194/tcp
    sudo ufw allow 1194/udp

    sudo ufw allow 1883/tcp
    sudo ufw allow 2000/tcp
    sudo ufw allow 2001/tcp
    sudo ufw allow 2002/tcp
    sudo ufw allow 2003/tcp
    sudo ufw allow 2004/tcp
    sudo ufw allow 2005/tcp
    sudo ufw allow 2020/tcp
    sudo ufw allow 2021/tcp
    sudo ufw allow 2022/tcp
    sudo ufw allow 2023/tcp
    sudo ufw allow 2024/tcp
    sudo ufw allow 2025/tcp
    sudo ufw allow 2026/tcp
    sudo ufw allow 2027/tcp
    sudo ufw allow 2030/tcp
    sudo ufw allow 2080/tcp
    sudo ufw allow 2082/tcp
    sudo ufw allow 2083/tcp
    sudo ufw allow 2086/tcp
    sudo ufw allow 2087/tcp
    sudo ufw allow 2095/tcp
    sudo ufw allow 2096/tcp
    sudo ufw allow 2222/tcp
    sudo ufw allow 3389/tcp
    sudo ufw allow 4433/tcp
    sudo ufw allow 8891/tcp
    sudo ufw allow 8893/tcp
    sudo ufw allow 10040/tcp
    sudo ufw allow 22222/tcp

    if [ "$RemoteMariaDB" -eq "1" ]; then
        sudo ufw allow mysql
        sudo ufw allow 3306/tcp
    fi

    if [ ! "$SSHPort" -eq "22" ] && [ "$SSHPort" -ge "0" ]; then
        sudo ufw allow $SSHPort/tcp
    fi

    sudo ufw allow 4444/tcp
    sudo ufw allow 4567/tcp
    sudo ufw allow 4568/tcp

    # MiniO S3
    sudo ufw allow 3333/tcp
    sudo ufw allow 3334/tcp

    sudo systemctl start ufw
    sudo systemctl enable ufw

    sudo ufw --force enable
    
    sudo ufw reload

else
    echo "Unknown operating system."
    exit 1
fi

if [ "$Action" = "reset" ]; then
    sudo /go/waf reset
fi
