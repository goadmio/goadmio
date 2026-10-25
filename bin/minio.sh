#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

while getopts ":h:p:s:u:" opt; do
    case ${opt} in
    h) Hostname=$OPTARG ;;
    p) Password=$OPTARG ;;
    s) SSL=$OPTARG ;;
    u) Username=$OPTARG ;;
    \?) echo "Usage: minio [-u] Username [-p] Password [-h] Hostname [-s] y/n (Enable SSL Certificate on Port 443)" ;;
    esac
done

if [ "$Username" = "" ]; then

    Username="admin"

fi

if [ "$Password" = "" ]; then

    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

fi

if [ "$Hostname" = "" ]; then

    ReverseDNS=$(host $ServerIP | awk '{ print $5 }' | sed 's/.$//')
    Hostname="$ReverseDNS"

fi

if [ "$SSL" = "y" ]; then
    Port="443"
    URL="https://$Hostname"
else
    Port="3333"
    URL="https://$Hostname:3333"
fi

if [ ${#Username} -lt 5 ]; then
    echo "Error: Username must be at least 5 characters"
    exit 1
fi

if [ ${#Password} -lt 8 ]; then
    echo "Error: Password must be at least 8 characters"
    exit 1
fi

sudo userdel -f minio
useradd -s /sbin/nologin -d /usr/local/goadmio/minio minio

sudo mkdir -p /usr/local/goadmio/minio/bin
sudo mkdir -p /usr/local/goadmio/minio/.minio/certs
sudo mkdir -p /backup/s3

sudo rm -rf /usr/local/goadmio/minio/bin/minio
sudo wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/goadmio/minio/bin/minio

sudo chmod +x /usr/local/goadmio/minio/bin/minio

# SH File
echo "export MINIO_ROOT_USER=$Username" | sudo tee /usr/local/goadmio/minio/minio.sh >/dev/null
echo "export MINIO_ROOT_PASSWORD=$Password" | sudo tee -a /usr/local/goadmio/minio/minio.sh >/dev/null
echo "export MINIO_SERVER_URL=$URL" | sudo tee -a /usr/local/goadmio/minio/minio.sh >/dev/null
echo "# MINIO_CERT_PEM=/usr/local/goadmio/minio/.minio/certs/public.crt" | sudo tee -a /usr/local/goadmio/minio/minio.sh >/dev/null
echo "# MINIO_KEY_PEM=/usr/local/goadmio/minio/.minio/certs/private.key" | sudo tee -a /usr/local/goadmio/minio/minio.sh >/dev/null
echo "/usr/local/goadmio/minio/bin/minio server --address :443 --console-address :3334 /backup/s3" | sudo tee -a /usr/local/goadmio/minio/minio.sh >/dev/null

echo "MINIO_VOLUMES=/backup/s3" | sudo tee /usr/local/goadmio/minio/minio.conf >/dev/null
echo "MINIO_OPTS=\"--address :$Port --console-address :3334\"" | sudo tee -a /usr/local/goadmio/minio/minio.conf >/dev/null
echo "MINIO_DOMAIN=\"$Hostname\"" | sudo tee -a /usr/local/goadmio/minio/minio.conf >/dev/null
echo "MINIO_ROOT_USER=\"$Username\"" | sudo tee -a /usr/local/goadmio/minio/minio.conf >/dev/null
echo "MINIO_ROOT_PASSWORD=\"$Password\"" | sudo tee -a /usr/local/goadmio/minio/minio.conf >/dev/null

sudo chown -R minio:minio /usr/local/goadmio/minio
sudo chown minio:minio /backup/s3

# SERVICE="/etc/systemd/var/go/minio.service"
SERVICE="/lib/systemd/var/go/minio.service"

echo '[Unit]' >$SERVICE
echo 'Description=Minio' >>$SERVICE
echo 'Documentation=https://docs.minio.io' >>$SERVICE
echo 'Wants=network-online.target' >>$SERVICE
echo 'After=network-online.target' >>$SERVICE
echo 'AssertFileIsExecutable=/usr/local/goadmio/minio/bin/minio' >>$SERVICE
echo '' >>$SERVICE
echo '[Service]' >>$SERVICE
echo 'WorkingDirectory=/usr/local/goadmio/minio' >>$SERVICE
echo '' >>$SERVICE
echo 'User=minio' >>$SERVICE
echo 'Group=minio' >>$SERVICE
echo '' >>$SERVICE
echo 'PermissionsStartOnly=true' >>$SERVICE
echo '' >>$SERVICE
echo 'EnvironmentFile=-/usr/local/goadmio/minio/minio.conf' >>$SERVICE
echo 'ExecStartPre=/bin/bash -c "[ -n \"${MINIO_VOLUMES}\" ] || echo \"Variable MINIO_VOLUMES not set in /usr/local/goadmio/minio/minio.conf\""' >>$SERVICE
echo '' >>$SERVICE
echo 'ExecStart=/usr/local/goadmio/minio/bin/minio server $MINIO_OPTS $MINIO_VOLUMES' >>$SERVICE
echo '' >>$SERVICE
echo 'StandardOutput=journal' >>$SERVICE
echo 'StandardError=inherit' >>$SERVICE
echo '' >>$SERVICE
echo '# Specifies the maximum file descriptor number that can be opened by this process' >>$SERVICE
echo 'LimitNOFILE=65536' >>$SERVICE
echo '' >>$SERVICE
echo '# Disable timeout logic and wait until process is stopped' >>$SERVICE
echo 'TimeoutStopSec=0' >>$SERVICE
echo '' >>$SERVICE
echo '# SIGTERM signal is used to stop Minio' >>$SERVICE
echo 'KillSignal=SIGTERM' >>$SERVICE
echo '' >>$SERVICE
echo 'SendSIGKILL=no' >>$SERVICE
echo '' >>$SERVICE
echo 'SuccessExitStatus=0' >>$SERVICE
echo '' >>$SERVICE
echo '[Install]' >>$SERVICE
echo 'WantedBy=multi-user.target' >>$SERVICE

sudo systemctl enable minio
sudo systemctl restart minio

echo "API: $URL"
echo "Username: $Username"
echo "Password: $Password"
echo ""
echo "MinIO Config File: /usr/local/goadmio/minio/minio.conf"
echo "To restart MinIO Run: systemctl restart minio"

if sudo test ! -d "/etc/letsencrypt/live/$Hostname"; then

    sudo certbot delete --noninteractive --quiet --cert-name $Hostname &>/dev/null
    sudo certbot delete --noninteractive --quiet --cert-name $Hostname-* &>/dev/null

    sudo certbot --apache certonly --noninteractive --quiet --agree-tos --email info@$Hostname -d $Hostname --cert-name $Hostname
    sudo cp /etc/letsencrypt/live/$Hostname/fullchain.pem /usr/local/goadmio/minio/.minio/certs/public.crt
    sudo cp /etc/letsencrypt/live/$Hostname/privkey.pem /usr/local/goadmio/minio/.minio/certs/private.key

fi

sudo chown -R minio:minio /usr/local/goadmio/minio/.minio/certs

echo "$Hostname" | sudo tee /etc/minio >/dev/null

if [ "$SSL" = "y" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl disable nginx
            sudo systemctl stop nginx
        else
            sudo systemctl disable httpd
            sudo systemctl stop httpd
        fi

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl disable nginx
            sudo systemctl stop nginx
        else
            sudo systemctl disable apache2
            sudo systemctl stop apache2
        fi

    fi

else

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl enable nginx
            sudo systemctl restart nginx
        else
            sudo systemctl enable httpd
            sudo systemctl restart httpd
        fi

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        if [ "$WS" = "NGINX" ]; then
            sudo systemctl enable nginx
            sudo systemctl restart nginx
        else
            sudo systemctl enable apache2
            sudo systemctl restart apache2
        fi

    fi

fi

sudo /go/cron

# Install CLI
if sudo test ! -f "/usr/bin/mc" ; then
    sudo curl -s -o /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
    sudo chmod +x /usr/bin/mc
fi

# mc alias set myminio https://$Hostname:$Port $Username $Password

# Create new Bucket "khaled"
# mc mb myminio/khaled

# Allow public read access to bucket
# mc anonymous set download myminio/khaled

# mc admin user svcacct add --access-key "myuserserviceaccount" --secret-key "myuserserviceaccountpassword" myminio $Username
# mc du /backup/s3/mls
