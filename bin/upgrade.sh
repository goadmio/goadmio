#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)
Hostname=$(</etc/hostname)
MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)
TimeStamp=$(date +%s)

source /go/function

sudo /go/mkdir
sudo /go/sudoers

File="A128"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        A=0

        # ALTER Function
        ALTER "CREATE TABLE IF NOT EXISTS Config (ConfigID INTEGER PRIMARY KEY,Version TEXT NOT NULL DEFAULT '',InstallStamp INT NOT NULL DEFAULT '0',SerialNo TEXT NOT NULL DEFAULT '',SSHPassword TEXT NOT NULL DEFAULT '',SSHPort INT NOT NULL DEFAULT '22',PHPVersion TEXT NOT NULL DEFAULT '',SecretCode TEXT NOT NULL DEFAULT '',AdminFullName TEXT NOT NULL DEFAULT '',AdminEmail TEXT NOT NULL DEFAULT '',CronEmail TEXT NOT NULL DEFAULT '',AdminMobile TEXT NOT NULL DEFAULT '',Hostname TEXT NOT NULL DEFAULT '',IPv4 TEXT NOT NULL DEFAULT '',IPv6 TEXT NOT NULL DEFAULT '',IMAPHostname TEXT NOT NULL DEFAULT 'localhost',IMAPPort TEXT NOT NULL DEFAULT '143',IMAPSecure TEXT NOT NULL DEFAULT 'None',IMAPShortLogin TEXT NOT NULL DEFAULT 'Off',SMTPAuth TEXT NOT NULL DEFAULT 'yes',BrevoAPIKey TEXT NOT NULL DEFAULT '',BrevoCredit INTEGER DEFAULT '0',ForwardEmailAPIToken TEXT NOT NULL DEFAULT '',RoundcubeSMTPHost TEXT NOT NULL DEFAULT '',RoundcubeSMTPPort TEXT NOT NULL DEFAULT '587',RoundcubeSMTPUser TEXT NOT NULL DEFAULT '',RoundcubeSMTPPass TEXT NOT NULL DEFAULT '',RoundcubeSMTPActive INTEGER DEFAULT '0',MyNetworks TEXT NOT NULL DEFAULT '',ServerLimit INTEGER DEFAULT '10000',ExternalLimit INTEGER DEFAULT '5000',DomainLimit INTEGER DEFAULT '250',UserLimit INTEGER DEFAULT '20',SMTPDelay INTEGER DEFAULT '0',PostfixSMTPPort TEXT NOT NULL DEFAULT '25',AdminNotify INTEGER DEFAULT '0',SPAM TINYINT NOT NULL DEFAULT '3',DateFormat TEXT NOT NULL DEFAULT '',SSH TEXT NOT NULL DEFAULT '',SSHFontSize INTEGER DEFAULT '14',CloudflareAccountID TEXT NOT NULL DEFAULT '',CloudflareAPIToken TEXT NOT NULL DEFAULT '',DynadotIP TEXT NOT NULL DEFAULT 'goadmio.com',DynadotAPIKey TEXT NOT NULL DEFAULT '',SpaceshipAPIKey TEXT NOT NULL DEFAULT '',SpaceshipAPISecret TEXT NOT NULL DEFAULT '',ResellerclubIP TEXT NOT NULL DEFAULT 'goadmio.com',ResellerclubUserID TEXT NOT NULL DEFAULT '',ResellerclubAPIKey TEXT NOT NULL DEFAULT '',WAInstanceID TEXT NOT NULL DEFAULT '',WAAPIKey TEXT NOT NULL DEFAULT '',AdditionalSPFRecords TEXT NOT NULL DEFAULT 'include:spf.goadmio.com include:_spf.google.com include:zohomail.com include:spf.forwardemail.net include:spf.ahasend.com',RebootPassword TEXT NOT NULL DEFAULT '',Bots TEXT NOT NULL DEFAULT '',HardDiskInfo TEXT NOT NULL DEFAULT '',PageNo INTEGER DEFAULT '20',PageBarNo INTEGER DEFAULT '10',LoginNo INTEGER DEFAULT '0',QueueNo INTEGER DEFAULT '500',SSHAlert INTEGER DEFAULT '1',IMAPAlert INTEGER DEFAULT '1',Junk INTEGER DEFAULT '1',ApacheLogRotate INTEGER DEFAULT '7',Heal INTEGER DEFAULT '1',PermitRootLogin INTEGER DEFAULT '1',RemoteMariaDB INTEGER DEFAULT '0',Welcome INTEGER DEFAULT '1',Requests INTEGER DEFAULT '0',Resource TEXT NOT NULL DEFAULT 'Unlimited',Quota INTEGER DEFAULT '0',MemoryLimit INTEGER DEFAULT '100',CPULimit INTEGER DEFAULT '100')"
        ALTER "CREATE TABLE IF NOT EXISTS Site (SiteID INTEGER PRIMARY KEY,Domain TEXT UNIQUE,Username TEXT UNIQUE,Password TEXT NOT NULL DEFAULT '',Salt TEXT NOT NULL DEFAULT '',OTP TEXT NOT NULL DEFAULT '',DocumentRoot TEXT NOT NULL DEFAULT '',FullName TEXT NOT NULL DEFAULT '',Mobile TEXT NOT NULL DEFAULT '',Email TEXT NOT NULL DEFAULT '' COLLATE NOCASE,PackageID INTEGER DEFAULT '0',DiskSpace INTEGER DEFAULT '0',SpaceUsed INTEGER DEFAULT '0',Bandwidth INTEGER DEFAULT '0',BandwidthUsed INTEGER DEFAULT '0',Inode INTEGER DEFAULT '0',InodeUsed INTEGER DEFAULT '0',FTPNo INTEGER DEFAULT '0',EmailNo INTEGER DEFAULT '0',DatabaseNo INTEGER DEFAULT '0',SubDomainNo INTEGER DEFAULT '0',AliasNo INTEGER DEFAULT '0',AddonNo INTEGER DEFAULT '0',Shell INTEGER DEFAULT '0',JailedShell INTEGER DEFAULT '0',Hostname TEXT NOT NULL DEFAULT '',IP TEXT NOT NULL DEFAULT '',Timezone TEXT NOT NULL DEFAULT '',ZoneID TEXT NOT NULL DEFAULT '',Permission TEXT NOT NULL DEFAULT '755',Description TEXT NOT NULL DEFAULT '',PHPVersion TEXT NOT NULL DEFAULT '',OpenBasedir TEXT NOT NULL DEFAULT '',DisableFunctions TEXT NOT NULL DEFAULT 'exec,mail,passthru,pcntl_exec,popen,proc_close,proc_get_status,proc_open,proc_terminate,shell_exec,system',SMTPHost TEXT NOT NULL DEFAULT '',SMTPUser TEXT NOT NULL DEFAULT '',SMTPPass TEXT NOT NULL DEFAULT '',SMTPPort TEXT NOT NULL DEFAULT '587',SMTPActive INTEGER DEFAULT '1',SMTPStatus INTEGER DEFAULT '-1',RoundcubeSMTPHost TEXT NOT NULL DEFAULT 'localhost',RoundcubeSMTPPort TEXT NOT NULL DEFAULT '587',RoundcubeSMTPUser TEXT NOT NULL DEFAULT '',RoundcubeSMTPPass TEXT NOT NULL DEFAULT '',RoundcubeSMTPActive INTEGER DEFAULT '0',UnpublishCode TEXT NOT NULL DEFAULT '',SSLCertificate INTEGER DEFAULT '0',SSLRedirect INTEGER DEFAULT '1',Bot INTEGER DEFAULT '1',FPM INTEGER DEFAULT '1',Proxy INTEGER DEFAULT '1',MailSpaceUsed INTEGER DEFAULT '0',VisitorNo INTEGER DEFAULT '0',Trash INTEGER DEFAULT '0',Suspend INTEGER DEFAULT '0',Unpublish INTEGER DEFAULT '0',FTPStatus INTEGER DEFAULT '1',FTPUpload INTEGER DEFAULT '1',FTPDownload INTEGER DEFAULT '1',FTPDelete INTEGER DEFAULT '1',Backup INTEGER DEFAULT '1',BackupStamp INTEGER DEFAULT '0',Snapshot INTEGER DEFAULT '1',SnapshotStamp INTEGER DEFAULT '0',ExpiresOn date,DomainExpiresOn date,SSLExpiresOn date,MailTTL INTEGER DEFAULT '0',CacheTTL INTEGER DEFAULT '86400',CacheLength INTEGER DEFAULT '0',CacheExclude TEXT NOT NULL DEFAULT 'php',CacheActive INTEGER DEFAULT '0',BrowserCacheTTL INTEGER DEFAULT '86400',FMStamp INTEGER DEFAULT '0',UnderAttackStamp INTEGER DEFAULT '0',APIIgnore INTEGER DEFAULT '0',PostfwdIgnore INTEGER DEFAULT '0',PostfwdDomainLimit INTEGER DEFAULT '0',PostfwdUserLimit INTEGER DEFAULT '0',UserID INTEGER DEFAULT '0',Owner TEXT NOT NULL DEFAULT '',TimeStamp INTEGER DEFAULT '0')"
        ALTER "CREATE TABLE IF NOT EXISTS Mail (MailID INTEGER PRIMARY KEY,Email TEXT UNIQUE COLLATE NOCASE,Pass TEXT NOT NULL DEFAULT '',ForwardTo TEXT NOT NULL DEFAULT '',Reject INTEGER DEFAULT '0',RejectMessage TEXT NOT NULL DEFAULT '',KeepCopy INTEGER DEFAULT '0',Domain TEXT NOT NULL DEFAULT '',Username TEXT NOT NULL DEFAULT '',DefaultAddress INTEGER DEFAULT '0',ResponderSubject TEXT NOT NULL DEFAULT '',ResponderMessage TEXT NOT NULL DEFAULT '',ResponderFirstDay date,ResponderLastDay date,ResponderActive INTEGER DEFAULT '0',Trash INTEGER DEFAULT '0',Suspend INTEGER DEFAULT '0',Admin INTEGER DEFAULT '0',SentToday INTEGER DEFAULT '0',SentThisWeek INTEGER DEFAULT '0',SentSunday INTEGER DEFAULT '0',SentMonday INTEGER DEFAULT '0',SentTuesday INTEGER DEFAULT '0',SentWednesday INTEGER DEFAULT '0',SentThursday INTEGER DEFAULT '0',SentFriday INTEGER DEFAULT '0',SentSaturday INTEGER DEFAULT '0',Description TEXT NOT NULL DEFAULT '',TimeStamp INTEGER DEFAULT '0')"
        ALTER "CREATE TABLE IF NOT EXISTS Package (PackageID INTEGER PRIMARY KEY,Name TEXT NOT NULL DEFAULT '',DiskSpace INTEGER DEFAULT '0',Bandwidth INTEGER DEFAULT '0',Inode INTEGER DEFAULT '0',FTPNo INTEGER DEFAULT '0',EmailNo INTEGER DEFAULT '0',DatabaseNo INTEGER DEFAULT '0',SubDomainNo INTEGER DEFAULT '0',AliasNo INTEGER DEFAULT '0',AddonNo INTEGER DEFAULT '0',Shell INTEGER DEFAULT '0',JailedShell INTEGER DEFAULT '0',SSLCertificate INTEGER DEFAULT '0',TimeStamp INTEGER DEFAULT '0',UserID INTEGER DEFAULT '0',ControlFile TEXT NOT NULL DEFAULT '')"
        ALTER "CREATE TABLE IF NOT EXISTS SMTP (SMTPID INTEGER PRIMARY KEY,SMTPHost TEXT NOT NULL DEFAULT 'localhost',SMTPPort TEXT NOT NULL DEFAULT '587',SMTPUser TEXT NOT NULL DEFAULT '',SMTPPass TEXT NOT NULL DEFAULT '',Active INTEGER DEFAULT '1',Priority INTEGER DEFAULT '0',SMTPStatus INTEGER DEFAULT '-1')"

        sudo /go/filter
        sudo /go/rclone
        sudo /go/fm all

        sudo /go/logrotate 1

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site set SMTPHost='',SMTPUser='',SMTPPass='',SMTPPort='587',SMTPActive='0' WHERE SMTPHost='smtp.forwardemail.net'"

    fi

