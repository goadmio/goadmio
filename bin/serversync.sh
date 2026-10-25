#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/serversync "$@"
fi

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $1 '********' $3 >>/var/log/go/$(basename "$0").log

if [ $# -eq 0 ]; then
    echo "Missing Remote Server"
    exit 1
fi

LockFile="/usr/local/goadmio/lock/serversync.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi
echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
# Run When Click Ctrl+C
trap 'sudo rm -f "$LockFile"' EXIT

RemoteServer=$1
RemotePassword=$2
Port=$3

if [ "$Port" = "" ]; then
    Port="22222"
fi

sudo rm -rf /usr/local/goadmio/tmp/serversync
sudo mkdir -p /usr/local/goadmio/tmp/serversync
sudo mkdir -p /var/log/go/serversync

echo "" | sudo tee /usr/local/goadmio/tmp/connection.db >/dev/null
sudo sshpass -p "$RemotePassword" rsync --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /usr/local/goadmio/tmp/connection.db root@$RemoteServer:/usr/local/goadmio/tmp/connection.db &>/usr/local/goadmio/tmp/scp.db

if grep -iqE "permission|denied|error" /usr/local/goadmio/tmp/scp.db; then
    echo "REMOTE: Invalid username or password"
    exit 1
fi

echo -ne "Working... Please be patient"

sudo /go/ssh --serversync
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/ssh --serversync" >/dev/null 2>&1

# STOP Firewall & Fail2ban & CROND
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/firewall stop" >/dev/null 2>&1
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/cron stop" >/dev/null 2>&1

sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /etc/hostname root@$RemoteServer:/etc/hostname

# Create Accounts
cd /home
for Domain in *; do

    if sudo test -d /home/$Domain/www ; then

        sudo /go/siteconf $Domain
        source /home/$Domain/log/include/site.conf

        echo -ne "."

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/create --domain '$Domain' --username '$Username' --password '$Password' --documentroot '$DocumentRoot' --fullname '$FullName' --mobile '$Mobile' --email '$Email' --packageid '$PackageID' --diskspace '$DiskSpace' --bandwidth '$Bandwidth' --inode '$Inode' --ftpno '$FTPNo' --emailno '$EmailNo' --databaseno '$DatabaseNo' --subdomainno '$SubDomainNo' --aliasno '$AliasNo' --addonno '$AddonNo' --shell '$Shell' --jailedshell '$JailedShell' --timezone '$Timezone' --permission '$Permission' --description '$Description' --phpversion '$PHPVersion' --smtphost '$SMTPHost' --smtpuser '$SMTPUser' --smtppass '$SMTPPass' --smtpport '$SMTPPort' --sslcertificate '$SSLCertificate' --sslredirect '$SSLRedirect' --bot '$Bot' --proxy '$Proxy' --ftpstatus '$FTPStatus' --ftpupload '$FTPUpload' --ftpdownload '$FTPDownload' --ftpdelete '$FTPDelete' --backup '$Backup' --backupstamp '$BackupStamp' --expireson '$ExpiresOn' --domainexpireson '$DomainExpiresOn' --mailttl '$MailTTL' --browsercachettl '$BrowserCacheTTL' --apiignore '$APIIgnore' --userid '$UserID' --owner '$Owner' --timestamp '$TimeStamp' --skeleton '$Skeleton'" &>/dev/null

    fi

done

# Copy MySQL & PostgreSQL
sudo nohup /go/mysqlsync $1 $2 $3 >/var/log/go/serversync/mysql.log 2>&1 &
sudo nohup /go/postgresync $1 $2 $3 >/var/log/go/serversync/postgre.log 2>&1 &
N=1

# Copy SSL
sudo nohup /go/sslsync $1 $2 $3 >/var/log/go/serversync/ssl.log 2>&1 &
N=2

# Home SYNC
cd /home
for Domain in *; do

    if sudo test -d /home/$Domain/www ; then

        sudo nohup /go/homesync $1 $2 $Domain $Port >/var/log/go/serversync/$Domain.log 2>&1 &

        N=$(($N + 1))

    fi

done

print_percentage_bar() {
    local percentage=$1
    local width=50
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf "["
    printf "%${filled}s" | tr ' ' '-'
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%\n" "$percentage"
}

for ((i = 1; ; i++)); do

    clear

    F=$(ls /usr/local/goadmio/tmp/serversync | wc -l)

    P=$(($F * 100 / $N))

    ls -tr /usr/local/goadmio/tmp/serversync | sed "s/^/✓ /"

    echo ""

    print_percentage_bar $P

    if [ "$F" -eq "$N" ]; then
        break
    fi

    sleep 10

done

S3FSTAB=$(sudo cat /etc/fstab | grep passwd-s3fs)
if [[ "$S3FSTAB" = *"passwd-s3fs"* ]]; then
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "echo $S3FSTAB >> /etc/fstab"

    if sudo test -f /etc/passwd-s3fs ; then
        sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /etc/passwd-s3fs root@$RemoteServer:/etc/passwd-s3fs
    fi
fi

# Go Database
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/lib/sqlite root@$RemoteServer:/var/lib/sqlite >/dev/null 2>&1

# Go DB
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /usr/local/goadmio/db root@$RemoteServer:/usr/local/goadmio/db >/dev/null 2>&1

# System
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /var/go root@$RemoteServer:/var/go >/dev/null 2>&1

# Rclone
sudo sshpass -p "$RemotePassword" rsync --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /root/.config/rclone/rclone.conf root@$RemoteServer:/root/.config/rclone/rclone.conf >/dev/null 2>&1

# START Firewall & Fail2ban
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/firewall start" >/dev/null 2>&1
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/cron restart" >/dev/null 2>&1

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/checkid"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "screen -d -m bash -c '/go/fix'"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "screen -d -m bash -c '/go/installmail'"

echo ""

sudo rm -f $LockFile