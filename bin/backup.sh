#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/backup "$@"
fi

shopt -s extglob

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

LockFile="/usr/local/goadmio/lock/backup.lock"
if [[ $# -eq 0 ]] || [ "$1" = "secondary" ] || [ "$1" = "tertiary" ]; then

	if sudo test -f $LockFile ; then
		if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "1800" ]]; then
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

if [[ $@ = *"--help"* ]]; then

	printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
	echo "Transfer all accounts from one server to another:"
	
	echo "/go/backup all full sftp <RemoteIP> root <RemotePass> <Port> /backup"
	echo "Or"
	echo "/go/backup all <RemoteIP> <RemotePass>"
	exit 1

fi

if [[ "$@" = *"--"* ]]; then

	Arguments=1

	while [[ "$#" -gt 0 ]]; do
		case $1 in
			--domain) Domain="$2"; shift ;;
			--cron) Cron="$2"; shift ;;
			--type) Type="$2"; shift ;;
			--destination) Destination="$2"; shift ;;
			--remoteserver) RemoteServer="$2"; shift ;;
			--key) Key="$2"; shift ;;
			--apikey) ApiKey="$2"; shift ;;
			--token) Token="$2"; shift ;;
			--apptoken) AppToken="$2"; shift ;;
			--accesstoken) AccessToken="$2"; shift ;;
			--accesskeyid) AccessKeyID="$2"; shift ;;
			--secretaccesskey) SecretAccessKey="$2"; shift ;;
			--endpoint) Endpoint="$2"; shift ;;
			--provider) Provider="$2"; shift ;;
			--region) Region="$2"; shift ;;
			--url) Url="$2"; shift ;;
			--vendor) Vendor="$2"; shift ;;
			--email) Email="$2"; shift ;;
			--account) Account="$2"; shift ;;
			--sharename) ShareName="$2"; shift ;;
			--remoteuser) RemoteUser="$2"; shift ;;
			--remotepass) RemotePass="$2"; shift ;;
			--megauser) MegaUser="$2"; shift ;;
			--megapass) MegaPass="$2"; shift ;;
			--opendriveuser) OpenDriveUser="$2"; shift ;;
			--opendrivepass) OpenDrivePass="$2"; shift ;;
			--pikpakuser) PikPakUser="$2"; shift ;;
			--pikpakpass) PikPakPass="$2"; shift ;;
			--protondriveuser) ProtonDriveUser="$2"; shift ;;
			--protondrivepass) ProtonDrivePass="$2"; shift ;;
			--mailruuser) MailruUser="$2"; shift ;;
			--mailrupass) MailruPass="$2"; shift ;;
			--uloztouser) UloztoUser="$2"; shift ;;
			--uloztopass) UloztoPass="$2"; shift ;;
			--webdavuser) WebDAVUser="$2"; shift ;;
			--webdavpass) WebDAVPass="$2"; shift ;;
			--idriveuser) IDriveUser="$2"; shift ;;
			--idrivepass) IDrivePass="$2"; shift ;;
			--port) Port="$2"; shift ;;
			--remotedir) RemoteDir="$2"; shift ;;
			--retention) Retention="$2"; shift ;;
			--sync) Sync="$2"; shift ;;
			--date) Date="$2"; shift ;;
			--setup) Setup="$2"; shift ;;
			--quiet) Quiet="$2"; shift ;;
			--storage) Storage="$2"; shift ;;
			*) echo "BACKUP: Unknown parameter: $1"; exit 1 ;;
		esac
		shift
	done
	
else

	Arguments=0
	
fi

