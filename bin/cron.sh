#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="$1"

SMTPRelayNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "SELECT COUNT(*) from SMTP")
BrevoSMTPNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "SELECT COUNT(*) FROM SMTP WHERE Active=1 AND SMTPHost like '%brevo.com%' AND SMTPPort='587'")

if [[ "$Domain" = *"."* ]]; then

    if sudo test -d "/home/$Domain/www" ; then

        Email=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Email from Site where Domain='$Domain'")

        CronFile="${Domain//./_}"

        if [ "$SMTPRelayNo" -ge "1" ]; then
            # Protect Brevo SMTP Relay Email Credits
            CronMailto="MAILTO=\"\""
        else
            CronMailto="MAILTO=\"$Email\""
        fi

        {
            echo "$CronMailto"

            sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/cron.db "
                SELECT IFNULL(Minute, '*') || '|' || IFNULL(Hour, '*') || '|' || IFNULL(DayMonth, '*') || '|' || IFNULL(Month, '*') || '|' || IFNULL(DayWeek, '*') || '|' || IFNULL(Command, '') || '|' || IFNULL(Username, '')
                FROM Cron
                WHERE Domain='$Domain' AND Username!='' AND Active=1
            " | while IFS='|' read -r Minute Hour DayMonth Month DayWeek Command Username; do

                CronSchedule="$Minute $Hour $DayMonth $Month $DayWeek"

                if [[ "$CronSchedule" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
                    echo "$CronSchedule $Username /usr/bin/$Command"
                fi

            done
        } | sudo tee "/etc/cron.d/$CronFile" >/dev/null

        sudo /go/cron restart

    else

        echo "Domain $Domain does not exist."

    fi

    exit 1

fi

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
CronEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CronEmail from Config")

Action="$1"

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)
Hostname=$(</etc/hostname)

if [ "$Action" = "restart" ] || [ "$Action" = "stop" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo systemctl "$Action" crond

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo systemctl "$Action" cron

    fi

    exit 1

fi

SSHUsername=$(sudo grep -oP 'SSHUsername="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Action" = "-e" ]; then

    nano /etc/cron.d/go
    exit 1

fi

if sudo test -f "/etc/hostname" ; then
    Hostname=$(</etc/hostname)
fi

ServerNo=$(printf '%s' "$MainDomain" | tr -d 'abcdefghijklmnopqrstuvwxyz.')
if [ "$ServerNo" = "" ]; then
    ServerNo=1
fi

# Fixed Random number from 0-23
H=$(sudo /usr/sbin/ifconfig | awk '/ether/ {gsub(":","",$2); dec = sprintf("%d", "0x"$2); print dec % 24}')

# Fixed Random number from 12-23
T=$(sudo /usr/sbin/ifconfig | awk '/ether/ {gsub(":","",$2); dec = sprintf("%d", "0x"$2); print (dec % 13) + 11}')

# Fixed Random number from 2-7
B=$(sudo /usr/sbin/ifconfig | awk '/ether/ {gsub(":","",$2); dec = sprintf("%d", "0x"$2); print (dec % 6) + 2}')

# Fixed Random number from 0-59
M=$(sudo /usr/sbin/ifconfig | awk '/ether/ {gsub(":","",$2); dec = sprintf("%d", "0x"$2); print dec % 60}')

if sudo test -f /usr/local/goadmio/minio/minio.conf ; then

    if grep -q ":443 " /usr/local/goadmio/minio/minio.conf; then

        if [ "$SMTPRelayNo" -ge "1" ]; then
            # Protect Brevo SMTP Relay Email Credits
            CronMailto="MAILTO=\"\""
        else
            CronMailto="MAILTO=\"$CronEmail\""
        fi

        {
            echo "$CronMailto"

            if [[ "$Hostname" = *"."* ]]; then
                echo "MAILFROM=\"goadmio@$Hostname\""
            fi

            echo "0 0 1,15 * * root /go/miniossl"
            echo "0 18 * * * root /go/checkssl"
        } | sudo tee /etc/cron.d/go >/dev/null

        exit 1

    fi

fi

if [ "$SMTPRelayNo" -ge "1" ]; then
    # Protect Brevo SMTP Relay Email Credits
    CronMailto="MAILTO=\"\""
else
    CronMailto="MAILTO=\"$CronEmail\""
fi

# ============================================================
# Build /etc/cron.d/go in one pass
# ============================================================
{
    echo "$CronMailto"

    if [[ "$Hostname" = *"."* ]]; then
        echo "MAILFROM=\"goadmio@$Hostname\""
    fi

    if sudo test -f /root/.config/rclone/rclone.conf ; then
        if sudo test -f "/var/go/etc/storage"  || grep -q "\[storage\]" /root/.config/rclone/rclone.conf; then
            echo "@reboot root /go/storage"
        fi
    fi

    echo "0 * * * * root /go/hourly > /var/log/go/cron/hourly.log 2>&1"
    echo "*/20 * * * * root /go/20min > /var/log/go/cron/20min.log 2>&1"

    if [ "$BrevoSMTPNo" -ge "1" ]; then
        echo "0 8,10,12,14,16,18,20,22 root /go/brevo check"
    fi

    echo "55 23 * * * root /go/bandwidth"
    echo "56 23 * * * root /go/outgoing"
    echo "57 23 * * * root /go/incoming"

    echo "$M $T */2 * * root /go/update"

    if sudo test -f "/var/go/etc/maria.conf" ; then

        MariaCron=$(sudo grep -E "^Cron*=*" /var/go/etc/maria.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        echo "$M 4 * * * root /go/maria refresh > /var/log/go/cron/maria.log 2>&1"

        if [[ "$MariaCron" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
            echo "$MariaCron root /go/maria > /var/log/go/cron/maria.log 2>&1"
        else
            echo "$M 12,16,20 * * * root /go/maria > /var/log/go/cron/maria.log 2>&1"
        fi

    fi

    if sudo test -f "/var/go/etc/backup.conf" ; then

        BackupCron=$(sudo grep -E "^Cron*=*" /var/go/etc/backup.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        if [[ "$BackupCron" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
            echo "$BackupCron root /go/backup > /var/log/go/cron/backup.log 2>&1"
        fi

    fi

    if sudo test -f "/var/go/etc/secondary.conf" ; then

        SecondaryCron=$(sudo grep -E "^Cron*=*" /var/go/etc/secondary.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        if [[ "$SecondaryCron" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
            echo "$SecondaryCron root /go/backup secondary > /var/log/go/cron/secondary.log 2>&1"
        fi

    fi

    if sudo test -f "/var/go/etc/tertiary.conf" ; then

        TertiaryCron=$(sudo grep -E "^Cron*=*" /var/go/etc/tertiary.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        if [[ "$TertiaryCron" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
            echo "$TertiaryCron root /go/backup tertiary > /var/log/go/cron/tertiary.log 2>&1"
        fi

    fi

    if sudo test -f "/var/go/etc/snapshot.conf" ; then

        SnapshotCron=$(sudo grep -E "^Cron*=*" /var/go/etc/snapshot.conf | cut -d'=' -f2 | tr -d "\"';" | xargs echo -n)

        if [[ "$SnapshotCron" =~ ^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$ ]]; then
            echo "$SnapshotCron root /go/snapshot > /var/log/go/cron/snapshot.log 2>&1"
        fi

    fi

    # Under Attack Mode
    echo "15,30,45 * * * * root /go/iptop underattack"
    echo "5,35 * * * * root /go/usertop > /var/log/go/cron/usertop.log 2>&1"
    echo "20,50 * * * * root /go/mysqltop > /var/log/go/cron/mysqltop.log 2>&1"

    if sudo test -f "/var/go/etc/uptime" ; then
        echo "*/10 * * * * root /go/uptime"
    fi

    if sudo test -d "/home/crmrealty.net/www" ; then

        echo "*/5 * * * * root curl -s -o /dev/null https://www.crmrealty.net/module/crm/theme/default/iframe/rotation.php"
        echo "*/5 * * * * root curl -s -o /dev/null https://crmrealty.net/api/twilio/call.php"
        echo "*/1 * * * * root /go/wa"
    fi

    if sudo test -f "/var/go/etc/wa" ; then
        echo "*/1 * * * * root /go/wa"
    fi

    if sudo test -d "/usr/local/goadmio/whatsapp" ; then
        echo "*/3 * * * * root /go/whatsapp"
    fi
} | sudo tee /etc/cron.d/go >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo systemctl restart crond

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo systemctl restart cron

fi