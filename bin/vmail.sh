#!/bin/bash
shopt -s extglob

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)
HostnameDomain=$(echo "$Hostname" | cut -d. -f2-)
SMTPAuth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SMTPAuth from Config where ConfigID=1")

DomainNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "SELECT COUNT(*) from Site")

if [ "$DomainNo" -eq "0" ]; then
    echo "VMAIL: There are currently no active domains."
    exit 1
fi

if ! command -v opendmarc &>/dev/null; then
    sudo /go/installdmarc
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    if ! command -v swaks &>/dev/null; then
        sudo dnf -y install swaks
    fi
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    if ! command -v swaks &>/dev/null; then
        sudo apt -y install swaks
    fi
fi

if [[ "$Hostname" = *"."* ]]; then
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "DELETE FROM SMTP WHERE SMTPHost='$Hostname'"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SMTPHost='' WHERE SMTPHost='$Hostname'"
fi

if sudo test -f /usr/local/goadmio/include/config/smtp.php ; then
    GoSMTPPass=$(sudo grep -oP 'SMTPPass="\K[^"]+' /usr/local/goadmio/include/config/smtp.php)
    GoSMTPPass=$(doveadm pw -s sha1 -p "$GoSMTPPass" | cut -d '}' -f2)
else
    MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}')
    GoSMTPPass=$(echo -n "$MAC|$(date +%s)" | md5sum | awk '{print $1}')
    GoSMTPPass=$(doveadm pw -s sha1 -p "$GoSMTPPass" | cut -d '}' -f2)
fi

LockFile="/usr/local/goadmio/lock/vmail.lock"
if sudo test -f "$LockFile" ; then
    if [[ $(($(date +%s) - $(stat -c %Y "$LockFile" 2>/dev/null))) -le "900" ]]; then
        InstanceFile=$(<"$LockFile")
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi
echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null
trap 'sudo rm -f "$LockFile"' EXIT

sudo /go/postfwd
sudo /go/postconf
sudo /go/doveconf

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "delete from Mail where Email like '%*%'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "delete from Mail where Email not like '%@%'"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "update Mail SET Pass='Go' where Pass=''"

# ============================================================
# Headers (written once)
# ============================================================
echo "# Go SMTP Relayhost" | sudo tee /etc/postfix/vmail_relayhost >/dev/null
echo "# Go SMTP Relay (Usernames & Passwords)" | sudo tee /etc/postfix/vmail_sasl_passwd >/dev/null
echo "# Go Mail Domains" | sudo tee /etc/postfix/vmail_domains >/dev/null
echo "# Go MAIL SSL" | sudo tee /etc/postfix/vmail_ssl >/dev/null
echo "# Go Custom SMTP Relay" | sudo tee /etc/postfix/vmail_relay >/dev/null

{
    echo "# Go Mail Aliases"
    echo "goadmio@$HostnameDomain goadmio@$HostnameDomain"
} | sudo tee /etc/postfix/vmail_aliases >/dev/null

echo "# Go Mail Box" | sudo tee /etc/postfix/vmail_mailbox >/dev/null

{
    echo "# Go Mail Password"
    echo "goadmio@$HostnameDomain:$GoSMTPPass"
} | sudo tee /etc/dovecot/passwd >/dev/null

# ============================================================
# SMTP (global relay) — one query, tee -a to sasl_passwd
# ============================================================
sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/smtp.db "
    SELECT IFNULL(SMTPHost,'') || '|' || IFNULL(SMTPPort,'') || '|' || IFNULL(SMTPUser,'') || '|' || IFNULL(SMTPPass,'0') || '|' || IFNULL(SMTPStatus,'-1')
    FROM SMTP
    WHERE Active=1 ORDER BY Priority
" | while IFS='|' read -r SMTPHost SMTPPort SMTPUser SMTPPass SMTPStatus; do

    if [ "$SMTPHost" != "" ] && [ "$SMTPUser" != "" ] && [ "$SMTPPass" != "" ] && [ "$SMTPPort" != "" ]; then
        echo "[$SMTPHost]:$SMTPPort $SMTPUser:$SMTPPass" | sudo tee -a /etc/postfix/vmail_sasl_passwd >/dev/null
    fi

    if [ "$SMTPStatus" = "-1" ] && [ "$SMTPPort" = "587" ]; then
        Status=$(swaks --server "$SMTPHost" --port "$SMTPPort" -tls \
            --auth LOGIN --auth-user "$SMTPUser" \
            --auth-password "$SMTPPass" --quit-after AUTH)
        if [[ "$Status" = *"235"* ]]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "UPDATE SMTP SET SMTPStatus=1 where SMTPHost='$SMTPHost' and SMTPPort='$SMTPPort'"
        elif [[ "$Status" = *"failed"* ]]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "UPDATE SMTP SET SMTPStatus=0 where SMTPHost='$SMTPHost' and SMTPPort='$SMTPPort'"
        else
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "UPDATE SMTP SET SMTPStatus=-2 where SMTPHost='$SMTPHost' and SMTPPort='$SMTPPort'"
        fi
    fi
done