if [ "$1" = "go" ] && [ $# -eq 1 ]; then

	sudo mkdir -p /GoAdmio
	sudo rm -rf /GoAdmio/*
	sudo cp -p /root/*.sh /GoAdmio/
	/opt/IDriveForLinux/bin/idrive --backup
	exit 1
	
fi

if [ "$1" = "all" ] && [ $# -eq 1 ]; then

	C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

	cd /home
	for Domain in *
	do

		if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain/www ; then
		
			N=$(($N + 1))

			echo "[$N/$C] Backup $Domain to /backup"
			sudo /go/backup $Domain
			
		fi
		
	done
	
	exit 1
				
fi

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")	
if [ "$Threads" -ge 2 ]; then
	Parallel=$(($Threads / 2 ))
else
	Parallel=1
fi

TimeStamp=$(date +'%s')
Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")

if [ "$RemoteUser" = "" ]; then
	RemoteUser="root"
fi

if [ "$RemoteDir" = "" ]; then
	RemoteDir="/"
fi

if [ "$1" = "secondary" ]; then
	Storage="secondary"
fi

if [ "$1" = "tertiary" ]; then
	Storage="tertiary"
fi

if [ "$Storage" = "" ]; then
	Storage="backup"
fi

if [ "$Date" = "" ]; then 
	Date=$(date +'%Y-%m-%d')
fi

# Clear Command Line history
history -c

if [ "$Arguments" = "0" ]; then

	if [ "$1" = "default" ]; then

		if [ "$2" = "30" ]; then
			sudo /go/backup --cron "" --type full --destination sftp --remoteserver - --remoteuser root --remotepass - --port 22 --remotedir / --retention 33 --sync 1 --setup 1 --quiet 1
			sudo /go/backup --cron "" --type database --destination sftp --remoteserver - --remoteuser root --remotepass - --port 22 --remotedir / --retention 33 --sync 0 --setup 1 --quiet 1 --storage secondary
		else
			DayName=$(echo -e "Sat-Tue\nSun-Wed\nMon-Thu" | shuf -n 1)		
			sudo /go/backup --cron "" --type full --destination rclone --remoteserver - --remoteuser root --remotepass - --port 22 --remotedir / --retention 8 --sync 1 --setup 1 --quiet 1
			sudo /go/backup --Cron "" --type database --destination rclone --remoteserver - --remoteuser root --remotepass - --port 22 --remotedir / --retention 8 --sync 0 --setup 1 --quiet 1 --storage secondary
		fi
		
		exit 1

	fi

	if [ "$1" = "ssl" ]; then

		if sudo test -d /etc/letsencrypt/live ; then

			sudo mkdir -p /var/go/ssl/live
			sudo mkdir -p /var/go/ssl/archive

			rsync -azlh /etc/letsencrypt/live/ /var/go/ssl/live/
			rsync -azlh /etc/letsencrypt/archive/ /var/go/ssl/archive/

		fi
		
		LockFile="/usr/local/goadmio/lock/backup-ssl.lock"
		echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

		exit 1

	fi

	if [[ $# -eq 1 ]] && sudo test -d "/home/$1/www" ; then

		# Local Backup one Domain
		# backup <Domain>

		Domain=$1
		Type="full"
		Destination="local"
		RemoteDir="/backup"

		Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

	fi

	if [ $# -eq 3 ]; then

		# backup all <RemoteIP> <RemotePass>"

		Domain="all"
		Type="full"
		Destination="sftp"
		RemoteServer=$2
		RemoteUser="root"
		RemotePass=$3
		Port="22222"
		RemoteDir="/backup"

		Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

	fi

	if [[ "$1" = *"/"* ]] && [[ "$2" = *"/"* ]] && [ "$3" = "" ]; then

		# Backup Folder to Remore Folder (For Backup Server)
		# /backkup /root/home /backup/home

		source /var/go/etc/$Storage.conf

		if [ "$Destination" = "local" ]; then
			
			echo "Can not copy folder $1. Please Setup Remote Server Backup."

		else

			echo "Copying $1 to remote:$2..."		
			sudo rclone copy $1 $Storage:$2 -P

		fi

		exit 1

	fi

	if [[ $# -eq 0 ]] || [ "$1" = "secondary" ] || [ "$1" = "tertiary" ]; then

		# Run Schedule Backup
		
		if sudo test -f /var/go/etc/$Storage.conf ; then
			source /var/go/etc/$Storage.conf
		else
			echo "File /var/go/etc/$Storage.conf not exists."
			exit 1
		fi
		
		sudo mkdir -p /var/lib/sqlite/backup/$Date
		sudo cp /var/lib/sqlite/*.db /var/lib/sqlite/backup/$Date
	
		echo "Backup Destination: $Destination"
									
		sudo /go/sendmail "Schedule Backup Running Now" "Schedule Backup Running Now" "Backup"
		sudo /go/sendwhatsapp "*Schedule Backup Running Now*" "Backup"

		if [ "$Sync" -eq "1" ]; then
		
			echo "Generating MySQL/MariaDB Hot Backup..."
			sudo rm -rf /mysql
			sudo mkdir -p /mysql
			
			ulimit -n 65535
			sudo mariadb-backup --backup --compress --parallel=$Parallel --user=root --password=$MySQLRootPassword --target-dir=/mysql
			echo "$MySQLRootPassword" | sudo tee /mysql/mariadb.pwd >/dev/null
			
		fi

		if [ "$Destination" = "local" ]; then
		
			DiskSpacePercent=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g')
			if [ "$DiskSpacePercent" -ge "90" ]; then

				echo "Your disk space is running low."
				sudo /go/sendmail "Your disk space is running low" "Dear customer,\nWe would like to inform that your server $Hostname ($ServerIP) is about to reach the limit:\nDisk Usage - $DiskSpacePercent %.\n\nBest regards,\nGoAdmio Team" "Backup"
				sudo /go/sendwhatsapp "*Your disk space is running low*\n\nWe would like to inform that your server $Hostname ($ServerIP) is about to reach the limit:\nDisk Usage - $DiskSpacePercent %.\n\nBest regards,\nGoAdmio Team" "Backup"
				
				exit 1

			fi

			sudo mkdir -p $RemoteDir/$Hostname/$Date >/dev/null 2>&1

			sudo /go/backup --domain all --type "$Type" --destination "$Destination" --remoteserver "$RemoteServer" --remoteuser "$RemoteUser" --remotepass "$RemotePass" --megauser "$MegaUser" --megapass "$MegaPass" --opendriveuser "$OpenDriveUser" --opendrivepass "$OpenDrivePass" --pikpakuser "$PikPakUser" --pikpakpass "$PikPakPass" --protondriveuser "$ProtonDriveUser" --protondrivepass "$ProtonDrivePass" --mailruuser "$MailruUser" --mailrupass "$MailruPass" --uloztouser "$UloztoUser" --uloztopass "$UloztoPass" --webdavuser "$WebDAVUser" --webdavpass "$WebDAVPass" --idriveuser "$IDriveUser" --idrivepass "$IDrivePass" --port "$Port" --remotedir "$RemoteDir/$Hostname/$Date" --retention "$Retention" --sync "$Sync" --date "$Date" --storage "$Storage"
			
		elif [ "$Destination" = "idrive" ]; then

			echo "Backup All Domains | IDrive ..."
			sudo /go/backup --domain all --type "$Type" --destination "$Destination" --remoteserver "$RemoteServer" --remoteuser "$RemoteUser" --remotepass "$RemotePass" --megauser "$MegaUser" --megapass "$MegaPass" --opendriveuser "$OpenDriveUser" --opendrivepass "$OpenDrivePass" --pikpakuser "$PikPakUser" --pikpakpass "$PikPakPass" --protondriveuser "$ProtonDriveUser" --protondrivepass "$ProtonDrivePass" --mailruuser "$MailruUser" --mailrupass "$MailruPass" --uloztouser "$UloztoUser" --uloztopass "$UloztoPass" --webdavuser "$WebDAVUser" --webdavpass "$WebDAVPass" --idriveuser "$IDriveUser" --idrivepass "$IDrivePass" --port "$Port" --remotedir "$RemoteDir/$Hostname/$Date" --retention "$Retention" --sync "$Sync" --date "$Date" --storage "$Storage"

		else

			if [ "$Type" = "full" ] || [[ "$Type" = *"database"* ]] || [[ "$Sync" -eq "1" ]]; then

				if grep -q "\["$Storage"\]" /root/.config/rclone/rclone.conf; then
					
					echo "[$Storage]"
					
					for i in {1..2}; do

						BackupNo=$(rclone lsf --dirs-only $Storage:${RemoteDir##+(/)}/$Hostname 2>/dev/null | wc -l)
						BackupFolder=$(rclone lsf --dirs-only --format "tp" "$Storage:${RemoteDir##+(/)}/$Hostname" 2>/dev/null | sort | head -n 1 | cut -d' ' -f1)

						if [ "$BackupNo" -ge "$Retention" ]; then
							echo "Deleting $Storage:${RemoteDir##+(/)}/$Hostname/$BackupFolder..."
							sudo rclone purge $Storage:${RemoteDir##+(/)}/$Hostname/$BackupFolder
						fi
						
					done

					if [ "$Storage" = "backup" ]; then
					
						echo "Copying GoAdmio Database..."
						sudo rclone copy /var/lib/sqlite/backup/$Date/ $Storage:${RemoteDir##+(/)}/$Hostname/$Date/var/lib/sqlite/
						echo "."
					
						echo "Copying GoAdmio Variable..."
						sudo rclone copy -L /var/go/ $Storage:${RemoteDir##+(/)}/$Hostname/$Date/var/go/
						echo "."
						
					fi

					if [ "$Sync" -eq "1" ]; then
						echo "Copying MySQL/MariaDB..."
						sudo rclone copy /mysql/ $Storage:${RemoteDir##+(/)}/$Hostname/$Date/mysql/
						echo "."
					fi

				else
					echo "[$Storage] Mot Exists."
				fi

			fi
			
			sudo rm -rf /mysql

			echo "Backup All Domains..."
			sudo /go/backup --domain all --type "$Type" --destination "$Destination" --remoteserver "$RemoteServer" --remoteuser "$RemoteUser" --remotepass "$RemotePass" --megauser "$MegaUser" --megapass "$MegaPass" --opendriveuser "$OpenDriveUser" --opendrivepass "$OpenDrivePass" --pikpakuser "$PikPakUser" --pikpakpass "$PikPakPass" --protondriveuser "$ProtonDriveUser" --protondrivepass "$ProtonDrivePass" --mailruuser "$MailruUser" --mailrupass "$MailruPass" --uloztouser "$UloztoUser" --uloztopass "$UloztoPass" --webdavuser "$WebDAVUser" --webdavpass "$WebDAVPass" --idriveuser "$IDriveUser" --idrivepass "$IDrivePass" --port "$Port" --remotedir "$RemoteDir/$Hostname/$Date" --retention "$Retention" --sync "$Sync" --date "$Date" --storage "$Storage"
		
		fi

		exit 1

	fi
	
fi

if [ "$Setup" = "1" ]; then

	echo "Cron=\"$Cron\"" | sudo tee /var/go/etc/$Storage.conf >/dev/null
	echo "Type=\"$Type\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Destination=\"$Destination\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "RemoteServer=\"$RemoteServer\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Key=\"$Key\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "ApiKey=\"$ApiKey\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Token=\"$Token\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "AppToken=\"$AppToken\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "AccessToken=\"$AccessToken\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "AccessKeyID=\"$AccessKeyID\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "SecretAccessKey=\"$SecretAccessKey\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Endpoint=\"$Endpoint\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Provider=\"$Provider\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Region=\"$Region\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Url=\"$Url\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Vendor=\"$Vendor\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Email=\"$Email\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Account=\"$Account\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "ShareName=\"$ShareName\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	
	echo "RemoteUser=\"$RemoteUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "RemotePass=\"$RemotePass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "MegaUser=\"$MegaUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "MegaPass=\"$MegaPass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "OpenDriveUser=\"$OpenDriveUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "OpenDrivePass=\"$OpenDrivePass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "PikPakUser=\"$PikPakUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "PikPakPass=\"$PikPakPass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "ProtonDriveUser=\"$ProtonDriveUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "ProtonDrivePass=\"$ProtonDrivePass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "MailruUser=\"$MailruUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "MailruPass=\"$MailruPass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "UloztoUser=\"$UloztoUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "UloztoPass=\"$UloztoPass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "WebDAVUser=\"$WebDAVUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "WebDAVPass=\"$WebDAVPass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "IDriveUser=\"$IDriveUser\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "IDrivePass=\"$IDrivePass\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	echo "Port=\"$Port\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "RemoteDir=\"$RemoteDir\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Retention=\"$Retention\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null
	echo "Sync=\"$Sync\"" | sudo tee -a /var/go/etc/$Storage.conf >/dev/null

	# Setup Schedule Backup
	if [ "$Destination" = "local" ]; then
		sudo rclone config delete $Storage
	elif [[ "$Destination" == "ftp" || "$Destination" = "sftp" ]]; then
		sudo rclone config create $Storage $Destination known_hosts_file=none host=$RemoteServer user=$RemoteUser pass=$RemotePass port=$Port --obscure
	elif [ "$Destination" = "s3" ]; then
		sudo rclone config create $Storage $Destination access_key_id=$AccessKeyID secret_access_key=$SecretAccessKey endpoint=$Endpoint provider=$Provider region=$Region
	elif [ "$Destination" = "ulozto" ]; then
		sudo rclone config create $Storage $Destination app_token=$AppToken username=$UloztoUser password=$UloztoPass
	elif [ "$Destination" = "webdav" ]; then
		sudo rclone config create $Storage $Destination url=$Url vendor=$Vendor user=$WebDAVUser pass=$WebDAVPass --obscure
	elif [ "$Destination" = "mega" ]; then
		sudo rclone config create $Storage $Destination user=$MegaUser pass=$MegaPass
	elif [ "$Destination" = "protondrive" ]; then
		sudo rclone config create $Storage $Destination user=$ProtonDriveUser pass=$ProtonDrivePass
	elif [ "$Destination" = "fichier" ]; then
		sudo rclone config create $Storage $Destination api_key=$ApiKey
	elif [[ "$Destination" == "drime" || "$Destination" = "gofile" ]]; then
		sudo rclone config create $Storage $Destination access_token=$AccessToken
	elif [ "$Destination" = "pikpak" ]; then
		sudo rclone config create $Storage $Destination user=$PikPakUser pass=$PikPakPass --non-interactive
	elif [ "$Destination" = "opendrive" ]; then
		sudo rclone config create $Storage $Destination username=$OpenDriveUser password=$OpenDrivePass
	elif [ "$Destination" = "internxt" ]; then
		sudo rclone config create $Storage $Destination email=$Email pass=$RemotePass
	elif [ "$Destination" = "linkbox" ]; then
		sudo rclone config create $Storage $Destination token=$Token email=$Email password=$RemotePass
	elif [ "$Destination" = "mailru" ]; then
		sudo rclone config create $Storage $Destination user=$MailruUser pass=$MailruPass speedup_enable=true
	elif [ "$Destination" = "azureblob" ]; then
		sudo rclone config create $Storage $Destination account=$Account key=$Key
	elif [ "$Destination" = "azurefiles" ]; then
		sudo rclone config create $Storage $Destination account=$Account ShareName=$ShareName key=$Key
	elif [ "$Destination" = "idrive" ]; then

		sudo mkdir -p /backup/idrive

		# Delete all lines containing "idrivecron" from your crontab 
		crontab -l | grep -v "idrivecron" | crontab -

		echo "Run /opt/IDriveForLinux/bin/idrive from command line. Select \"Edit your Backupset\". Specify source: /backup/idrive"

	fi

	if [ ! "$Quiet" = "1" ]; then
	
		if [ "$Destination" = "sftp" ]; then

			if [ "$RemoteServer" = "-" ]; then
			
				echo "Please enter your remote server"
				exit 1

			fi

			echo "" | sudo tee /usr/local/goadmio/tmp/connection.db >/dev/null
			
			Connection=$(rclone copy /usr/local/goadmio/tmp/connection.db $Storage:connection/connection.db)
			sudo rclone purge $Storage:connection

			if [ ! "$Connection" = "" ]; then
			   
				# Connection Failed
				echo "$Connection"
			   
			else
			
				sudo rclone delete $Storage:connection/connection.db
			
				echo "Setup Completed Successfully"
				
			fi

		else
		
			echo "Setup Completed Successfully"
			
		fi
		
	fi

	sudo /go/cron

	exit 1

fi

if [ "$Type" = "" ] || [ "$Type" = "full" ] || [ "$Type" = "www" ] || [ "$Type" = "mail" ] || [ "$Type" = "database" ] || [ "$Type" = "wwwmail" ] || [ "$Type" = "wwwdatabase" ] || [ "$Type" = "maildatabase" ]; then

	if [ "$Type" = "" ]; then
		Type="full"	
	fi

else

	echo "Invalid backup type: $Type"
	exit 1
	
fi

if [ "$Domain" = "all" ]; then

	# Count Websites 
	C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print| wc -l)

	X=0
	
	cd /home
	for Domain in *
	do
	
		Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

		if [[ "$Domain" = *"."* ]] && [ "$Domain" != "lost+found" ] && [ "$Domain" != "temp.txt" ] ; then
	
			X=$(($X + 1))
	
			if sudo test -d "/home/$Domain/www" ; then

				if [ "$RemoteDir" = "" ]; then

					echo "[$X/$C] Backup $Domain [Local Backup]"
					sudo /go/backup $Domain
					
				else
									
					Backup=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Backup from Site where Domain='$Domain' and Trash=0")

					if [ "$Backup" = "1" ]; then

						if [ "$Destination" = "local" ]; then
							
							echo -ne "[$X/$C] Copying $Domain $Type backup to $RemoteDir | Compressing..."
						
						elif [ "$Destination" = "idrive" ]; then
						
							echo -ne "[$X/$C] Transferring $Domain $Type Backup to IDrive:backup/idrive/$Date | Compressing..."
						
						else
						
							if [ "$X" = "1" ]; then
							
								echo "" | sudo tee /usr/local/goadmio/tmp/connection.db >/dev/null

								Connection=$(rclone copy /usr/local/goadmio/tmp/connection.db $Storage:connection/connection.db)
								sudo rclone purge $Storage:connection

								if [ ! "$Connection" = "" ]; then
								   
									# Connection Failed
									echo "$Connection"
								
									sudo /go/sendmail "Schedule Backup Failed" "Connection Failed ($RemoteServer)..." "Backup"
									sudo /go/sendwhatsapp "*Schedule Backup Failed*\nConnection Failed ($RemoteServer)" "Backup"
									
									exit 1	
								   
								else
									echo "Connecting..."
								fi
						
							fi

							echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
							printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
							sudo /go/log "[$X/$C] Transferring $Domain $Type Backup to $Storage:${RemoteDir##+(/)}" $(basename "$0")
							echo -ne "[$X/$C] Transferring $Domain $Type Backup to $Storage:${RemoteDir##+(/)} | Compressing..."

						fi

						sudo /go/backup --domain "$Domain" --type "$Type" --destination "$Destination" --remoteserver "$RemoteServer" --remoteuser "$RemoteUser" --remotepass "$RemotePass" --megauser "$MegaUser" --megapass "$MegaPass" --opendriveuser "$OpenDriveUser" --opendrivepass "$OpenDrivePass" --pikpakuser "$PikPakUser" --pikpakpass "$PikPakPass" --protondriveuser "$ProtonDriveUser" --protondrivepass "$ProtonDrivePass" --mailruuser "$MailruUser" --mailrupass "$MailruPass" --uloztouser "$UloztoUser" --uloztopass "$UloztoPass" --webdavuser "$WebDAVUser" --webdavpass "$WebDAVPass" --port "$Port" --remotedir "$RemoteDir" --email "$Email" --retention "$Retention" --sync "$Sync" --date "$Date" --storage "$Storage"
						
						BackupStamp=$(date +'%s')
						sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET BackupStamp='$BackupStamp' where Domain='$Domain'"
					
					else
					
						echo "[$X/$C] Backup Disabled $Domain"

					fi
					
				fi
				
			else
			
				echo "[$X/$C] /home/$Domain/www not exists"
				
			fi
			
		fi

	done
	
	echo ""

	Hostname=$(</etc/hostname)
	sudo /go/sendmail "Schedule Backup Finished (Copied: $X Sites)" "Copied: $X Sites" "Backup"
	sudo /go/sendwhatsapp "*Schedule Backup Finished (Copied: $X Sites)*\nCopied: $X Sites" "Backup"

	exit 1

fi

# Day of Year
D=$(date +'%j')
D=$(echo $D | sed 's/^0*//')
E=$(( $D % 2 ))
	
N=0

if sudo test ! -d "/home/$Domain"; then
	echo "BACKUP: Domain Directory /home/$Domain not exists."
	exit 1
fi

Dir="$Type-backup-$Date-$Domain"

sudo rm -rf /home/$Domain/log
sudo rm -rf /home/$Domain/$Dir.tar.gz
sudo rm -rf /usr/local/goadmio/backup/$Type-backup-*-$Domain-*.tar.gz

sudo mkdir -p /home/$Domain/etc
sudo mkdir -p /home/$Domain/log
sudo mkdir -p /home/$Domain/log/include
sudo mkdir -p /home/$Domain/log/mysql
sudo mkdir -p /home/$Domain/log/postgre
sudo mkdir -p /home/$Domain/log/subdomain
sudo mkdir -p /home/$Domain/log/mail

if [ "$Type" = "full" ] || [[ "$Type" = *"www"* ]]; then

	# Backup Subdomains
	sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/subdomain.db "
		SELECT IFNULL(Subdomain,'') || '|' || IFNULL(DocumentRoot,'') || '|' || IFNULL(RedirectUrl,'') || '|' || IFNULL(Domain,'') || '|' || IFNULL(Username,'') || '|' || IFNULL(PHPVersion,'') || '|' || IFNULL(TimeStamp,'')
		FROM Subdomain
		WHERE Domain='$Domain'
	" | while IFS='|' read -r Subdomain DocumentRoot RedirectUrl Domain Username PHPVersion TimeStamp
	do
		
		echo "Subdomain=\"$Subdomain\"" | sudo tee /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "DocumentRoot=\"$DocumentRoot\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "RedirectUrl=\"$RedirectUrl\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "Domain=\"$Domain\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "Username=\"$Username\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "PHPVersion=\"${Row[4]}\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
		echo "TimeStamp=\"$TimeStamp\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null

	done
	
fi

sudo /go/siteconf $Domain

# Linux Password 
sudo cat /etc/shadow | grep "$Username:" | head -n 1 > /home/$Domain/log/include/shadow

if [ "$Type" = "full" ] || [[ "$Type" = *"database"* ]]; then

	# MariaDB
	SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "SELECT Name FROM Mysql WHERE Domain='$Domain'")
	for Name in $SQL
	do
	
		User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select User from Mysql where Name='$Name'")
		Pass=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select Password from mysql.user where User='$User'")

		echo "$User|$Pass" | sudo tee /home/$Domain/log/mysql/$Name.pwd >/dev/null
		sudo mariadb-dump -uroot -p$MySQLRootPassword $Name > /home/$Domain/log/mysql/$Name.sql

	done

	# PostgreSQL 
	SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Domain='$Domain'")
	for Name in $SQL
	do

		User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where Name='$Name'")
		Pass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Pass from Postgre where Name='$Name'")

		echo "$User|$Pass" | sudo tee /home/$Domain/log/postgre/$Name.pwd >/dev/null
		# PGPASSWORD="$Pass" pg_dump -U $User -h hostname $Name > /home/$Domain/log/postgre/$Name.sql
		sudo su - postgres -c "pg_dump $Name > /home/$Domain/log/postgre/$Name.sql"

	done

