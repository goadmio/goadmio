#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/snapshot "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

LockFile="/usr/local/goadmio/lock/backup.lock"
if [[ ! "$1" = *"."* ]] && [[ ! "$1" = "list" ]]; then

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

sudo mkdir -p /var/log/go
sudo mkdir -p /var/go/etc

restic cache --cleanup >/dev/null 2>&1

Domain=$1

MinIO=0
if sudo test -f /usr/local/goadmio/minio/minio.conf  && sudo test -d /s3 ; then

    if grep -q ":443 " /usr/local/goadmio/minio/minio.conf; then
        MinIO=1
    fi

fi

export RESTIC_PASSWORD="GoPanel"
export RCLONE_CONFIG="/root/.config/rclone/rclone.conf"
Hostname=$(</etc/hostname)

if sudo test -f /usr/local/goadmio/include/config/config.php ; then
    OS=$(</usr/local/goadmio/linux/os.db)
    MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)
fi

Date=$(date +'%Y-%m-%d')

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
if [ "$Threads" -ge 2 ]; then
    Parallel=$(($Threads / 2))
else
    Parallel=1
fi

if sudo test -f "/var/go/etc/snapshot.conf" ; then

    source /var/go/etc/snapshot.conf

    if [[ "$RemoteDir" == "" || "$RemoteDir" == "/" || "$RemoteDir" = "/snapshot" ]]; then
        RemoteDir="snapshot"
    else
        RemoteDir="${RemoteDir#/}"
    fi

    if [ "$RestoreDir" = "" ]; then
        RestoreDir="/"
    fi

else

    echo "File /var/go/etc/snapshot.conf not Exists."

    sudo rm -rf /usr/local/goadmio/lock/backup.lock
    exit 1

fi