# ============================================================
# MAIL — one query, writes aliases + mailbox + dovecot passwd
# ============================================================
sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/mail.db "
    SELECT IFNULL(Email,'') || '|' || IFNULL(Pass,'') || '|' || IFNULL(ForwardTo,'') || '|' || IFNULL(Reject,'0') || '|' || IFNULL(RejectMessage,'') || '|' || IFNULL(KeepCopy,'0') || '|' || IFNULL(Domain,'') || '|' || IFNULL(DefaultAddress,'0') || '|' || IFNULL(Suspend,'0') || '|' || IFNULL(Admin,'0')
    FROM Mail
    WHERE Email!='goadmio@$HostnameDomain' ORDER BY DefaultAddress,Email
" | while IFS='|' read -r Email Pass ForwardTo Reject RejectMessage KeepCopy Domain DefaultAddress Suspend Admin; do

    if sudo test -d "/home/$Domain/mail" ; then

        if [[ "$Email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then

            User=$(echo "$Email" | cut -d '@' -f1)

            if [ "$DefaultAddress" = "1" ]; then
                echo "@$Domain $Email" | sudo tee -a /etc/postfix/vmail_aliases >/dev/null
            elif [[ "$ForwardTo" = *"@"* ]]; then
                if [ "$KeepCopy" = "1" ]; then
                    echo "$Email $Email,$ForwardTo" | sudo tee -a /etc/postfix/vmail_aliases >/dev/null
                else
                    echo "$Email $ForwardTo" | sudo tee -a /etc/postfix/vmail_aliases >/dev/null
                fi
            else
                echo "$Email $Email" | sudo tee -a /etc/postfix/vmail_aliases >/dev/null
            fi

            echo "$Email $Domain/mail/$User/" | sudo tee -a /etc/postfix/vmail_mailbox >/dev/null

            if [ "$Suspend" != "1" ]; then
                Pass=$(doveadm pw -s sha1 -p "$Pass" | cut -d '}' -f2)
                echo "$Email:$Pass" | sudo tee -a /etc/dovecot/passwd >/dev/null
            fi

        fi

    fi

done

# ============================================================
# SITE — one query, writes domains + ssl + relay + sasl + status
# ============================================================
sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/site.db "
    SELECT IFNULL(Domain,'') || '|' || IFNULL(SMTPHost,'') || '|' || IFNULL(SMTPUser,'') || '|' || IFNULL(SMTPPass,'') || '|' || IFNULL(SMTPPort,'') || '|' || IFNULL(SMTPActive,'0') || '|' || IFNULL(SMTPStatus,'-1')
    FROM Site
    WHERE SiteID>=1 ORDER BY Domain
" | while IFS='|' read -r Domain SMTPHost SMTPUser SMTPPass SMTPPort SMTPActive SMTPStatus; do

    if sudo test -d "/home/$Domain/mail" ; then

        echo "$Domain OK" | sudo tee -a /etc/postfix/vmail_domains >/dev/null

        if sudo test -d "/etc/letsencrypt/live/$Domain" ; then
            if [ "$Hostname" != "smtp.$Domain" ]; then
                echo "smtp.$Domain /etc/letsencrypt/live/$Domain/privkey.pem /etc/letsencrypt/live/$Domain/fullchain.pem" | sudo tee -a /etc/postfix/vmail_ssl >/dev/null
            fi
        fi

        if [ "$SMTPHost" != "" ] && [ "$SMTPUser" != "" ] && [ "$SMTPPass" != "" ] && [ "$SMTPPort" != "" ] && [ "$SMTPActive" = "1" ]; then

            echo "@$Domain [$SMTPHost]:$SMTPPort" | sudo tee -a /etc/postfix/vmail_relay >/dev/null
            echo "@$Domain $SMTPUser:$SMTPPass" | sudo tee -a /etc/postfix/vmail_sasl_passwd >/dev/null

            if [ "$SMTPStatus" = "-1" ] && [ "$SMTPPort" = "587" ]; then
                Status=$(swaks --server "$SMTPHost" --port "$SMTPPort" -tls \
                    --auth LOGIN --auth-user "$SMTPUser" \
                    --auth-password "$SMTPPass" --quit-after AUTH)
                if [[ "$Status" = *"235"* ]]; then
                    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SMTPStatus=1 where Domain='$Domain'"
                elif [[ "$Status" = *"failed"* ]]; then
                    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SMTPStatus=0 where Domain='$Domain'"
                else
                    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SMTPStatus=-2 where Domain='$Domain'"
                fi
            fi

        fi

        sudo chown vmail:vmail "/home/$Domain/mail"

    fi

done

# ============================================================
# Filter files
# ============================================================
sudo sqlite3 -batch /var/lib/sqlite/filter.db "SELECT '/' || Keyword || '/i REJECT ' || Description FROM Filter WHERE Type = 'Body' ORDER BY Keyword;" | sed 's/\.\*\.\*/.*/g' | sudo tee /etc/postfix/vmail_body_checks >/dev/null

{
    sudo sqlite3 -batch /var/lib/sqlite/filter.db "SELECT '/^Subject:.*' || Keyword || '/ REJECT ' || Description FROM Filter WHERE Type = 'Header' ORDER BY Keyword;" | sed 's/\.\*\.\*/.*/g'
    echo "/^Subject: (.*)/ INFO"
} | sudo tee /etc/postfix/vmail_header_checks >/dev/null

echo "/^Subject: (.*)/ INFO [Outgoing]" | sudo tee /etc/postfix/vmail_outgoing_header_checks >/dev/null

sudo /go/mail restart

sudo /usr/sbin/postfix check

sudo rm -rf "$LockFile"