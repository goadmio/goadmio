#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

if ! command -v fail2ban-client &>/dev/null; then

    ProgressBar "Installing FAIL2BAN"

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo dnf -y install fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl restart fail2ban

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo apt -y install fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl restart fail2ban

    fi

fi

if [ "$1" = "clear" ]; then

    fail2ban-client unban --all
    sudo systemctl restart fail2ban
    exit 1

fi

if sudo test -f /var/go/etc/white ; then
    IgnoreIP=$(printf 'ignoreip = 127.0.0.1/8 ::1 %s\n' "$(sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+)\.\*$/\1.0\/24/; s/^([0-9]+\.[0-9]+)\.\*$/\1.0.0\/16/; s/^([0-9]+)\.\*$/\1.0.0.0\/8/' /var/go/etc/white | paste -sd' ' -)")
else
    IgnoreIP="ignoreip = 127.0.0.1/8 ::1"
fi

# SSH
if sudo test -d "/etc/fail2ban/jail.d" ; then

    echo "[sshd]" | sudo tee /etc/fail2ban/jail.d/ssh.conf >/dev/null
    echo "enabled  = true" | sudo tee -a /etc/fail2ban/jail.d/ssh.conf >/dev/null
    echo "$IgnoreIP" | sudo tee -a /etc/fail2ban/jail.d/ssh.conf >/dev/null
    echo "maxretry = 30" | sudo tee -a /etc/fail2ban/jail.d/ssh.conf >/dev/null
    echo "findtime = 3600" | sudo tee -a /etc/fail2ban/jail.d/ssh.conf >/dev/null
    echo "bantime  = 86400" | sudo tee -a /etc/fail2ban/jail.d/ssh.conf >/dev/null

    sudo systemctl restart fail2ban

fi

# FTP
if sudo test -d "/etc/fail2ban/jail.d" ; then

    echo "[vsftpd]" | sudo tee /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "enabled  = true" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "$IgnoreIP" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "port     = ftp,ftp-data,ftps,ftps-data" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "filter   = vsftpd" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "logpath  = /var/log/vsftpd.log" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "maxretry = 30" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null
    echo "bantime  = 1h" | sudo tee -a /etc/fail2ban/jail.d/ftp.conf >/dev/null

fi

# SMTP
if sudo test -d "/etc/fail2ban/jail.d" ; then

    echo "[postfix-sasl]" | sudo tee /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "enabled  = true" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "$IgnoreIP" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "port     = smtp,ssmtp,submission,465,587" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "logpath  = /var/log/maillog" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "maxretry = 5" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "findtime = 3600" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null
    echo "bantime  = 1h" | sudo tee -a /etc/fail2ban/jail.d/smtp.conf >/dev/null

fi

# Dovecot
if sudo test -d "/etc/fail2ban/jail.d" ; then

    echo "[dovecot]" | sudo tee /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "enabled  = true" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "$IgnoreIP" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "port     = pop3,pop3s,imap,imaps,submission,465,sieve" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "logpath  = /var/log/maillog" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "maxretry = 5" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "findtime = 3600" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null
    echo "bantime  = 1h" | sudo tee -a /etc/fail2ban/jail.d/dovecot.conf >/dev/null

fi

# Check for Configuration Errors
# sudo fail2ban-client -t

sudo fail2ban-client unban --all

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
