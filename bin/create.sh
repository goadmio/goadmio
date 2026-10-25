#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $# -eq 1 ]; then

	# Restore Using SITE.CONF
	Domain=$1

	if sudo test -f /home/$Domain/log/include/site.conf ; then

		# GoAdmio
		source /home/$Domain/log/include/site.conf

		Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
		
		# IF Backup PHP Version not Installed Get Latest Installed PHP Version
		if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
		
			if sudo test ! -f "/etc/opt/remi/$PHPVersion/php.ini" ; then

				cd /etc/opt/remi
				for Version in *
				do
					PHPVersion="$Version"
				done

			fi
			
		elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
		
			if sudo test ! -f "/etc/php/$PHPVersion/fpm/php.ini" ; then
			
				cd /etc/php
				for Version in *
				do
					PHPVersion="$Version"
				done
				
			fi
		
		fi
		
		sudo /go/create --domain "$Domain" --username "$Username" --password "$Password" --documentroot "$DocumentRoot" --fullname "$FullName" --mobile "$Mobile" --email "$Email" --packageid "$PackageID" --diskspace "$DiskSpace" --bandwidth "$Bandwidth" --inode "$Inode" --ftpno "$FTPNo" --emailno "$EmailNo" --databaseno "$DatabaseNo" --subdomainno "$SubDomainNo" --aliasno "$AliasNo" --addonno "$AddonNo" --shell "$Shell" --jailedshell "$JailedShell" --timezone "$Timezone" --permission "$Permission" --description "$Description" --phpversion "$PHPVersion" --smtphost "$SMTPHost" --smtpuser "$SMTPUser" --smtppass "$SMTPPass" --smtpport "$SMTPPort" --sslcertificate "$SSLCertificate" --sslredirect "$SSLRedirect" --bot "$Bot" --proxy "$Proxy" --ftpstatus "$FTPStatus" --ftpupload "$FTPUpload" --ftpdownload "$FTPDownload" --ftpdelete "$FTPDelete" --backup "$Backup" --backupstamp "$BackupStamp" --expireson "$ExpiresOn" --domainexpireson "$DomainExpiresOn" --mailttl "$MailTTL" --browsercachettl "$BrowserCacheTTL" --apiignore "$APIIgnore" --userid "$UserID" --owner "$Owner" --timestamp "$TimeStamp" --skeleton "$Skeleton"
	
	fi
	
	exit 1
	
fi

if [[ "$@" = *"--"* ]]; then

	Arguments=1

	while [[ "$#" -gt 0 ]]; do
		case $1 in
			--domain) Domain="$2"; shift ;;
			--username) Username="$2"; shift ;;
			--documentroot) DocumentRoot="$2"; shift ;;
			--fullname) FullName="$2"; shift ;;
			--mobile) Mobile="$2"; shift ;;
			--email) Email="$2"; shift ;;
			--packageid) PackageID="$2"; shift ;;
			--diskspace) DiskSpace="$2"; shift ;;
			--bandwidth) Bandwidth="$2"; shift ;;
			--inode) Inode="$2"; shift ;;
			--ftpno) FTPNo="$2"; shift ;;
			--emailno) EmailNo="$2"; shift ;;
			--databaseno) DatabaseNo="$2"; shift ;;
			--subdomainno) SubDomainNo="$2"; shift ;;
			--aliasno) AliasNo="$2"; shift ;;
			--addonno) AddonNo="$2"; shift ;;
			--shell) Shell="$2"; shift ;;
			--jailedshell) JailedShell="$2"; shift ;;
			--timezone) Timezone="$2"; shift ;;
			--permission) Permission="$2"; shift ;;
			--description) Description="$2"; shift ;;
			--phpversion) PHPVersion="$2"; shift ;;
			--smtphost) SMTPHost="$2"; shift ;;
			--smtpuser) SMTPUser="$2"; shift ;;
			--smtppass) SMTPPass="$2"; shift ;;
			--smtpport) SMTPPort="$2"; shift ;;
			--sslcertificate) SSLCertificate="$2"; shift ;;
			--sslredirect) SSLRedirect="$2"; shift ;;
			--bot) Bot="$2"; shift ;;
			--proxy) Proxy="$2"; shift ;;
			--ftpstatus) FTPStatus="$2"; shift ;;
			--ftpupload) FTPUpload="$2"; shift ;;
			--ftpdownload) FTPDownload="$2"; shift ;;
			--ftpdelete) FTPDelete="$2"; shift ;;
			--backup) Backup="$2"; shift ;;
			--backupstamp) BackupStamp="$2"; shift ;;
			--expireson) ExpiresOn="$2"; shift ;;
			--domainexpireson) DomainExpiresOn="$2"; shift ;;
			--mailttl) MailTTL="$2"; shift ;;
			--browsercachettl) BrowserCacheTTL="$2"; shift ;;
			--apiignore) APIIgnore="$2"; shift ;;
			--userid) UserID="$2"; shift ;;
			--owner) Owner="$2"; shift ;;
			--timestamp) TimeStamp="$2"; shift ;;
			--password) Password="$2"; shift ;;
			--skeleton) Skeleton="$2"; shift ;;
			*) echo "CREATE: Unknown parameter: $1"; exit 1 ;;
		esac
		shift
	done
	