fi

if [ "$Type" = "full" ] || [[ "$Type" = *"mail"* ]]; then

	if sudo test -d "/home/$Domain/mail" ; then

		sudo /go/mailconf $Domain

	fi

fi

cd /home/$Domain

if [ "$Type" = "www" ]; then
	sudo tar -cpzf $Dir.tar.gz www etc log --transform "s,^,$Dir/,"
elif [ "$Type" = "mail" ]; then
	sudo tar -cpzf $Dir.tar.gz mail etc log --transform "s,^,$Dir/,"	
elif [ "$Type" = "database" ]; then
	sudo tar -cpzf $Dir.tar.gz etc log sqlite --transform "s,^,$Dir/,"
elif [ "$Type" = "wwwmail" ]; then
	sudo tar -cpzf $Dir.tar.gz www mail etc log --transform "s,^,$Dir/,"	
elif [ "$Type" = "wwwdatabase" ]; then
	sudo tar -cpzf $Dir.tar.gz www etc log sqlite --transform "s,^,$Dir/,"	
elif [ "$Type" = "maildatabase" ]; then
	sudo tar -cpzf $Dir.tar.gz mail etc log sqlite --transform "s,^,$Dir/,"	
else
	# Full Backup
	sudo tar -cpzf $Dir.tar.gz www mail etc log sqlite --transform "s,^,$Dir/,"	
