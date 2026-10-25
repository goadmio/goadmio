#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

DomainNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "SELECT COUNT(*) from Site")

if [[ ! $@ = *"--skip"* ]]; then

    nc -w 3 -vv -z gmail-smtp-in.l.google.com 25 >/usr/local/goadmio/tmp/checkmail.db 2>&1
    if grep -q "unreachable" /usr/local/goadmio/tmp/checkmail.db || grep -q "Connection timed out" /usr/local/goadmio/tmp/checkmail.db; then

        ServerIP=$(curl -s -4 checkip.amazonaws.com)

        Whois=$(whois $ServerIP)
        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}')

        if [ "$Organization" = "" ]; then
            Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}')
        fi

        Organization=$(echo $Organization | sed -e 's/^[ \t]*//')

        echo "Your ISP $Organization blocking SMTP Port 25"
        exit 1

    fi

fi

if [[ $@ = *"--force"* ]]; then
    # Make SMTP & IMAP Default Configuration
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "update Config set IMAPHostname='localhost',IMAPPort='143',IMAPSecure='None',IMAPShortLogin='Off' where ConfigID=1"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "update Config set SMTPHostname='',SMTPPort='587',SMTPUsername='',SMTPPassword='' where ConfigID=1"
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

ProgressBar "Setting Up and Configuring a Linux Mail Server"

Hostname=$(</etc/hostname)

# Create user & group used for virtual mailboxes
sudo userdel -rf vmail >/dev/null 2>&1
sudo groupdel vmail >/dev/null 2>&1
sudo groupadd -g 5000 vmail
sudo useradd -g vmail -u 5000 -d /var/vmail -m -s /usr/sbin/nologin vmail

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    # remove chroot to allow ssl folder to access by postfix
    echo "Removing BIND-CHROOT..."
    sudo dnf -y remove bind-chroot &>/dev/null

    echo "Removing POSTFIX..."
    sudo dnf -y remove postfix &>/dev/null

    echo "Removing POSTFWD..."
    sudo dnf -y remove postfwd &>/dev/null

    echo "Removing DOVECOT..."
    sudo dnf -y remove dovecot &>/dev/null

    echo "Removing DOVECOT-PIGEONHOLE..."
    sudo dnf -y remove dovecot-pigeonhole &>/dev/null

    echo "Removing EXIM..."
    sudo dnf -y remove exim &>/dev/null

    echo "Removing SENDMAIL..."
    sudo dnf -y remove sendmail &>/dev/null

    echo "Removing CYRUS-SASL..."
    sudo dnf -y remove cyrus-sasl &>/dev/null
    echo "Removing CYRUS-SASL-DEVEL..."
    sudo dnf -y remove cyrus-sasl-devel &>/dev/null
    echo "Removing CYRUS-SASL-GSSAPI..."
    sudo dnf -y remove cyrus-sasl-gssapi &>/dev/null
    sudo dnf -y remove cyrus-sasl-md5 &>/dev/null
    echo "Removing CYRUS-SASL-PLAIN..."
    sudo dnf -y remove cyrus-sasl-plain &>/dev/null

    ProgressBar "Installing POSTFIX"
    sudo dnf -y install postfix
    sudo dnf -y install postfix-pcre
    sudo dnf -y install postfix-lmdb

    ProgressBar "Installing POSTFWD..."
    sudo dnf -y install postfwd

    ProgressBar "Installing DOVECOT..."
    sudo dnf -y install dovecot
    sudo dnf -y install dovecot-pigeonhole

    ProgressBar "Installing SASL..."
    echo "Installing CYRUS-SASL..."
    sudo dnf -y install cyrus-sasl
    echo "Installing CYRUS-SASL-DEVEL..."
    sudo dnf -y install cyrus-sasl-devel
    echo "Installing CYRUS-SASL-GSSAPI..."
    sudo dnf -y install cyrus-sasl-gssapi
    echo "Installing CYRUS-SASL-MD5..."
    sudo dnf -y install cyrus-sasl-md5
    echo "Installing CYRUS-SASL-PLAIN..."
    sudo dnf -y install cyrus-sasl-plain

    echo "debugger_command =" | sudo tee /etc/postfix/main.cf >/dev/null
    echo "	PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin" | sudo tee -a /etc/postfix/main.cf >/dev/null
    echo "	ddd \$daemon_directory/\$process_name \$process_id & sleep 5" | sudo tee -a /etc/postfix/main.cf >/dev/null

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    DEBIAN_FRONTEND='noninteractive' apt -y purge postfix &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge postfwd &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge daemon &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge dovecot-core dovecot-pop3d dovecot-imapd &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge dovecot-sieve dovecot-managesieved &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge dovecot-lmtpd &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge sasl2-bin &>/dev/null

    ProgressBar "Installing Postfix"
    debconf-set-selections <<<"postfix postfix/mailname string $Hostname"
    debconf-set-selections <<<"postfix postfix/main_mailer_type string 'No configuration'"
    DEBIAN_FRONTEND='noninteractive' apt -y install postfix
    DEBIAN_FRONTEND='noninteractive' apt -y install postfix-pcre
    DEBIAN_FRONTEND='noninteractive' apt -y install postfix-lmdb

    ProgressBar "Installing Postfwd"
    DEBIAN_FRONTEND='noninteractive' apt -y install postfwd
    DEBIAN_FRONTEND='noninteractive' apt -y install daemon

    # Run Postfwd on port 10040 (Debian & Ubunto Only)
    echo "STARTUP=1" | sudo tee /etc/default/postfwd >/dev/null
    echo "CONF=/etc/postfwd.cf" | sudo tee -a /etc/default/postfwd >/dev/null
    echo "INET=127.0.0.1" | sudo tee -a /etc/default/postfwd >/dev/null
    echo "PORT=10040" | sudo tee -a /etc/default/postfwd >/dev/null
    echo "RUNAS=\"postfw\"" | sudo tee -a /etc/default/postfwd >/dev/null
    echo "ARGS=\"--summary=600 --cache=600 --cache-rdomain-only --cache-no-size\"" | sudo tee -a /etc/default/postfwd >/dev/null

    ProgressBar "Installing Dovecot"
    DEBIAN_FRONTEND='noninteractive' apt -y install dovecot-core dovecot-pop3d dovecot-imapd
    DEBIAN_FRONTEND='noninteractive' apt -y install dovecot-sieve dovecot-managesieved
    DEBIAN_FRONTEND='noninteractive' apt -y install dovecot-lmtpd

    ProgressBar "Installing SASL"
    DEBIAN_FRONTEND='noninteractive' apt -y install sasl2-bin

