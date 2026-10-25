#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

SMTPHostNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "select COUNT(*) FROM SMTP where Active=1")

if [ "$SMTPHostNo" -eq "0" ]; then

    Relayhost=""
    SMTPAuth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT SMTPAuth FROM Config WHERE ConfigID=1")

    SMTPHost="localhost"
    SMTPPort="587"

else

    Relayhost=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "SELECT '[' || SMTPHost || ']:' || SMTPPort FROM SMTP WHERE Active=1 ORDER BY Priority LIMIT 1")
    SMTPFallbackRelay=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "SELECT '[' || SMTPHost || ']:' || SMTPPort FROM SMTP WHERE Active=1 ORDER BY Priority LIMIT 1,2" | tr '\n' ' ' | sed 's/ $//')
    SMTPAuth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT SMTPAuth FROM Config WHERE ConfigID=1")

fi

PostfixVersion=$(sudo postconf -d | grep "^mail_version" | sed 's/[^0-9\.]//g')

MyNetworks=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select MyNetworks from Config")

if [ "$MyNetworks" = "" ]; then
    sudo /usr/sbin/postconf -e "mynetworks = 127.0.0.0/8 [::1]/128 $ServerIP"
else
    sudo /usr/sbin/postconf -e "mynetworks = 127.0.0.0/8 [::1]/128 $ServerIP $MyNetworks"
fi

sudo /usr/sbin/postconf -e "inet_interfaces = all"
sudo /usr/sbin/postconf -e "inet_protocols = ipv4"
sudo /usr/sbin/postconf -e "default_database_type = lmdb"
sudo /usr/sbin/postconf -e "alias_maps = lmdb:/etc/aliases"
sudo /usr/sbin/postconf -e "alias_database = \$alias_maps"
sudo /usr/sbin/postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"
sudo /usr/sbin/postconf -e "message_size_limit = 0"
sudo /usr/sbin/postconf -e "mailbox_size_limit = 0"
sudo /usr/sbin/postconf -e "virtual_mailbox_limit = 0"
sudo /usr/sbin/postconf -e "html_directory = no"
sudo /usr/sbin/postconf -e "relay_domains = *"
sudo /usr/sbin/postconf -e "virtual_alias_maps=lmdb:/etc/postfix/vmail_aliases"
sudo /usr/sbin/postconf -e "virtual_mailbox_domains=lmdb:/etc/postfix/vmail_domains"
sudo /usr/sbin/postconf -e "virtual_mailbox_maps=lmdb:/etc/postfix/vmail_mailbox"

sudo /usr/sbin/postconf -e "virtual_mailbox_base = /home"
sudo /usr/sbin/postconf -e "virtual_minimum_uid = 5000"
sudo /usr/sbin/postconf -e "virtual_uid_maps = static:5000"
sudo /usr/sbin/postconf -e "virtual_gid_maps = static:5000"
sudo /usr/sbin/postconf -e "smtpd_sasl_auth_enable = yes"
sudo /usr/sbin/postconf -e "smtpd_sasl_type = dovecot"
sudo /usr/sbin/postconf -e "smtpd_sasl_security_options = noanonymous"
sudo /usr/sbin/postconf -e "smtpd_sasl_tls_security_options = \$smtpd_sasl_security_options"
sudo /usr/sbin/postconf -e "smtpd_sasl_local_domain = \$mydomain"
sudo /usr/sbin/postconf -e "smtpd_tls_security_level=may"
sudo /usr/sbin/postconf -e "smtp_tls_note_starttls_offer = yes"
sudo /usr/sbin/postconf -e "smtp_tls_loglevel = 1"
sudo /usr/sbin/postconf -e 'smtpd_tls_protocols = !SSLv2, !SSLv3 !TLSv1'
sudo /usr/sbin/postconf -e "smtpd_sasl_authenticated_header = yes"
sudo /usr/sbin/postconf -e "broken_sasl_auth_clients = yes"
sudo /usr/sbin/postconf -e "smtpd_recipient_restrictions = check_policy_service inet:127.0.0.1:10040, check_recipient_access lmdb:/etc/postfix/custom_replies, permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, check_policy_service unix:private/policyd-spf"
sudo /usr/sbin/postconf -e "smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"
sudo /usr/sbin/postconf -e "policyd-spf_time_limit = 3600"