else

	Arguments=0
	
fi

if [ "$Domain" = "" ]; then
	echo "USAGE: $0 --domain <domain> --username <username> --password <password> --documentroot <path> --fullname <customer full name> --mobile <customer mobile number> --email <email> --packageid <id> --diskspace <b> --bandwidth <b> --inode <number> --ftpno <number> --emailno <number> --databaseno <number> --subdomainno <number> --aliasno <number> --addonno <number> --shell <0|1> --jailedshell <0|1> --timezone <zone> --permission <755|777|555> --description <text> --phpversion <version> --smtphost <host> --smtpuser <user> --smtppass <pass> --smtpport <port> --sslcertificate <0|1> --sslredirect <0|1> --bot <0|1> --proxy <0|1> --ftpstatus <0|1> --ftpupload <0|1> --ftpdownload <0|1> --ftpdelete <0|1> --backup <0|1> --backupstamp <timestamp> --expireson <date> --domainexpireson <date> --mailttl <days> --browsercachettl <seconds> --apiignore <0|1> --userid <id> --owner <domain> --timestamp <unix> --skeleton <0|1>"
	exit 1
fi

if [ "$Username" = "" ]; then
	Username="$Domain"
fi

if [ "$Password" = "" ]; then
	Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
	GoAdmioPassword="$Password"
else
	GoAdmioPassword="$Password"
fi

if [ "$Email" = "" ]; then
	Email="info@$Domain"
fi

if [ "$PHPVersion" = "" ]; then
	PHPVersion="8.3"
fi
	
if [ "$PackageID" = "" ]; then
	PackageID="0"
fi
	
if [ "$DiskSpace" = "" ]; then
	DiskSpace="0"
fi
	
if [ "$Bandwidth" = "" ]; then
	Bandwidth="0"
fi

if [ "$Inode" = "" ]; then
	Inode="0"
fi
	
if [ "$FTPNo" = "" ]; then
	FTPNo="100"
fi
	
if [ "$EmailNo" = "" ]; then
	EmailNo="100"
fi
	
if [ "$DatabaseNo" = "" ]; then
	DatabaseNo="100"
fi
		
if [ "$SubDomainNo" = "" ]; then
	SubDomainNo="100"
fi

if [ "$AliasNo" = "" ]; then
	AliasNo="-1"
fi
	
if [ "$AddonNo" = "" ]; then
	AddonNo="-1"
fi
	
if [ "$Skeleton" = "" ]; then
	Skeleton="0"
fi
	
if [ "$SSLCertificate" = "" ]; then
	SSLCertificate="1"
fi

if [ "$Permission" = "" ]; then
	Permission="755"
fi
	
if [ "$ExpiresOn" = "" ]; then
	ExpiresOn=$(date +%Y-%m-%d -d '1 year')
fi

if [ "$MailTTL" = "" ]; then
	MailTTL="180"
fi
	
if [ "$UserID" = "" ]; then
	UserID="1"
fi

if [[ "$Owner" = *"."* ]]; then

	if sudo test ! -d /home/$Owner ; then
		echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"Primary Domain $Owner not exists.\"}"
		exit 1
	fi

else
	Owner=""
fi

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

if [ "$WS" = "NGINX" ]; then
	Plugin="--nginx"
else
	Plugin="--apache"
fi

TimeStamp=$(date +'%s')