fi

File="B200"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

            sudo curl -s https://rclone.org/install.sh | bash

    fi

fi

File="C105"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        C=1

    fi

fi

File="D029"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        D=1

        sudo /go/sqliterc

    fi

fi

File="E067"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        E=1
        sudo /go/vmail

    fi

fi

File="F102"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        F=1

        rm -rf /etc/opt/remi/*/php-fpm.d/gopanel.conf
        rm -rf /etc/php/*/fpm/pool.d/gopanel.conf
        rm -rf /etc/httpd/gopanel.conf
        rm -rf /etc/nginx/gopanel.conf
        rm -rf /etc/apache2/gopanel.conf


    fi

fi

File="G279"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        G=1

        sudo curl https://rclone.org/install.sh | bash

    fi

fi

File="H051"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        H=1

        sudo /go/conf
        sudo /go/config --force

    fi

fi

File="N010"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        sed -i 's|/usr/local/go/|/usr/local/goadmio/|g' /etc/opt/remi/*/php.ini
        sudo /go/vendor
        sudo /go/restart

    fi

fi

File="P049"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        if sudo test -d /usr/local/goadmio ; then

            rm -rf /var/log/gopanel
            /go/mkdir
            /go/adduser go 

        fi

    fi

fi

File="W033"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        W=1

        rm -rf /etc/cron.d/gopanel
        sudo /go/config --force
        sudo /go/conf

    fi

fi

File="Z055"
if sudo test ! -f "/usr/local/goadmio/db/upgrade/$File" ; then

    echo "$TimeStamp" | sudo tee "/usr/local/goadmio/db/upgrade/$File" >/dev/null

    if [[ ! "$@" = *"--install"* ]]; then

        Z=1
        sudo /go/connect

    fi

fi