sudo /usr/sbin/postconf -e "smtp_sasl_password_maps = lmdb:/etc/postfix/vmail_sasl_passwd"
sudo /usr/sbin/postconf -e "sender_dependent_relayhost_maps = lmdb:/etc/postfix/vmail_relay"

sudo /usr/sbin/postconf -e "smtp_tls_security_level = encrypt"
sudo /usr/sbin/postconf -e "smtp_sender_dependent_authentication = yes"

# Prevent SPAM
sudo /usr/sbin/postconf -e "smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unknown_sender_domain, reject_sender_login_mismatch,reject_unlisted_sender,reject_unauth_destination"

sudo /usr/sbin/postconf -e "body_checks = pcre:/etc/postfix/vmail_body_checks"
sudo /usr/sbin/postconf -e "header_checks = pcre:/etc/postfix/vmail_header_checks"
sudo /usr/sbin/postconf -e "smtp_header_checks = pcre:/etc/postfix/vmail_outgoing_header_checks"

sudo /usr/sbin/postconf -e "compatibility_level = 3.6"

ServerLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ServerLimit from Config where ConfigID=1")
if [ "$ServerLimit" -ne 0 ]; then

    # Limit Send Emails Per Day
    sudo /usr/sbin/postconf -e "anvil_rate_time_unit = 86400"
    sudo /usr/sbin/postconf -e "smtpd_client_message_rate_limit = $ServerLimit"
    sudo /usr/sbin/postconf -e "smtpd_client_recipient_rate_limit = $ServerLimit"

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo /usr/sbin/postconf -e "smtpd_sasl_path = /var/run/dovecot/auth-client"
    sudo /usr/sbin/postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo /usr/sbin/postconf -e "smtpd_sasl_path = private/auth_dovecot"
    sudo /usr/sbin/postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"

fi

# Enable TLS
if sudo test -f "/etc/letsencrypt/live/$Hostname/fullchain.pem" ; then

    sudo /usr/sbin/postconf -e "smtp_use_tls=yes"
    sudo /usr/sbin/postconf -e "smtpd_use_tls=yes"

    sudo /usr/sbin/postconf -e "smtpd_tls_chain_files = /etc/letsencrypt/live/$Hostname/privkey.pem,/etc/letsencrypt/live/$Hostname/fullchain.pem"
    sudo /usr/sbin/postconf -e "tls_server_sni_maps = lmdb:/etc/postfix/vmail_ssl"

fi

# Connect to External SMTP
if [[ "$Relayhost" = *"."* ]]; then

    # Public SMTP Relay (External SMTP)
    sudo /usr/sbin/postconf -e "relayhost = $Relayhost"

    if [[ "$SMTPFallbackRelay" = *"."* ]]; then
        sudo /usr/sbin/postconf -e "smtp_fallback_relay = $SMTPFallbackRelay"
    fi

    sudo /usr/sbin/postconf -e "smtp_sasl_auth_enable = $SMTPAuth"
    sudo /usr/sbin/postconf -e "smtp_sasl_security_options = noanonymous"

    # Add this to remote server (main.cf) when 95.216.236.66 current server ip
    # mynetworks = 127.0.0.0/8 95.216.236.66

else

    # Public SMTP Relay (No SMTP Relay)
    sudo /usr/sbin/postconf -e "relayhost ="
    sudo /usr/sbin/postconf -e "smtp_sasl_auth_enable = $SMTPAuth"
    sudo /usr/sbin/postconf -e "smtp_sasl_security_options = noanonymous"

fi

# Enable DKIM (8891)
sudo /usr/sbin/postconf -e "milter_default_action = accept"
sudo /usr/sbin/postconf -e "smtpd_milters = inet:127.0.0.1:8891"
sudo /usr/sbin/postconf -e "non_smtpd_milters = \$smtpd_milters"

# Enable DKIM (8891) & DMARC (8893)
# /usr/sbin/postconf -e "smtpd_milters = inet:127.0.0.1:8891,inet:127.0.0.1:8893"