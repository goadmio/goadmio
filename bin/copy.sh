#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/copy "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $# -eq 0 ]; then
    echo "Missing Domain"
    exit 1
fi

LockFile="/usr/local/goadmio/lock/copy.lock"
if [ "$1" = "all" ]; then
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

fi

Domain=$1
RemoteServer=$2
RemotePassword=$3
Port=$4

if [ "$Port" = "" ]; then
    Port="22222"
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [[ $@ = *"--shadow"* ]]; then

    Domain=$1
    Username=$2

    if sudo test -f "/home/$Domain/log/shadow" ; then
        # Restore Linux Password
        sudo sed -i "/^$Username:/d" /etc/shadow
        LinuxPassword=$(</home/$Domain/log/shadow)
        echo "$LinuxPassword" | sudo tee -a /etc/shadow >/dev/null
        sudo rm -rf /home/$Domain/log/shadow
    fi

    exit 1

fi

if [[ $@ = *"--grant"* ]]; then

    Name=$1
    User=$2
    Pass=$3
    sudo mariadb -e "GRANT USAGE ON $Name.* TO '$User'@'localhost' IDENTIFIED BY PASSWORD '$Pass';"

    exit 1

fi

if [[ $@ = *"--import"* ]]; then

    Name=$1
    sudo /usr/bin/pv /usr/local/goadmio/tmp/$Name.sql | mariadb -uroot -p$MySQLRootPassword $Name

    exit 1

fi

if [ "$Domain" = "all" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        X=$(($X + 1))
        echo "[$X/$C] Copying $Domain..."
        sudo /go/copy $Domain $2 $3 $4

    done

    exit 1

fi

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")

if [[ ! "$DomainExists" = "$Domain" ]]; then
    echo "Domain $Domain not exists."
    exit 1
fi

echo "Copying $Domain to $RemoteServer..."
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/firewall stop" >/dev/null 2>&1

sudo /go/siteconf $Domain
source /home/$Domain/log/include/site.conf

echo "Creating Account $Domain..."
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/create --domain '$Domain' --username '$Username' --password '$Password' --documentroot '$DocumentRoot' --fullname '$FullName' --mobile '$Mobile' --email '$Email' --packageid '$PackageID' --diskspace '$DiskSpace' --bandwidth '$Bandwidth' --inode '$Inode' --ftpno '$FTPNo' --emailno '$EmailNo' --databaseno '$DatabaseNo' --subdomainno '$SubDomainNo' --aliasno '$AliasNo' --addonno '$AddonNo' --shell '$Shell' --jailedshell '$JailedShell' --timezone '$Timezone' --permission '$Permission' --description '$Description' --phpversion '$PHPVersion' --smtphost '$SMTPHost' --smtpuser '$SMTPUser' --smtppass '$SMTPPass' --smtpport '$SMTPPort' --sslcertificate '$SSLCertificate' --sslredirect '$SSLRedirect' --bot '$Bot' --proxy '$Proxy' --ftpstatus '$FTPStatus' --ftpupload '$FTPUpload' --ftpdownload '$FTPDownload' --ftpdelete '$FTPDelete' --backup '$Backup' --backupstamp '$BackupStamp' --expireson '$ExpiresOn' --domainexpireson '$DomainExpiresOn' --mailttl '$MailTTL' --browsercachettl '$BrowserCacheTTL' --apiignore '$APIIgnore' --userid '$UserID' --owner '$Owner' --timestamp '$TimeStamp' --skeleton '$Skeleton'"

echo "Copying WWW Files $Domain..."
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/www/ root@$RemoteServer:/home/$Domain/www/
echo "."

echo "Copying MAIL Files $Domain..."
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/mail/ root@$RemoteServer:/home/$Domain/mail/
echo "."

echo "Copying SQLITE Files $Domain..."
sudo sshpass -p "$RemotePassword" rsync -azlh -P --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/sqlite/ root@$RemoteServer:/home/$Domain/sqlite/
echo "."

echo "Set Password $Domain..."
# Shadow
sudo cat /etc/shadow | grep "$Username:" | sudo tee /home/$Domain/log/shadow >/dev/null
sudo sshpass -p "$RemotePassword" rsync -azlh --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/log/shadow root@$RemoteServer:/home/$Domain/log/
sudo rm -rf /home/$Domain/log/shadow
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/copy $Domain $Username --shadow"
echo "."

echo "Set Up Mail $Domain..."
# Create missing Email from folders
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/mail --domain $Domain --action create"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "chown -R vmail:vmail /home/$Domain/mail"
echo "."

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "chown -R $Username:$Username /home/$Domain/www"

echo "Copying Databases..."
# MySQL
Sql=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Username='$Username'")
for Name in $Sql; do

    User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select User from Mysql where Name='$Name'")
    Pass=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select Password from mysql.user where User='$User'")

    # Copy Database
    sudo mariadb-dump --skip-lock-tables -uroot -p$MySQLRootPassword $Name >/usr/local/goadmio/tmp/$Name.sql
    sudo sshpass -p "$RemotePassword" rsync -azlh --rsync-path="sudo rsync" -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /usr/local/goadmio/tmp/$Name.sql root@$RemoteServer:/usr/local/goadmio/tmp

    # Create Database
    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/mysql $Domain $Name $User $Password"

    # GRANT Database
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/copy $Name $User $Pass --grant"

    # Import Database
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/copy $Name --import"

    sudo rm -rf /usr/local/goadmio/tmp/$Name.sql

done

sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/checkid"
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/firewall start" >/dev/null 2>&1

sudo rm -f $LockFile
