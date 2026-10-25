#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/doveconf "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

Hostname=$(</etc/hostname)

Junk=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select Junk from Config")

DovecotVersion=$(dovecot --version | awk {' print $1 '} | cut -d'-' -f1)

# ============================================================
# Build /etc/dovecot/dovecot.conf in one pass
# ============================================================
{
    if [[ "$DovecotVersion" = "2.4"* ]]; then

        echo "dovecot_config_version = $DovecotVersion"
        echo "dovecot_storage_version = $DovecotVersion"
        echo "listen = *"

    else

        echo "listen = *"

    fi

    echo "ssl = yes"
    echo ""

    if sudo test -f "/etc/letsencrypt/live/$Hostname/fullchain.pem" ; then

        if [[ "$DovecotVersion" = "2.4"* ]]; then

            # Default Server IMAPS (993)
            echo "ssl_server_cert_file = /etc/letsencrypt/live/$Hostname/fullchain.pem"
            echo "ssl_server_key_file = /etc/letsencrypt/live/$Hostname/privkey.pem"
            echo ""

        else

            # Default Server IMAPS (993)
            echo "ssl_cert = </etc/letsencrypt/live/$Hostname/fullchain.pem"
            echo "ssl_key = </etc/letsencrypt/live/$Hostname/privkey.pem"
            echo ""

        fi

        # MULTI Domains IMAPS (993)
        cd /home || exit
        for Domain in *; do

            if sudo test -f "/etc/letsencrypt/live/$Domain/fullchain.pem"  && sudo test -f "/etc/letsencrypt/live/$Domain/privkey.pem" ; then

                if [ "$Hostname" != "imap.$Domain" ]; then

                    echo "local_name imap.$Domain {"
                    echo "ssl_cert = </etc/letsencrypt/live/$Domain/fullchain.pem"
                    echo "ssl_key = </etc/letsencrypt/live/$Domain/privkey.pem"
                    echo "}"
                    echo ""

                fi

            fi

        done

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set PostfixSMTPPort='465' where ConfigID=1"

    else

        if [[ "$DovecotVersion" = "2.4"* ]]; then

            # Default Server IMAPS (993)
            echo "ssl_server_cert_file = /etc/postfix/ssl/smtpd.crt"
            echo "ssl_server_key_file = /etc/postfix/ssl/smtpd.key"
            echo ""

        else

            # Default Server IMAPS (993)
            echo "ssl_cert = </etc/postfix/ssl/smtpd.crt"
            echo "ssl_key = </etc/postfix/ssl/smtpd.key"
            echo ""

        fi

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set PostfixSMTPPort='25' where ConfigID=1"

    fi

    echo "log_path = /var/log/dovecot.log"

    if [[ "$DovecotVersion" = "2.4"* ]]; then

        echo ""
        echo "mail_home = /home/%{user | domain}/mail/%{user | username}"
        echo "mail_uid = vmail"
        echo "mail_gid = vmail"

        echo ""
        echo "protocols {"
        echo "    imap   = yes"
        echo "    pop3   = yes"
        echo "    lmtp   = yes"
        echo "    sieve  = yes          # actually enables ManageSieve"
        echo "}"
        echo ""

    else

        echo "disable_plaintext_auth = no"
        echo "mail_location = maildir:/home/%d/mail/%n"

        echo "protocols = imap pop3 lmtp sieve"

    fi

    echo "auth_mechanisms = plain login"
    echo "mail_access_groups = vmail"
    echo "default_login_user = vmail"
    echo "first_valid_uid = 5000"
    echo "first_valid_gid = 5000"

    if [[ "$DovecotVersion" = "2.4"* ]]; then

        echo "userdb static {"
        echo "    driver = static"
        echo "    fields {"
        echo "        uid = 5000"
        echo "        gid = 5000"
        echo "        home = /home/%{user | domain}/mail/%{user | username}"
        echo "    }"
        echo "    allow_all_users = yes"
        echo "}"
        echo ""

        echo "passdb passwd-file {"
        echo "    default_password_scheme = SHA1"
        echo "    auth_username_format = %{user}"
        echo "    passwd_file_path = /etc/dovecot/passwd"
        echo "}"
        echo ""

        echo "protocol lmtp {"
        echo "    postmaster_address = postmaster@domainname   # required on my debian"
        echo "    mail_plugins {"
        echo "    sieve = yes"
        echo "    }"
        echo "}"

    else

        echo "userdb {"
        echo "    driver = static"
        echo "    args = uid=5000 gid=5000 home=/home/%d/mail/%n allow_all_users=yes"
        echo "}"
        echo ""

        echo "passdb {"
        echo "    driver = passwd-file"
        echo "    args = scheme=SHA1 /etc/dovecot/passwd"
        echo "}"
        echo ""

        echo "protocol lmtp {"
        echo "    mail_fsync = optimized"
        echo "    mail_plugins = \$mail_plugins sieve"
        echo "}"
        echo ""

    fi

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        echo "service auth {"
        echo "   unix_listener auth-client {"
        echo "   group = postfix"
        echo "   mode = 0660"
        echo "   user = postfix"
        echo "   }"
        echo "   unix_listener auth-master {"
        echo "   mode = 0600"
        echo "   user = vmail"
        echo "   }"
        echo "user = root"
        echo "}"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        echo "service auth {"
        echo "   unix_listener /var/spool/postfix/private/auth_dovecot {"
        echo "   group = postfix"
        echo "   mode = 0660"
        echo "   user = postfix"
        echo "   }"
        echo "   unix_listener auth-master {"
        echo "   mode = 0600"
        echo "   user = vmail"
        echo "   }"
        echo "user = root"
        echo "}"

    fi

    echo "service imap-login {"
    echo "    process_min_avail = 1"
    echo "    user = vmail"
    echo "}"
    echo ""

    echo "# SPAM Filter"
    echo "protocol lda {"
    echo "    mail_plugins = \$mail_plugins sieve"
    echo "}"
    echo ""

    echo "service lmtp {"
    echo "    unix_listener /var/spool/postfix/private/dovecot-lmtp {"
    echo "    group = postfix"
    echo "    mode = 0600"
    echo "    user = postfix"
    echo "    }"
    echo "    client_limit = 1"
    echo "}"
    echo ""

    echo "service managesieve-login {"
    echo "    inet_listener sieve {"
    echo "    port = 4190"
    echo "    }"
    echo "}"
    echo ""

    if [[ "$DovecotVersion" = "2.4"* ]]; then

        echo "sieve_script personal {"
        echo "driver = file"
        echo "path = ~/.sieve"
        echo "}"
        echo ""

        if [ "$Junk" -eq "1" ]; then

            if sudo test -f /usr/local/goadmio/junk/.sieve ; then

                echo "sieve_script default {"
                echo "driver = file"
                echo "path = /usr/local/goadmio/junk/.sieve"
                echo "}"
                echo ""

            fi

            if sudo test -f /usr/local/goadmio/junk/.ip ; then

                echo "sieve_script ip {"
                echo "sieve_max_script_size = 0"
                echo "driver = file"
                echo "type = after"
                echo "path = /usr/local/goadmio/junk/.ip"
                echo "}"
                echo ""

            fi

        fi

    else

        echo "plugin {"
        echo "    sieve_max_script_size = 0"
        echo "    sieve = ~/.sieve"

        if [ "$Junk" -eq "1" ]; then

            if sudo test -f /usr/local/goadmio/junk/.ip  && sudo test -f /usr/local/goadmio/junk/.sieve ; then

                # Enable Junk Filter
                echo "    sieve_global_path = /usr/local/goadmio/junk/.sieve"
                echo "    sieve_after = /usr/local/goadmio/junk/.ip"

            fi

        fi

        echo "}"

    fi
} | sudo tee /etc/dovecot/dovecot.conf >/dev/null