fi

if sudo test -f "/home/$Domain/$Dir.tar.gz" ; then
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b\b\bCopying...    "
	echo ""
	sudo rm -rf /home/$Domain/log/include
	sudo rm -rf /home/$Domain/log/mysql
	sudo rm -rf /home/$Domain/log/postgre
	sudo rm -rf /home/$Domain/log/subdomain
	sudo rm -rf /home/$Domain/log/mail
	
fi

if [ "$Destination" = "homedir" ]; then

	echo "Backup: /home/$Domain/$Dir.tar.gz"

elif [ "$Destination" = "url" ]; then
	
	echo "Options -Indexes" | sudo tee /usr/local/goadmio/backup/.htaccess >/dev/null
	echo "GoAdmio Backup..." | sudo tee /usr/local/goadmio/backup/index.html >/dev/null
	
	Security=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)

	sudo mv /home/$Domain/$Dir.tar.gz /usr/local/goadmio/backup/$Dir-$Security.tar.gz
	
	echo "Download URL: http://$Domain/backup/$Dir.tar.gz"

elif [ "$Destination" = "backup" ]; then

	sudo mv /home/$Domain/$Dir.tar.gz /backup/$Dir.tar.gz
	
	sudo rm -rf /home/$Domain/$Dir.tar.gz
	