fi

echo "webmaster@$Hostname:kX6vXihRANf/w9d6EMgXQJUOGrI=" | sudo tee /etc/dovecot/passwd >/dev/null
sudo chown root: /etc/dovecot/passwd
sudo chmod 600 /etc/dovecot/passwd

sudo rm -rf /home/vmail

# Add postfix user to opendkim group.
sudo gpasswd -a postfix opendkim

# Add user postfix to group opendmarc.
sudo gpasswd -a postfix opendmarc

if sudo test -f /usr/local/goadmio/junk/.sieve ; then
    sudo sievec /usr/local/goadmio/junk/.sieve
fi

if sudo test -f /usr/local/goadmio/junk/.ip ; then
    sudo sievec /usr/local/goadmio/junk/.ip
fi

echo "MAILSSL..."
sudo /go/mailssl
echo "POSTCONF..."
sudo /go/postconf
echo "DOVECONF..."
sudo /go/doveconf
echo "Installing SPF..."
sudo /go/installspf
echo "DKIM..."
sudo /go/installdkim
echo "Installing DMARC..."
sudo /go/installdmarc

if [ "$DomainNo" -ge "1" ]; then

    echo "TROUBLESHOOT..."
    sudo /go/troubleshoot

    echo "AUTODISCOVER..."
    sudo /go/autodiscover

    sudo /go/firewall

    sudo /go/checkmx

    sudo /go/vmail

fi

sudo systemctl enable postfix
sudo systemctl enable postfwd
sudo systemctl enable dovecot
sudo systemctl enable saslauthd
sudo systemctl enable opendkim
sudo systemctl enable opendmarc
sudo systemctl enable rsyslog