Domain=$(echo $Domain | sed "s/[^a-zA-Z0-9\.\-]//g")
Domain=$(echo "$Domain" | tr '[:upper:]' '[:lower:]')
Username=$(echo "$Username" | tr '[:upper:]' '[:lower:]')

if [[ "$Domain" = "www."* ]]; then
	# Remove first 4 chars of string
	Domain=$(echo "$Domain" | sed -r "s/^.{4}//")
fi

if [[ ! $Domain = *"."* ]]; then
	Domain="$Domain.com"
fi

if [[ "$Username" = "www."* ]]; then
	# Remove first 4 chars of string
	Username=$(echo "$Username" | sed -r "s/^.{4}//")
fi

# IF Username more than 32 chars
if [ ${#Username} -gt 32 ]; then 
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"SITE: Invalid Username $Username.\"}"
	exit 1
fi

if [[ ! "$Domain" =~ ^[a-z0-9] ]]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"SITE: Invalid Domain $Domain.\"}"
	exit 1
fi

if [[ ! "$Domain" =~ ^[a-z0-9.-]+$ ]]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"SITE: Invalid Domain $Domain.\"}"
	exit 1
fi

if [[ "$Username" = @(root|go|goadmio|admin|vmail|nobody|apache|nginx) ]]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"This username $Username not allowed.\"}"
	exit 1
fi

if [[ ! "$Username" =~ ^[a-z] ]]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"SITE: Invalid Username $Username.\"}"
	exit 1
fi

if [[ ! "$Username" =~ ^[a-z0-9.-]+$ ]]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"SITE: Invalid Username $Username.\"}"
	exit 1
fi

DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")

if [ "$DomainExists" = "$Domain" ]; then	
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"Domain $Domain already exists.\"}"
	exit 1
fi

UsernameExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Username='$Username'")

if [ "$UsernameExists" = "$Username" ]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"Username $Username already exists.\"}"
	exit 1
fi

TrashExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Trash from Site where Domain='$Domain'")

if [ "$TrashExists" = "1" ]; then
	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"Account $Domain already exists in recycle bin, To create $Domain please remove it from recycle bin.\"}"
	exit 1
fi

AliasExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where AliasDomain='$Domain'")

if [ "$AliasExists" = "$Domain" ]; then
	
	PrimaryDomain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select Domain from Alias where AliasDomain='$Domain'")

	echo "{\"success\":false,\"title\":\"creating_goadmio_account\",\"error\":\"Sorry Domain $Domain already exists as Alias Domain, Primary Domain: $PrimaryDomain.\"}"	
	exit 1
	
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

	if sudo test ! -f "/etc/opt/remi/$PHPVersion/php.ini" ; then

		# GET Latest PHP Version
		cd /etc/opt/remi
		for Version in *
		do

			if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then
			
				PHPVersion="$Version"
		
			fi
			
		done

	fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

	if sudo test ! -f "/etc/php/$PHPVersion/fpm/php.ini" ; then

		# GET Latest PHP Version
		cd /etc/php
		for Version in *
		do
	
			if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then
			
				PHPVersion="$Version"
				
			fi
			
		done
		
	fi

fi

DiskSpace=$(($DiskSpace * 1048576))
Bandwidth=$(($Bandwidth * 1048576))

if [[ ! "${#GoAdmioPassword}" -eq 32 ]]; then
	Password=$(echo -n $GoAdmioPassword | md5sum | awk '{print $1}')
fi

Salt=$(echo -n "$Domain|$Password" | md5sum | awk '{print $1}')
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "INSERT INTO Site (Domain,Username,Password,Salt,DocumentRoot,FullName,Mobile,Email,PackageID,DiskSpace,Bandwidth,Inode,FTPNo,EmailNo,DatabaseNo,SubDomainNo,AliasNo,AddonNo,Shell,JailedShell,Timezone,Permission,Description,PHPVersion,SMTPHost,SMTPUser,SMTPPass,SMTPPort,SSLCertificate,SSLRedirect,Bot,Proxy,FTPStatus,FTPUpload,FTPDownload,FTPDelete,Backup,BackupStamp,ExpiresOn,DomainExpiresOn,MailTTL,BrowserCacheTTL,APIIgnore,UserID,Owner,TimeStamp) VALUES ('$Domain','$Username','$Password','$Salt','$DocumentRoot','$FullName','$Mobile','$Email','$PackageID','$DiskSpace','$Bandwidth','$Inode','$FTPNo','$EmailNo','$DatabaseNo','$SubDomainNo','$AliasNo','$AddonNo','$Shell','$JailedShell','$Timezone','$Permission','$Description','$PHPVersion','$SMTPHost','$SMTPUser','$SMTPPass','$SMTPPort','$SSLCertificate','$SSLRedirect','$Bot','$Proxy','$FTPStatus','$FTPUpload','$FTPDownload','$FTPDelete','$Backup','$BackupStamp','$ExpiresOn','$DomainExpiresOn','$MailTTL','$BrowserCacheTTL','$APIIgnore','$UserID','$Owner','$TimeStamp')"

# Create FTP Account
sudo /go/adduser	$Username $GoAdmioPassword

# Generate CSR and private key files (Paid SSL)
sudo screen -d -m bash -c "/go/openssl $Domain"

sudo mkdir -p /home/$Domain
sudo mkdir -p /home/$Domain/etc
sudo mkdir -p /home/$Domain/log	
sudo mkdir -p /home/$Domain/www
sudo mkdir -p /home/$Domain/sqlite
sudo mkdir -p /home/$Domain/.trash
sudo mkdir -p /home/$Domain/mail
sudo screen -d -m bash -c "/go/fix $Domain"

sudo chmod 755 /home/$Domain

sudo systemctl restart vsftpd

# Create VHOST CONF
sudo /go/apache $Domain
sudo /go/nginx $Domain

DomainIP=$(ping -c 1 $Domain | gawk -F'[()]' '/PING/{print $2}')
IP=$(curl -s -4 checkip.amazonaws.com)
IP=$(echo $IP | sed -e 's/^[ \t]*//')

if [ "$IP" = "$DomainIP" ]; then
	U="$Domain"
else
	U="$IP"
fi

if [ "$IP" != "$DomainIP" ]; then

	Warning="Warning: Domain $Domain Not Resolving To $IP. Please correct DNS settings."

fi

echo "{\"success\":true,\"title\":\"creating_goadmio_account\",\"warning\":\"$Warning\",\"result\":{\"goadmio_url\":\"http://$U:2020\",\"goadmio_urls\":\"https://go.$Domain\",\"shared_ip_address\":\"$IP\",\"domain\":\"$Domain\",\"username\":\"$Username\",\"password\":\"$GoAdmioPassword\",\"ftp_hostname\":\"$U\",\"ftp_username\":\"$Username\",\"ftp_password\":\"$GoAdmioPassword\",\"webmail_url\":\"http://$U:2024\",\"webmail_urls\":\"https://webmail.$Domain\"}}"

sudo /go/sendmail "$Domain GoAdmio Account Info" "----------GoAdmio Control Panel----------\nURL: http://$U:2020\nIP: $IP\nDomain: $Domain\nUsername: $Username\nPassword: $GoAdmioPassword\n\n----------FTP Details----------\nHostname: $U\nUsername: $Username\nPassword: $GoAdmioPassword\n\n----------Webmail----------\nURL: http://$U:2022" "Account Creation" "$Email"

echo "" | sudo tee /etc/host.key

# Enable Mail Server For Domain
if ! grep -q "^$Domain #Domain" /etc/postfix/vmail_domains
then
	echo "$Domain #Domain" | sudo tee -a /etc/postfix/vmail_domains
fi

if [ "$Skeleton" = "y" ]; then
	sudo screen -d -m bash -c "rsync -azlh /skeleton/ /home/$Domain/www/"
fi

sudo chown -R $Username:$Username /home/$Domain/www

# Create php-fpm config file 
sudo screen -d -m bash -c "/go/php-fpm $Domain"

# Create Zone File
if sudo test -f "/etc/nameservers" ; then

	sudo screen -d -m bash -c "/go/zone $Domain reset"

fi

# Generate DKIM TXT Record
sudo screen -d -m bash -c "/go/installdkim $Domain"

# Create File Manager
sudo screen -d -m bash -c "/go/fm $Domain"

if sudo test -d /s3 ; then

	sudo mkdir -p /s3/$Domain

fi

At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
if [[ ! "$At" = *"fpm"* ]]; then
	echo "/go/fpm; /go/ssl $Domain" | at now + 1 minute >/dev/null 2>&1
fi