elif [ "$Destination" = "sftp" ]; then
	
	sudo sshpass -p "$RemotePass" rsync -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/$Dir.tar.gz $RemoteUser@$RemoteServer:$RemoteDir
	sudo rm -rf /home/$Domain/$Dir.tar.gz
	
elif [ "$Destination" = "local" ]; then

	sudo mv /home/$Domain/$Dir.tar.gz $RemoteDir/$Dir.tar.gz

elif [ "$Destination" = "idrive" ]; then

	# Drive Cloud
	# if sudo test -f /usr/bin/idrive-cli ; then
	#	/usr/bin/idrive-cli upload /home/$Domain/$Dir.tar.gz $RemoteDir/idrive
	# else
	# /usr/local/bin/idrive-cli upload /home/$Domain/$Dir.tar.gz $RemoteDir/idrive
	# fi
	
	# Drive Backup
	sudo mkdir -p /backup/idrive/$Date/
	sudo mv /home/$Domain/$Dir.tar.gz /backup/idrive/$Date/$Dir.tar.gz
	/opt/IDriveForLinux/bin/idrive --backup
	sudo rm -rf /backup/idrive/*

else

	if grep -q "\[ "$Storage"\]" /root/.config/rclone/rclone.conf; then
		echo "[$Storage]"
		sudo rclone copy /home/$Domain/$Dir.tar.gz $Storage:${RemoteDir##+(/)} -P
	else
		echo "[$Storage] Mot Exists."				
	fi
		
	sudo rm -rf /home/$Domain/$Dir.tar.gz
		
fi

sudo rm -f $LockFile