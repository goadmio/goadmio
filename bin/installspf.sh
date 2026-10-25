#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    echo "Installing SPF"
    sudo dnf -y install pypolicyd-spf
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    echo "Installing SPF"
    sudo apt -y install postfix-policyd-spf-python
fi

# Because the service can't be run by the 'root' or 'postfix' user, we need to create a new user, called 'policyd-spf':
useradd -c "SPF Policy Server for Postfix" -d /etc/python-policyd-spf -s "/sbin/nologin" policyd-spf

echo "# Allow SMTP Port 26" | sudo tee -a /etc/postfix/master.cf >/dev/null
sudo sed -i "/^26 .*/d" /etc/postfix/master.cf
echo "26        inet  n       -       n       -       -       smtpd" | sudo tee -a /etc/postfix/master.cf >/dev/null

echo "# Allow SMTP Port 587" | sudo tee -a /etc/postfix/master.cf >/dev/null
echo -e "submission inet n       -       n       -       -       smtpd\n  -o syslog_name=postfix\/submission\n  -o smtpd_tls_security_level=may\n  -o smtpd_sasl_auth_enable=yes" | sudo tee -a /etc/postfix/master.cf >/dev/null

echo "# Allow SMTP Port 465" | sudo tee -a /etc/postfix/master.cf >/dev/null
echo -e "smtps     inet  n       -       n       -       -       smtpd\n  -o syslog_name=postfix\/smtps\n  -o smtpd_tls_wrappermode=yes\n  -o smtpd_sasl_auth_enable=yes" | sudo tee -a /etc/postfix/master.cf >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    echo "# To Add SPF To Receive Header Message" | sudo tee -a /etc/postfix/master.cf >/dev/null
    echo -e "policyd-spf    unix    -    n    n    -    0\n  spawn user=policyd-spf argv=/usr/libexec/postfix/policyd-spf" | sudo tee -a /etc/postfix/master.cf >/dev/null
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    echo "# To Add SPF To Receive Header Message" | sudo tee -a /etc/postfix/master.cf >/dev/null
    echo -e "policyd-spf  unix  -       n       n       -       0       spawn\n    user=policyd-spf argv=/usr/bin/policyd-spf" | sudo tee -a /etc/postfix/master.cf >/dev/null
fi