BACKUP() {
    Domain=$1

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
        sudo mkdir -p /var/snapshot/$Domain
    fi

    if [ "$MinIO" = "1" ] && sudo test -d "/s3/$Domain" ; then

        # MinIO Server
        restic init --repo $ResticDestination >/dev/null 2>&1

        # Check if restic repository exists and is initialized
        if ! restic -r "$ResticDestination" snapshots &>/dev/null; then

            echo "Repository Missing: $ResticDestination, System will Initialize new Repository."
            sudo rclone purge $Destination
            restic init --repo $ResticDestination >/dev/null 2>&1

        fi

        # Remove old snapshots
        restic --repo $ResticDestination forget --keep-within 24h --keep-daily 7 --keep-weekly 4 --keep-monthly 12
        restic --repo $ResticDestination prune

        echo "Creating Snapshot: $Destination..."
        restic backup /s3/$Domain --repo $ResticDestination --compression auto --tag $Date

    elif sudo test -d "/home/$Domain"  && sudo test -d "/scripts" ; then

        # cPanel

        restic init --repo $ResticDestination >/dev/null 2>&1

        # Check if restic repository exists and is initialized
        if ! restic -r "$ResticDestination" snapshots &>/dev/null; then

            echo "Repository Missing: $ResticDestination, System will Initialize new Repository."
            sudo rclone purge $Destination
            restic init --repo $ResticDestination >/dev/null 2>&1

        fi

        # Remove old snapshots
        restic --repo $ResticDestination forget --keep-within 24h --keep-daily 7 --keep-weekly 4 --keep-monthly 12
        restic --repo $ResticDestination prune

        echo "Creating Snapshot: $Destination..."
        restic backup /home/$Domain --repo $ResticDestination --compression auto --tag $Date

    elif sudo test -d "/home/$Domain" ; then

        sudo rm -rf /home/$Domain/log

        sudo mkdir -p /home/$Domain/log
        sudo mkdir -p /home/$Domain/log/include
        sudo mkdir -p /home/$Domain/log/mysql
        sudo mkdir -p /home/$Domain/log/postgre
        sudo mkdir -p /home/$Domain/log/subdomain

        # Backup Subdomains
        sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/subdomain.db "
			SELECT IFNULL(Subdomain,'') || '|' || IFNULL(DocumentRoot,'') || '|' || IFNULL(RedirectUrl,'') || '|' || IFNULL(Domain,'') || '|' || IFNULL(Username,'') || '|' || IFNULL(PHPVersion,'') || '|' || IFNULL(TimeStamp,'')
			FROM Subdomain
			WHERE Domain='$Domain'
		" | while IFS='|' read -r Subdomain DocumentRoot RedirectUrl Domain Username PHPVersion TimeStamp; do

            echo "Subdomain=\"$Subdomain\"" | sudo tee /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "DocumentRoot=\"$DocumentRoot\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "RedirectUrl=\"$RedirectUrl\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "Domain=\"$Domain\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "Username=\"$Username\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "PHPVersion=\"${Row[4]}\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null
            echo "TimeStamp=\"$TimeStamp\"" | sudo tee -a /home/$Domain/log/subdomain/$Subdomain.conf >/dev/null

        done

        if [[ ! $@ = *"--skip mysql"* ]]; then

            # MariaDB
            SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "SELECT Name FROM Mysql WHERE Domain='$Domain'")
            for Name in $SQL; do

                User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select User from Mysql where Name='$Name'")
                Pass=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "select Password from mysql.user where User='$User'")

                echo "$User|$Pass" | sudo tee /home/$Domain/log/mysql/$Name.pwd >/dev/null
                sudo /usr/bin/mariadb-dump -uroot -p$MySQLRootPassword $Name >/home/$Domain/log/mysql/$Name.sql

            done

        fi

        # PostgreSQL
        SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Domain='$Domain'")
        for Name in $SQL; do

            User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where Name='$Name'")
            Pass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Pass from Postgre where Name='$Name'")

            echo "$User|$Pass" | sudo tee /home/$Domain/log/postgre/$Name.pwd >/dev/null
            # PGPASSWORD="$Pass" pg_dump -U $User -h hostname $Name > /home/$Domain/log/postgre/$Name.sql
            sudo su - postgres -c "pg_dump $Name > /home/$Domain/log/postgre/$Name.sql"

        done

        if sudo test -d "/home/$Domain/mail" ; then

            sudo /go/mailconf $Domain

        fi

        sudo /go/siteconf $Domain

        # Linux Password
        sudo cat /etc/shadow | grep "$Username:" | head -n 1 >/home/$Domain/log/include/shadow

        restic init --repo $ResticDestination >/dev/null 2>&1

        # Check if restic repository exists and is initialized
        if ! restic -r "$ResticDestination" snapshots &>/dev/null; then

            echo "Repository Missing: $ResticDestination, System will Initialize new Repository."
            sudo rclone purge $Destination
            restic init --repo $ResticDestination >/dev/null 2>&1

        fi

        # Remove old snapshots
        restic --repo $ResticDestination forget --keep-within 24h --keep-daily 7 --keep-weekly 4 --keep-monthly 12
        restic --repo $ResticDestination prune

        echo "Creating Snapshot: $Destination..."
        restic backup /home/$Domain --repo $ResticDestination --compression auto --tag $Date

        sudo rm -rf /home/$Domain/log/*

    fi

    SnapshotStamp=$(date +'%s')
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SnapshotStamp='$SnapshotStamp' where Domain='$Domain'"

}

RESTORE() {
    Domain=$1
    Archive=$2

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    if [[ "$@" = *"--mail"* ]]; then
        Parameter="$Parameter --include /home/$Domain/mail"
    fi

    if [[ "$@" = *"--www"* ]]; then
        Parameter="$Parameter --include /home/$Domain/www"
    fi

    if [[ "$@" = *"--database"* ]]; then
        Parameter="$Parameter --include /home/$Domain/log"
    fi

    Parameter=$(echo "$Parameter" | xargs echo -n)

    if [ "$Archive" != "" ]; then

        if [[ $(restic --repo $ResticDestination snapshots --tag $Archive | wc -l) -gt "1" ]]; then

            # rm -rf $Dir
            # mkdir -p $Dir

            echo "Restoring Snapshot TAG $Archive..."
            restic --repo $ResticDestination restore latest --target $RestoreDir --tag $Archive $Parameter

        elif [[ $(restic --repo $ResticDestination snapshots $Archive | wc -l) -gt "1" ]]; then

            echo "Restoring Snapshot ID $Archive..."

            restic --repo $ResticDestination restore $Archive --target $RestoreDir $Parameter

        else

            echo "Archive $Archive does not exist"
            restic --repo $ResticDestination snapshots

            sudo rm -rf /usr/local/goadmio/lock/backup.lock
            exit 1

        fi

        if sudo test -f /home/$Domain/log/include/site.conf ; then

            # Restore Using SITE.CONF
            sudo /go/create $Domain

            # Temporary hide from Go interface (Preventing Site deletion while a recovery process is in progress)
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Trash=1 where Domain='$Domain'"

        fi

        if sudo test -d /home/$Domain/log/subdomain ; then

            if [[ "$@" = *"--www"* ]] || [ "$Parameter" = "" ]; then

                printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
                echo "Restoring Subdomains..."

                cd /home/$Domain/log/subdomain
                for File in *; do

                    if [[ "$File" = *".conf" ]]; then

                        source /home/$Domain/log/subdomain/$File
                        sudo /go/subdomain --subdomain $Subdomain --documentroot $DocumentRoot --redirecturl $RedirectUrl

                    fi

                done

            fi

        fi

        if sudo test -d /home/$Domain/mail ; then

            if [[ "$@" = *"--mail"* ]] || [ "$Parameter" = "" ]; then

                printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
                echo "Restoring $Domain Email Accounts..."
                sudo chown vmail:vmail -R /home/$Domain/mail
                cd /home/$Domain/mail
                for User in *; do

                    if sudo test -d "/home/$Domain/mail/$User" ; then

                        source /home/$Domain/mail/$User.conf
                        Email="$User@$Domain"

                        if [[ "$Email" = *"@"* ]] && [ "$Pass" != "" ] && [[ "$Domain" = *"."* ]]; then
                            sudo /go/mail --email "$Email" --pass "$Pass" --forwardto "$ForwardTo" --reject "$Reject" --rejectmessage "$RejectMessage" --keepcopy "$KeepCopy" --domain "$Domain" --defaultaddress "$DefaultAddress" --suspend "$Suspend" --admin "$Admin" --description "$Description" --timestamp "$TimeStamp" --action add --norestart 1
                        fi

                    fi

                done

            fi

        fi

        if sudo test -f "/home/$Domain/log/include/shadow" ; then
            # Restore Linux Password
            sudo sed -i "/^$Username:/d" /etc/shadow
            LinuxPassword=$(</home/$Domain/log/include/shadow)
            echo "$LinuxPassword" | sudo tee -a /etc/shadow >/dev/null
        fi

        if sudo test -d /home/$Domain/log/mysql ; then

            if [[ "$@" = *"--database"* ]] || [ "$Parameter" = "" ]; then

                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "DELETE FROM Mysql WHERE Domain='$Domain'"

                printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
                echo "Restoring $Domain MySQL/MariaDB Databases.."
                cd /home/$Domain/log/mysql
                for File in *; do

                    if [[ "$File" = *".sql" ]]; then

                        Name=${File/.sql/}

                        DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Name from Mysql where Name='$Name'")
                        if [ "$Name" = "$DatabaseExists" ]; then
                            echo "Database '$Name' already exists."
                        else

                            DBInfo=$(</home/$Domain/log/mysql/$Name.pwd)

                            IFS='|' read -r -a Array <<<"$DBInfo"
                            User="${Array[0]}"
                            Pass="${Array[1]}"

                            sudo /go/mysql $Domain $Name $User $Pass

                            echo "Restoring MySQL/MariaDB Database $Name..."

                            if [[ ! $@ = *"--skip mysql"* ]]; then
                                pv $File | mariadb -uroot -p$MySQLRootPassword $Name
                                sudo mariadb -uroot -p$MySQLRootPassword -e "GRANT USAGE ON $Name.* TO '$User'@'localhost' IDENTIFIED BY PASSWORD '$Pass';"
                            fi

                        fi

                    fi

                done

            fi

        fi

        if sudo test -d /home/$Domain/log/postgre ; then

            if [[ "$@" = *"--database"* ]] || [ "$Parameter" = "" ]; then

                printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
                echo "Restoring $Domain PostgreSQL Databases.."
                cd /home/$Domain/log/postgre
                for File in *; do

                    if [[ "$File" = *".sql" ]]; then

                        Name=${File/.sql/}

                        DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Name='$Name'")
                        if [ "$Name" = "$DatabaseExists" ]; then
                            echo "Database '$Name' already exists."
                        else

                            DBInfo=$(</home/$Domain/log/postgre/$Name.pwd)

                            IFS='|' read -r -a Array <<<"$DBInfo"
                            User="${Array[0]}"
                            Pass="${Array[1]}"

                            sudo /go/postgre $Domain $Name $User $Pass

                            echo "Restoring PostgreSQL Database $Name..."
                            sudo su - postgres -c "psql -d $Name -f /home/$Domain/log/postgre/$File"

                        fi

                    fi

                done

            fi

        fi

        printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

        sudo /go/ssl $Domain
        sudo /go/fix $Domain

        sudo rm -rf /home/$Domain/log/*

        # Show Domain in Go Interface
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Trash=0 where Domain='$Domain'"

    fi

}

DELETE() {
    Domain=$1

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        sudo rclone purge $Destination
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
        sudo rm -rf $Destination
    fi
}

LIST() {
    Domain=$1

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    restic --repo $ResticDestination snapshots

}

CHECK() {
    Domain=$1

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
        sudo mkdir -p /var/snapshot/$Domain
    fi

    # Check if restic repository exists and is initialized
    if ! restic -r "$ResticDestination" snapshots &>/dev/null; then

        echo "Repository Missing: $ResticDestination, System will Initialize new Repository."

        sudo rclone purge $Destination
        sudo /go/snapshot $Domain

    fi

}

if [ "$1" = "list" ]; then

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname"
    else
        ResticDestination="/var/snapshot"
    fi

    if [[ "$Destination" = *":"* ]]; then
        sudo rclone lsd $Destination | awk '$5 ~ /\./ {print $5}'
    else
        sudo find "$ResticDestination" -maxdepth 1 -type d -name "*.*" -exec basename {} \;
    fi

    sudo rm -rf /usr/local/goadmio/lock/backup.lock
    exit 1

fi

# Restore One MySQL Database
if [[ "$1" = *".sql" ]]; then

    Archive=$2

    Domain=$(echo "$1" | cut -d'/' -f3)
    SQLFile=$(basename "$1")
    Database="${SQLFile%.sql}"

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    sudo mkdir -p /home/$Domain/log/mysql
    Parameter="--include /home/$Domain/log/mysql/$SQLFile"

    if [[ $(restic --repo $ResticDestination snapshots --tag $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring MySQL $SQLFile From TAG $Archive..."
        restic --repo $ResticDestination restore latest --target $RestoreDir --tag $Archive $Parameter

    elif [[ $(restic --repo $ResticDestination snapshots $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring MySQL $SQLFile From ID $Archive..."

        restic --repo $ResticDestination restore $Archive --target $RestoreDir $Parameter

    else

        echo "Archive $Archive does not exist"

        restic --repo $ResticDestination snapshots

        sudo rm -rf /usr/local/goadmio/lock/backup.lock
        exit 1

    fi

    if sudo test -f /home/$Domain/log/mysql/$SQLFile ; then

        sudo screen -d -m bash -c "mariadb -uroot -p$MySQLRootPassword $Database < /home/$Domain/log/mysql/$SQLFile && rm -rf /home/$Domain/log/mysql/$SQLFile"

    fi

    sudo rm -rf /usr/local/goadmio/lock/backup.lock
    exit 1

fi

# Restore Directory
if [[ "$1" = *"/"* ]]; then

    Archive=$2

    Domain=$(echo "$1" | cut -d'/' -f3)

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    Parameter="--include $1"

    if [[ $(restic --repo $ResticDestination snapshots --tag $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring Directory $1 From TAG $Archive..."
        restic --repo $ResticDestination restore latest --target $RestoreDir --tag $Archive $Parameter

    elif [[ $(restic --repo $ResticDestination snapshots $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring Directory $1 From ID $Archive..."

        restic --repo $ResticDestination restore $Archive --target $RestoreDir $Parameter

    else

        echo "Archive $Archive does not exist"

        restic --repo $ResticDestination snapshots

        sudo rm -rf /usr/local/goadmio/lock/backup.lock
        exit 1

    fi

    if [[ "$1" = *"/$Domain/mail"* ]]; then
        # Create missing Email from folders
        sudo /go/mail --domain $Domain --action create
    fi

    if sudo test -d /home/$Domain; then
        sudo /go/fix $Domain
    fi

    sudo rm -rf /usr/local/goadmio/lock/backup.lock
    exit 1

fi

# Restore One Email Account
if [[ "$1" = *"@"* ]]; then

    Archive=$2

    IFS='@' read -r -a EmailArray <<<"$Domain"
    User="${EmailArray[0]}"
    Domain="${EmailArray[1]}"

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    Parameter="--include /home/$Domain/mail/$User"

    if [[ $(restic --repo $ResticDestination snapshots --tag $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring Email $1 From TAG $Archive..."
        restic --repo $ResticDestination restore latest --target $RestoreDir --tag $Archive $Parameter

    elif [[ $(restic --repo $ResticDestination snapshots $Archive | wc -l) -gt "1" ]]; then

        echo "Restoring Email $1 From ID $Archive..."

        restic --repo $ResticDestination restore $Archive --target $RestoreDir $Parameter

    else

        echo "Archive $Archive does not exist"

        restic --repo $ResticDestination snapshots

        sudo rm -rf /usr/local/goadmio/lock/backup.lock
        exit 1

    fi

    exit 1

fi

if [[ "$@" = *"--list"* ]]; then

    if grep -q "\[snapshot\]" /root/.config/rclone/rclone.conf; then
        Destination="snapshot:$RemoteDir/$Hostname/$Domain"
        ResticDestination="rclone:$Destination"
    else
        Destination="/var/snapshot/$Domain"
        ResticDestination="/var/snapshot/$Domain"
    fi

    restic --repo $ResticDestination snapshots --json | jq -r '.[] | "\(.short_id)|\(.tags[])|\(.time | split(".")[0] + "Z" | fromdate)"'

    sudo rm -rf /usr/local/goadmio/lock/backup.lock
    exit 1

fi

if [ $# -eq 0 ] || [ "$1" = "all" ]; then

    N=0

    if [ "$MinIO" = "1" ]; then

        C=$(sudo find /s3 -maxdepth 1 -type d -print | wc -l)

        cd /s3
        for Domain in *; do

            if [ "$2" = "list" ]; then
                LIST "$Domain"
            elif [ "$2" = "restore" ]; then
                RESTORE "$Domain" "$3" "$@"
            else

                if sudo test -d /s3/$Domain ; then

                    N=$(($N + 1))

                    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
                    echo "[$N/$C] Snapshot Backup S3 $Domain..."
                    BACKUP "$Domain"

                fi

            fi

        done

    else

        if sudo test -d "/var/cpanel/users" ; then
            C=$(sudo find /home -maxdepth 1 -type d -print | wc -l)
        else
            C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
        fi

        cd /home
        for Domain in *; do

            if [ "$2" = "list" ]; then
                LIST "$Domain"
            elif [ "$2" = "restore" ]; then
                RESTORE "$Domain" "$3" "$@"
            else

                if sudo test -d /home/$Domain/www ; then

                    N=$(($N + 1))

                    Snapshot=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Snapshot from Site where Domain='$Domain'")
                    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

                    if [ "$Snapshot" = "1" ]; then

                        echo "[$N/$C] Snapshot Backup $Domain..."
                        BACKUP "$Domain"

                    else

                        echo "[$N/$C] Snapshot Backup Disabled $Domain..."

                    fi

                fi

            fi

        done

    fi

elif [ "$1" = "check" ]; then

    N=0

    if sudo test -d "/var/cpanel/users" ; then
        C=$(sudo find /home -maxdepth 1 -type d -print | wc -l)
    else
        C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    fi

    cd /home
    for Domain in *; do

        if sudo test -d /home/$Domain/www ; then

            N=$(($N + 1))

            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
            echo "[$N/$C] Check $Domain..."
            CHECK "$Domain"

        fi

    done

else

    if [ "$MinIO" = "1" ]; then

        if [ "$2" = "list" ]; then
            LIST "$Domain"
        elif [ "$2" = "delete" ]; then
            DELETE "$Domain"
        elif [ "$2" = "restore" ]; then
            RESTORE "$Domain" "$3" "$@"
        else

            if sudo test -d /s3/$Domain ; then
                BACKUP "$Domain"
            else
                echo "Domain $Domain does not exist"
            fi

        fi

    elif [[ "$Domain" = *"."* ]]; then

        if [ "$2" = "list" ]; then
            LIST "$Domain"
        elif [ "$2" = "delete" ]; then
            DELETE "$Domain"
        elif [ "$2" = "restore" ]; then
            RESTORE "$Domain" "$3" "$@"
        else

            if sudo test -d /home/$Domain/www ; then
                BACKUP "$Domain"
            else
                echo "Domain $Domain does not exist"
            fi

        fi

    elif sudo test -d "/home/$Domain"  && sudo test -d "/scripts" ; then

        # cPanel

        if [ "$2" = "list" ]; then
            LIST "$Domain"
        elif [ "$2" = "restore" ]; then
            RESTORE "$Domain" "$3" "$@"
        else

            if sudo test -d /home/$Domain/public_html ; then
                BACKUP "$Domain"
            else
                echo "User $Domain does not exist"
            fi

        fi

    else

        echo "SNAPSHOT: Domain Directory /home/$1 not Exists"

    fi

fi

sudo rm -f $LockFile
