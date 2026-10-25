#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/restore "$@"
fi

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log

OS=$(</usr/local/goadmio/linux/os.db)

LockFile="/usr/local/goadmio/lock/backup.lock"
if [[ ! "$1" = *"."* ]]; then

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

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! command -v pv &>/dev/null; then
        sudo dnf -y install pv
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if ! command -v pv &>/dev/null; then
        sudo apt -y install pv
    fi
	
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")	
if [ "$Threads" -ge 2 ]; then
	Parallel=$(($Threads / 2 ))
else
	Parallel=1
fi

OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Domain=$1

if [[ ! $2 = *"--"* ]]; then
	BackupDate=$2
fi

if [[ $3 = *"."* ]]; then
	Hostname=$3
fi

if [[ $@ = *"--storage tertiary"* ]]; then
	Storage="tertiary"
elif [[ $@ = *"--storage secondary"* ]]; then
	Storage="secondary"
else
	Storage="backup"
fi

if [ $# -eq 0 ]; then
	exit 1
fi

if [ "$Domain" = "database" ] || [ "$Domain" = "go" ]; then

	# Restore From Remote Backup Server
		
	source /var/go/etc/$Storage.conf

	echo "Restoring Go Database..."

	if [ "$RemoteDir" = "" ] || [ "$RemoteDir" = "-" ] || [ "$RemoteDir" = "/" ]; then

		sudo rclone copy backup:$Hostname/$BackupDate/var/lib/sqlite/ /var/lib/sqlite/ -P

	else
	
		sudo rclone copy backup:$RemoteDir/$Hostname/$BackupDate/var/lib/sqlite/ /var/lib/sqlite/ -P

	fi

	sudo chown -R go:go /var/lib/sqlite

	exit 1
	
fi

if [ "$Domain" = "ssl" ]; then

	if sudo test -d /var/go/ssl/archive ; then
	
		echo "Restoring Let's Encrypt Certificates..."
		rsync --ignore-existing -azlh /var/go/ssl/live/ /etc/letsencrypt/live/
		rsync --ignore-existing -azlh /var/go/ssl/archive/ /etc/letsencrypt/archive/

		sudo /go/conf --skip ssl --skip mailssl
	
	fi
		
	exit 1
	
fi

if [[ "$Domain" = *"/"* ]] && [[ "$2" = *"/"* ]] && [ "$Hostname" = "" ]; then

	# Restore Folder from Remote Backup Server
	# /go/restore /backup/home /root/home

	source /var/go/etc/$Storage.conf

	if [ "$Destination" = "LOCAL" ]; then
		
		echo "Can not retore folder $1. Please Setup Remote Server Backup."

	else
	
		sudo mkdir -p $2

		if [ "$RemoteDir" = "" ] || [ "$RemoteDir" = "-" ] || [ "$RemoteDir" = "/" ]; then
	
			sudo rclone copy backup:$1 $2 -P
	
		else
		
			sudo rclone copy backup:$RemoteDir/$1 $2 -P

		fi

	fi

	exit 1

fi

if [[ "$BackupDate" = *"-"* ]]; then
	
	echo "Restoring $Domain from a Remote Backup Server"
		
	source /var/go/etc/$Storage.conf
	
	if [ "$Domain" = "all" ]; then

		echo "Restoring All Sites ($BackupDate)..."
		sudo /go/sendmail "Restoring Backup" "Restoring All Sites ($BackupDate | $Hostname)" "Start Restore"
		sudo /go/sendwhatsapp "*Restoring Backup*\n\nRestoring All Sites ($BackupDate | $Hostname)" "Start Restore"
		
		sudo mkdir -p /backup/$Hostname/$BackupDate

		DomainNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site")

		if [ "$Destination" = "Rclone" ] || [ "$Destination" = "rclone" ]; then
						
			if ! rclone lsd backup:$Hostname/$BackupDate &>/dev/null; then
				echo "Remote backup backup:$Hostname/$BackupDate does not exist"
				
					if rclone lsd backup:$Hostname &>/dev/null; then
						echo "Available Backup Dates:"
						sudo rclone lsd backup:$Hostname | awk '{print $NF}'
					fi
				
				exit 1
			fi
								
			if [ "$RemoteDir" = "" ] || [ "$RemoteDir" = "-" ] || [ "$RemoteDir" = "/" ]; then
				sudo rclone copy backup:$Hostname/$BackupDate/ /backup/$Hostname/$BackupDate/ -P
			else
				sudo rclone copy backup:$RemoteDir/$Hostname/$BackupDate/ /backup/$Hostname/$BackupDate/ -P
			fi
		
		elif [ "$Destination" = "SCP" ] || [ "$Destination" = "scp" ]; then
			
			LYR=$(echo -n "$SHA1|$Storage" | md5sum | awk '{print $1}')
			if sudo test -f /usr/local/goadmio/db/$LYR.db ; then
			
				RemotePassword=$(sudo openssl pkeyutl -inkey /etc/$Storage.key -decrypt </usr/local/goadmio/db/$LYR.db)
				RemotePassword=$(echo "$RemotePassword" | base64 --decode)
				
			else
			
				echo "REMOTE: Invalid password"
				exit 1
				
			fi
			
			sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" $RemoteUser@$RemoteServer:$RemoteDir/$Hostname/$BackupDate/ /backup/$Hostname/$BackupDate/
			
		fi

		if [ "$DomainNo" -eq "0" ]; then

			if sudo test -f /backup/$Hostname/$BackupDate/mysql/mariadb.pwd ; then

				ResetPass=$(</backup/$Hostname/$BackupDate/mysql/mariadb.pwd)
				sudo /go/mysqlreset $ResetPass

				Parameter="--skip mysql"

				ulimit -n 65535
				
				sudo /go/cron stop 
				sudo systemctl stop mariadb
				sudo rm -rf /var/lib/mysql/*
				sudo /usr/bin/mariadb-backup --decompress --parallel=$Parallel --target-dir=/backup/$Hostname/$BackupDate/mysql
				sudo /usr/bin/mariadb-backup --prepare --target-dir=/backup/$Hostname/$BackupDate/mysql
				sudo /usr/bin/mariadb-backup --copy-back --parallel=$Parallel --target-dir=/backup/$Hostname/$BackupDate/mysql
				sudo chown -R mysql:mysql /var/lib/mysql
				sudo systemctl restart mariadb
				sudo /go/cron restart
				sudo rm -rf /backup/$Hostname/$BackupDate/mysql
			
			fi
		
		fi
	
		if sudo test -d /backup/$Hostname/$BackupDate/go ; then
			sudo /go/cf /backup/$Hostname/$BackupDate/var/go/ /var/go/
		fi

		# Count Backup Files
		C=$(sudo find /backup/$Hostname/$BackupDate -maxdepth 1 -type f -name "*.tar.gz" -print| wc -l)
		
		# For loop by date DESC
		for File in `ls -t /backup/$Hostname/$BackupDate`
		do
		
			if [[ "$File" = *".tar.gz" ]]; then

				clear

				N=$(($N + 1))
				
				Website=$(echo "$File" | cut -d '-' -f6- | sed -e 's/.tar.gz//g')

				sudo /go/log "[$N/$C] Restoring $Website" $(basename "$0")
				echo "[$N/$C] Restoring $Website..."
				sudo /go/sendmail "Restoring Backup" "[$N/$C] Restoring $Website" "Start Restore"
				sudo /go/sendwhatsapp "*Restoring Backup*\n\n[$N/$C] Restoring $Website" "Start Restore"

				if [[ "$Hostname" = *"."* ]]; then
					# Restore from Another Hostname
					sudo mv /backup/$Hostname/$BackupDate/$File /backup/
				fi
					
				sudo /go/restore $File $Parameter

			fi
		
		done
		
		sudo /go/ssl all
	
	else

		echo "Restoring $Domain..."
		sudo mkdir -p /backup
		
		if [[ "$Domain" = *".tar.gz" ]]; then

			IFS='-' read -r -a Array <<< "$Domain"
			Type="${Array[0]}"
			Domain=$(echo "${Array[5]}" | sed 's/.tar.gz//')

		fi

		if [ "$RemoteDir" = "" ] || [ "$RemoteDir" = "-" ] || [ "$RemoteDir" = "/" ]; then
	
			sudo rclone copy backup:$Hostname/$BackupDate/$Type-backup-$BackupDate-$Domain.tar.gz /backup/ -P
	
		else
		
			sudo rclone copy backup:$RemoteDir/$Hostname/$BackupDate/$Type-backup-$BackupDate-$Domain.tar.gz /backup/ -P

		fi
		
		if sudo test -f "/backup/$Type-backup-$BackupDate-$Domain.tar.gz" ; then
		
			sudo /go/delete $Domain --force
			sudo /go/restore $Type-backup-$BackupDate-$Domain.tar.gz

		else

			echo "Backup not Exists, Try another backup date."

		fi
		
	fi
	
	sudo /go/sendmail "Restoring Backup Finished" "Restoring All Sites ($BackupDate | $Hostname)" "Restore Success"
	sudo /go/sendwhatsapp "*Restoring Backup Finished*\n\nRestoring All Sites ($BackupDate | $Hostname)" "Restore Success"
	
	exit 1
	
fi


if [ "$Domain" = "all" ]; then
		
	# Count Backup Files
	C=$(sudo find /backup -maxdepth 1 -type f -name "*.tar.gz" -print| wc -l)
	
	N=0
	
	# For loop by date DESC
	for File in `ls -t /backup`
	do
	
		if [[ "$File" = *".tar.gz" ]]; then

			clear

			N=$(($N + 1))
			
			Website=$(echo "$File" | cut -d '-' -f6- | sed -e 's/.tar.gz//g')

			sudo /go/log "[$N/$C] Restoring $Website" $(basename "$0")
			echo "[$N/$C] Restoring $Website..."

			sudo /go/restore $File

		fi

	
	done
	
	exit 1
	
fi

cd /backup

if [[ "$Domain" = *".tar.gz" ]]; then

	if sudo test -f "/backup/$1" ; then
	
		echo "Extracting $1..."
		sudo tar -xzf $1

	else
	
		IFS='-' read -r -a Array <<< "$1"
		FolderDate="${Array[2]}-${Array[3]}-${Array[4]}"
	
		if sudo test -f "/backup/$Hostname/$FolderDate/$1" ; then	

			sudo mv /backup/$Hostname/$FolderDate/$1 /backup/$1
			echo "Extracting $1..."
			sudo tar -xzf $1
	
		else

			# If file not in Local Server Try to find it on Remote Server
			sudo /go/restore $1 $FolderDate
			
			exit 1

		fi
	fi

	Dir=${1/.tar.gz} 

else

	# Find Filename by username 
	Find="0"
	cd /backup
	
	# For loop by date DESC
	for File in `ls -t /backup`
	do

		if [[ "$File" = *"_$1.tar.gz" ]]; then
			
			Find="1"
			echo "Extracting $File..."
			sudo tar -xzf $File
			Dir=${File/.tar.gz} 
			break
		fi
		
		if [[ "$File" = *"-$1.tar.gz" ]]; then
			Find="1"
			sudo tar -xzf $File
			Dir=${File/.tar.gz} 
			break
		fi
		
	done

	if [ "$File" = "0" ]; then
		echo "File extension is not allowed. Only 'tar.gz' is allowed."
		exit 1
	fi
fi

if sudo test ! -d "/backup/$Dir" ; then
	echo "Directory /backup/$Dir not exists."
	exit 1
fi

if sudo test -d "/backup/$Dir/homedir" ; then

	# cPanel
	cd /backup/$Dir/homedir/etc
	for File in *
	do
		if sudo test -d "/backup/$Dir/homedir/etc/$File" ; then
		
			if [[ "$File" = *"."* ]]; then
				Domain="$File"
			fi

		fi
	done
	
	if [[ ! $Domain = *"."* ]]; then
		echo "Invalid domain name $Domain"
		exit 1
	fi
	
	# Get Username
	if sudo test -f /backup/$Dir/meta/homedir_paths ; then
		HomePath=$(</backup/$Dir/meta/homedir_paths)
		IFS='/' read -r -a Array <<< "$HomePath"
		Username="${Array[2]}"
	fi

	if [ "$Username" = "" ]; then
		
		Username="$Domain"
		
	fi

	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
	
	echo "Restoring $Domain Files..."

	Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
	Email="info@$Domain"

	cd /etc/opt/remi
	for Version in *
	do
		PHPVersion="$Version"
	done

	DiskSpace="0"
	PackageID="0"
	Bandwidth="0"
	FTPNo="100"
	EmailNo="1000"
	DatabaseNo="100"
	SubDomainNo="100"
	AliasNo="1"
	AddonNo="0"
	Skeleton="n"
	SSLCertificate="1"
	SSLRedirect="1"
	FPM="1"
	Permission="secure"
	ExpiresOn=$(date +%Y-%m-%d -d '1 year')
	MailTTL=180
	UserID="1"

	sudo /go/create --domain "$Domain" --username "$Username" --password "$Password" --documentroot "$DocumentRoot" --fullname "$FullName" --mobile "$Mobile" --email "$Email" --packageid "$PackageID" --diskspace "$DiskSpace" --bandwidth "$Bandwidth" --inode "$Inode" --ftpno "$FTPNo" --emailno "$EmailNo" --databaseno "$DatabaseNo" --subdomainno "$SubDomainNo" --aliasno "$AliasNo" --addonno "$AddonNo" --shell "$Shell" --jailedshell "$JailedShell" --timezone "$Timezone" --permission "$Permission" --description "$Description" --phpversion "$PHPVersion" --smtphost "$SMTPHost" --smtpuser "$SMTPUser" --smtppass "$SMTPPass" --smtpport "$SMTPPort" --sslcertificate "$SSLCertificate" --sslredirect "$SSLRedirect" --bot "$Bot" --proxy "$Proxy" --ftpstatus "$FTPStatus" --ftpupload "$FTPUpload" --ftpdownload "$FTPDownload" --ftpdelete "$FTPDelete" --backup "$Backup" --backupstamp "$BackupStamp" --expireson "$ExpiresOn" --domainexpireson "$DomainExpiresOn" --mailttl "$MailTTL" --browsercachettl "$BrowserCacheTTL" --apiignore "$APIIgnore" --userid "$UserID" --owner "$Owner" --timestamp "$TimeStamp" --skeleton "$Skeleton"

	if sudo test -f "/backup/$Dir/shadow" ; then
		# Restore Linux Password (cPanel)
		sudo sed -i "/^$Username:/d" /etc/shadow
		LinuxPassword=$(</backup/$Dir/shadow)
		echo "$Username:$LinuxPassword" | sudo tee -a /etc/shadow
	fi

	sudo rm -rf /home/$Domain/www
	sudo rm -rf /home/$Domain/mail

	sudo mv /backup/$Dir/homedir/public_html /home/$Domain/www
	sudo mv /backup/$Dir/homedir/mail/$Domain /home/$Domain/mail

	sudo chmod 775 /home/$Domain
	sudo chmod 775 /home/$Domain/www
	sudo chown -R $Username:$Username /home/$Domain/www

	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
	
	echo "Restoring $Domain Email Accounts..."
	sudo chown vmail:vmail -R /home/$Domain/mail
	cd /home/$Domain/mail
	for User in *
	do
		Email="$User@$Domain"
		sudo /go/mail --email "$Email" --pass "$Pass" --forwardto "$ForwardTo" --reject "$Reject" --rejectmessage "$RejectMessage" --keepcopy "$KeepCopy" --domain "$Domain" --defaultaddress "$DefaultAddress" --suspend "$Suspend" --admin "$Admin" --description "$Description" --timestamp "$TimeStamp" --action add --norestart 1
	done
	
	# cPanel
	
	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

	echo "Restoring $Domain Databases..."
	sudo rm -rf /backup/$Dir/log/mysql/roundcube.sql
	cd /backup/$Dir/mysql
	for File in *
	do

		if [[ "$File" = *".sql" ]]; then
			
			Name=${File/.sql}

			# Remove DASH IF Exists
			Name=${Name//\-}

			User="$Name"
			
			DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
			if [ "$Name" = "$DatabaseExists" ]; then
				echo "Database '$Name' already exists."
			else
				sudo /go/mysql $Domain $Name $User "$Password"

				echo "Restoring Database $Name..."
				
				if [[ ! $@ = *"--skip mysql"* ]]; then
					pv $File | mariadb -uroot -p$MySQLRootPassword $Name
				fi
				
			fi
			
		fi

	done

	sudo mariadb -uroot -p$MySQLRootPassword $Name < /backup/$Dir/mysql.sql



	if [ "$Dir" != "" ] && [ "$Dir" != "/" ]; then	

		if sudo test -d /backup/$Dir ; then	
		
			sudo rm -rf /backup/$Dir
				
			if [[ "$2" = *"-"* ]]; then
				# Delete original backup if I restore external backup
				sudo rm -rf /backup/$Dir.tar.gz
			fi
			
		fi

	fi
	
	exit 1

fi

if sudo test -f "/backup/$Dir/log/include/site.conf" ; then

	# GoAdmio
	source /backup/$Dir/log/include/site.conf

	if [[ ! $Domain = *"."* ]]; then
		echo "Invalid domain name $Domain"
		exit 1
	fi
	
	UsernameExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

	if [ "$UsernameExists" = "$Username" ]; then
		echo "Username $Username already exists"
		exit 1
	fi

	if [ "$Password" = "" ]; then
		Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
	fi

	if sudo test -d "/home/$Domain" ; then
		echo "Directory /home/$Domain already exists."
	else
	
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
		
	fi

		sudo /go/create --domain "$Domain" --username "$Username" --password "$Password" --documentroot "$DocumentRoot" --fullname "$FullName" --mobile "$Mobile" --email "$Email" --packageid "$PackageID" --diskspace "$DiskSpace" --bandwidth "$Bandwidth" --inode "$Inode" --ftpno "$FTPNo" --emailno "$EmailNo" --databaseno "$DatabaseNo" --subdomainno "$SubDomainNo" --aliasno "$AliasNo" --addonno "$AddonNo" --shell "$Shell" --jailedshell "$JailedShell" --timezone "$Timezone" --permission "$Permission" --description "$Description" --phpversion "$PHPVersion" --smtphost "$SMTPHost" --smtpuser "$SMTPUser" --smtppass "$SMTPPass" --smtpport "$SMTPPort" --sslcertificate "$SSLCertificate" --sslredirect "$SSLRedirect" --bot "$Bot" --proxy "$Proxy" --ftpstatus "$FTPStatus" --ftpupload "$FTPUpload" --ftpdownload "$FTPDownload" --ftpdelete "$FTPDelete" --backup "$Backup" --backupstamp "$BackupStamp" --expireson "$ExpiresOn" --domainexpireson "$DomainExpiresOn" --mailttl "$MailTTL" --browsercachettl "$BrowserCacheTTL" --apiignore "$APIIgnore" --userid "$UserID" --owner "$Owner" --timestamp "$TimeStamp" --skeleton "$Skeleton"

		printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
		
		echo "Restoring $Domain Files..."

		if sudo test -d /backup/$Dir/www ; then
		
			sudo rm -rf /home/$Domain/www
			sudo mv /backup/$Dir/www /home/$Domain/www

		fi

		printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

		echo "Restoring $Domain SQLite Databases..."

		if sudo test -d /backup/$Dir/sqlite ; then
		
			sudo rm -rf /home/$Domain/sqlite
			sudo mv /backup/$Dir/sqlite /home/$Domain/sqlite

		fi

		if sudo test -d /backup/$Dir/log/subdomain ; then

			cd /backup/$Dir/log/subdomain
			for File in *
			do

				if [[ "$File" = *".conf" ]]; then
				
					source /backup/$Dir/log/subdomain/$File
					sudo /go/subdomain --subdomain $Subdomain --documentroot $DocumentRoot --redirecturl $RedirectUrl
				
				fi
				
			done
			
		fi
		
		if sudo test -d /backup/$Dir/mail ; then

			sudo rm -rf /home/$Domain/mail
			sudo mv /backup/$Dir/mail /home/$Domain/mail

		fi
		
		printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
		
		echo "Restoring $Domain Email Accounts..."
		sudo chown vmail:vmail -R /home/$Domain/mail
		cd /home/$Domain/mail
		for User in *
		do

			if sudo test -f "/backup/$Dir/mail/$User.conf" ; then
			
				source /backup/$Dir/mail/$User.conf
				Email="$User@$Domain"
				sudo /go/mail --email "$Email" --pass "$Pass" --forwardto "$ForwardTo" --reject "$Reject" --rejectmessage "$RejectMessage" --keepcopy "$KeepCopy" --domain "$Domain" --defaultaddress "$DefaultAddress" --suspend "$Suspend" --admin "$Admin" --description "$Description" --timestamp "$TimeStamp" --action add --norestart 1
			
			fi

		done

		if sudo test -f "/backup/$Dir/log/include/shadow" ; then
			# Restore Linux Password
			sudo sed -i "/^$Username:/d" /etc/shadow
			LinuxPassword=$(</backup/$Dir/log/include/shadow)
			echo "$LinuxPassword" | sudo tee -a /etc/shadow
		fi
		
       sudo /go/fix $Domain
		
	fi
	
	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
	
	echo "Restoring $Domain MySQL/MariaDB Databases.."
	cd /backup/$Dir/log/mysql
	for File in *
	do

		if [[ "$File" = *".sql" ]]; then
			
			Name=${File/.sql}
			
			DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
			if [ "$Name" = "$DatabaseExists" ]; then
				echo "Database '$Name' already exists."
			else
			
				DBInfo=$(</backup/$Dir/log/mysql/$Name.pwd)

				IFS='|' read -r -a Array <<< "$DBInfo"
				User="${Array[0]}";
				Pass="${Array[1]}";

				sudo /go/mysql $Domain $Name $User "$Pass"

				echo "Restoring MySQL/MariaDB Database $Name..."
				
				if [[ ! $@ = *"--skip mysql"* ]]; then
					pv $File | mariadb -uroot -p$MySQLRootPassword $Name
					sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT USAGE ON $Name.* TO '$User'@'localhost' IDENTIFIED BY PASSWORD '$Pass';"
				fi

			fi
			
		fi

	done
	
	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

	echo "Restoring $Domain PostgreSQL Databases.."
	cd /backup/$Dir/log/postgre
	for File in *
	do

		if [[ "$File" = *".sql" ]]; then
			
			Name=${File/.sql}
			
			DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Name='$Name'")
			if [ "$Name" = "$DatabaseExists" ]; then
				echo "Database '$Name' already exists."
			else
			
				DBInfo=$(</backup/$Dir/log/postgre/$Name.pwd)

				IFS='|' read -r -a Array <<< "$DBInfo"
				User="${Array[0]}";
				Pass="${Array[1]}";

				sudo /go/postgre $Domain $Name $User $Pass

				echo "Restoring PostgreSQL Database $Name..."
				sudo su - postgres -c "psql -d $Name -f /backup/$Dir/log/postgre/$File"

			fi
			
		fi

	done



	if [ "$Dir" != "" ] && [ "$Dir" != "/" ]; then	

		if sudo test -d /backup/$Dir ; then	
		
			sudo rm -rf /backup/$Dir

			if [[ "$2" = *"-"* ]]; then
				# Delete original backup if I restore external backup
				sudo rm -rf /backup/$Dir.tar.gz
			fi

		fi

	fi
	
	exit 1

fi

sudo rm -f $LockFile
