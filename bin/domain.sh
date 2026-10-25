#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

CurrentDomain=$1
Domain=$2
CurrentUsername=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$CurrentDomain'")

echo "A snapshot of the current domain ($Domain) will be taken before changing the primary domain..."
if [[ "$@" = *"--progress"* ]]; then
    echo "10"
fi

sudo /go/snapshot $CurrentDomain

echo "Changing primary domain started now..."
if [[ "$@" = *"--progress"* ]]; then
    echo "20"
fi

sudo /go/create --domain "$Domain" --username "$Username" --password "$Password" --documentroot "$DocumentRoot" --fullname "$FullName" --mobile "$Mobile" --email "$Email" --packageid "$PackageID" --diskspace "$DiskSpace" --bandwidth "$Bandwidth" --inode "$Inode" --ftpno "$FTPNo" --emailno "$EmailNo" --databaseno "$DatabaseNo" --subdomainno "$SubDomainNo" --aliasno "$AliasNo" --addonno "$AddonNo" --shell "$Shell" --jailedshell "$JailedShell" --timezone "$Timezone" --permission "$Permission" --description "$Description" --phpversion "$PHPVersion" --smtphost "$SMTPHost" --smtpuser "$SMTPUser" --smtppass "$SMTPPass" --smtpport "$SMTPPort" --sslcertificate "$SSLCertificate" --sslredirect "$SSLRedirect" --bot "$Bot" --proxy "$Proxy" --ftpstatus "$FTPStatus" --ftpupload "$FTPUpload" --ftpdownload "$FTPDownload" --ftpdelete "$FTPDelete" --backup "$Backup" --backupstamp "$BackupStamp" --expireson "$ExpiresOn" --domainexpireson "$DomainExpiresOn" --mailttl "$MailTTL" --browsercachettl "$BrowserCacheTTL" --apiignore "$APIIgnore" --userid "$UserID" --owner "$Owner" --timestamp "$TimeStamp" --skeleton "$Skeleton"
Username="$Domain"

sudo rm -rf /home/$Domain
sudo mv /home/$CurrentDomain /home/$Domain

sudo chgrp nobody /home/$Domain/www
sudo chown -R $Username:$Username /home/$Domain/www
sudo chmod 755 /home/$Domain

if [[ "$@" = *"--progress"* ]]; then
    echo "30"
fi

# Change default password for all MySQL Databases
sudo /go/phpmyadmin $Domain

# Delete (For Just Created Domain)
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "delete from Site where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "delete from Alias where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "delete from Subdomain where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "delete from Directory where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "delete from Mysql where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "delete from Postgre where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "delete from SQLite where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "delete from Mail where Domain='$Domain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "delete from Ftp where Domain='$Domain'"

# Replace
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/sqlite.db "UPDATE SQLite SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE FTP SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/httplog.db "UPDATE Httplog SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "UPDATE Ftplog SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "UPDATE Mysql SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Email=replace(Email,'$CurrentDomain','$Domain'),Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "UPDATE Subdomain SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/directory.db "UPDATE Directory SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/github.db "UPDATE Github SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "UPDATE Alias SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "UPDATE Block SET Domain='$Domain',Username='$Username' where Domain='$CurrentDomain'"

if [[ "$@" = *"--progress"* ]]; then
    echo "50"
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    VHOST="/etc/httpd/vhost/$CurrentDomain.conf"
    VHOSTSSL="/etc/httpd/vhost/$CurrentDomain-le-ssl.conf"

    # Delete PHP-FPM Pool
    sudo rm -rf /etc/php-fpm.d/$CurrentDomain.conf
    sudo rm -rf /etc/opt/remi/*/php-fpm.d/$CurrentDomain.conf

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    VHOST="/etc/apache2/vhost/$CurrentDomain.conf"
    VHOSTSSL="/etc/apache2/vhost/$CurrentDomain-le-ssl.conf"

    # Delete PHP-FPM Pool
    sudo rm -rf /etc/php/*/fpm/pool.d/$CurrentDomain.conf

fi

sudo userdel -f $CurrentUsername >/dev/null 2>&1
sudo rm -rf /home/$CurrentDomain
sudo rm -rf $VHOST
sudo rm -rf $VHOSTSSL

if [[ "$@" = *"--progress"* ]]; then
    echo "70"
fi

# NGINX
sudo rm -rf /etc/nginx/vhost/$CurrentDomain.conf
sudo rm -rf /etc/nginx/vhost/$CurrentDomain.bak

# Delete DNS Zone
sudo /go/zone $CurrentDomain delete

# Delete FTP Permissions
sudo rm -rf /etc/vsftpd/permission/$CurrentDomain

# Delete DKIM Record
sudo rm -rf /etc/opendkim/$CurrentDomain

echo "Primary domain name changed successfully..."

if [[ "$@" = *"--progress"* ]]; then
    echo "100"
fi
