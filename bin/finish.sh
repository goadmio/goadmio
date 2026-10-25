#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

TimeStamp=$(date +'%s')
Elapsed=$(</usr/local/goadmio/db/elapsed.db)
ElapsedSeconds=$(($TimeStamp - $Elapsed))
ElapsedH=$((ElapsedSeconds / 3600))
ElapsedM=$(((ElapsedSeconds / 60) % 60))
ElapsedS=$((ElapsedSeconds % 60))
TimeElapsed=$(printf "%02d:%02d:%02d\n" $ElapsedH $ElapsedM $ElapsedS)

echo "99||$TimeElapsed" | sudo tee /usr/local/goadmio/install/progress.html >/dev/null

sudo /go/disablefunctions-cli
sudo /go/ssh
sudo /go/dropbear
sudo /go/rclone
sudo /go/control
sudo /go/serverinfo &>/dev/null
sudo /go/sudoers
sudo /go/swap
sudo /go/logrotate 1
sudo /go/session

HardDiskInfo=$(/go/speed | grep "Hard")
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET HardDiskInfo='$HardDiskInfo'"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    if sudo test -d /run/screen ; then
        if [[ "$VERSION" = "10"* ]]; then
            sudo dnf -y reinstall screen
        fi
    fi
fi

sudo screen -d -m bash -c '/go/vendor'
sudo screen -d -m bash -c '/go/extension'

# sh /home/download.goadmio.com/www/bash/script.sh
# cp /var/lib/sqlite/script.db /home/download.goadmio.com/www/script/
sudo cp /usr/local/goadmio/script/script.db /var/lib/sqlite/

# Disable All Root Mail
sudo sed -i '/^root:/d' /etc/aliases
echo "root: /dev/null" | sudo tee -a /etc/aliases >/dev/null
newaliases

if sudo test -f "$HOME/.bash_profile" ; then

    if ! grep -q ":/go" $HOME/.bash_profile; then
        sudo sed -i "s/PATH=\$PATH:\$HOME\/bin/PATH=\$PATH:\$HOME\/bin:\/go/g" $HOME/.bash_profile
    fi

    if ! grep -q ":/go" $HOME/.bash_profile; then
        echo "PATH=\"\$PATH:/go\"" >>$HOME/.bash_profile
    fi

fi

if sudo test -f "$HOME/.profile" ; then
    if ! grep -q ":/go" $HOME/.profile; then
        echo "PATH=\"\$PATH:/go\"" >>$HOME/.profile
    fi
fi

sudo /go/my system

IP=$(curl -s -4 checkip.amazonaws.com)

sudo chown -R go:go /var/lib/sqlite

sudo chmod 755 -R /usr/local/goadmio
sudo chmod 555 -R /usr/local/goadmio/home/go
sudo chmod 777 -R /usr/local/goadmio/cache
sudo chmod 777 -R /usr/local/goadmio/home/go/webmail/snappymail/data

if [ ! -e /go ]; then
    sudo ln -s /usr/local/goadmio/bin /go
fi

sudo /go/mail restart
sudo /go/restart
sudo /go/profile

sudo rm -rf /root/latest

Hostname=$(</etc/hostname)

IFS='.' read -r -a Array <<<"$Hostname"

if [ "${Array[3]}" == "" ]; then

    Domain="${Array[1]}.${Array[2]}"

else

    Domain="${Array[1]}.${Array[2]}.${Array[3]}"

fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)
DomainIP=$(dig $Domain +short)

if [ "$DomainIP" = "$DomainIP" ]; then

    SenderEmail="no-reply@$Domain"

else

    SenderEmail="no-reply@$Hostname"

fi

Whois=$(whois $Domain)
AdminEmail=$(echo "$Whois" | grep -oP '(?<=Admin Email:).*')
AdminEmail="${AdminEmail//$'\r'/}"
AdminEmail=$(echo $AdminEmail | sed -e 's/^[ \t]*//')

if [[ "$AdminEmail" = *"@"* ]]; then

    echo -e "Thank you for installing GoAdmio.\nWebsite: https://www.goadmio.com" | mailx -s "GoAdmio Free Linux Web Hosting Control Panel" -r $SenderEmail $AdminEmail

fi

TechEmail=$(echo "$Whois" | grep -oP '(?<=Tech Email:).*')
TechEmail="${TechEmail//$'\r'/}"
TechEmail=$(echo $TechEmail | sed -e 's/^[ \t]*//')

if [[ "$TechEmail" = *"@"* ]] && [ "$AdminEmail" != $TechEmail ]; then

    echo -e "Thank you for installing GoAdmio.\nWebsite: https://www.goadmio.com" | mailx -s "GoAdmio Free Linux Web Hosting Control Panel" -r $SenderEmail $TechEmail

fi

# Backup GoAdmio Database
Date=$(date +'%Y-%m-%d')
sudo mkdir -p /var/lib/sqlite/backup/$Date
sudo cp /var/lib/sqlite/*.db /var/lib/sqlite/backup/$Date

# Send SMTP Email
echo -e "Thank you for installing GoAdmio.\nWebsite: https://www.goadmio.com" | mailx -s "GoAdmio Free Linux Web Hosting Control Panel" -r $SenderEmail info@$Domain
echo -e "Thank you for installing GoAdmio.\nWebsite: https://www.goadmio.com" | mailx -s "GoAdmio Free Linux Web Hosting Control Panel" -r $SenderEmail sales@$Domain
echo -e "Thank you for installing GoAdmio.\nWebsite: https://www.goadmio.com" | mailx -s "GoAdmio Free Linux Web Hosting Control Panel" -r $SenderEmail support@$Domain

sudo /go/upgrade --install

GoPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
AdminPassword=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    echo "$GoPassword" | passwd "go" --stdin
    echo "$AdminPassword" | passwd "admin" --stdin
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    GoPass=$(sudo openssl passwd $GoPassword)
    usermod -p $GoPass go
    AdminPass=$(sudo openssl passwd $AdminPassword)
    usermod -p $AdminPass admin
fi

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sudo cat /go/logo.img
echo "─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"
sudo /go/timezone
echo "─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"
echo "Thank you for installing GoAdmio"
echo "Installation Time: $TimeElapsed"
echo ""
echo "Accessing your account GoAdmio is done easily through your browser. All you need to do is type:"
echo "http://$IP:2020"
echo "or"
echo "http://$IP/go"
echo "Username: root"
echo "Password: your server’s root password"
echo "or login as Administrator"
echo "Username: admin"
echo "Password: $AdminPassword"
echo ""
echo "SSH Username: go"
echo "SSH Password: $GoPassword"
echo "SSH Port: 22"
echo "Alternative SSH Port: 22222"
echo ""
echo "If you have questions or need help, don't hesitate to get in touch."
echo "Email: support@goadmio.com"
echo "Website: www.goadmio.com"

nc -w 3 -vv -z gmail-smtp-in.l.google.com 25 >/usr/local/goadmio/tmp/25.db 2>&1
if grep -q -E "unreachable|Connection timed out|TIMEOUT|failed" /usr/local/goadmio/tmp/25.db; then

    ServerIP=$(curl -s -4 checkip.amazonaws.com)

    Whois=$(whois $ServerIP)
    Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}')

    if [ "$Organization" = "" ]; then
        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}')
    fi

    Organization=$(echo $Organization | sed -e 's/^[ \t]*//')

    echo "Your ISP $Organization blocking SMTP Port 25"

fi

echo "Installation finished."
