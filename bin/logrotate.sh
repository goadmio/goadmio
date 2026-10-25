#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" = "1" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set ApacheLogRotate='1'"

    # Apache/RHEL
    if sudo test -f /etc/logrotate.d/httpd ; then

        sudo cat >/etc/logrotate.d/httpd <<'EOF'
# Note that logs are not compressed unless "compress" is configured,
# which can be done either here or globally in /etc/logrotate.conf.
/var/log/httpd/*log {
    daily
    rotate 7
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
    endscript
}
EOF

    fi

    # Apache/Debian
    if sudo test -f /etc/logrotate.d/apache2 ; then
        sudo cat >/etc/logrotate.d/apache2 <<'EOF'
# Note that logs are not compressed unless "compress" is configured,
# which can be done either here or globally in /etc/logrotate.conf.
/var/log/apache2/*log {
    daily
    rotate 7
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/apache2.pid ; then
            sudo /usr/sbin/apachectl graceful > /dev/null 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

    # Nginx - RHEL/CentOS/Fedora
    if sudo test -f /etc/logrotate.d/nginx ; then
        sudo cat >/etc/logrotate.d/nginx <<'EOF'
/var/log/nginx/*log {
    daily
    rotate 7
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/nginx.pid ; then
            /bin/kill -USR1 `cat /var/run/nginx.pid` 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

    # Nginx - Debian/Ubuntu (alternative path)
    if sudo test -f /etc/logrotate.d/nginx ; then
        sudo cat >/etc/logrotate.d/nginx <<'EOF'
/var/log/nginx/*.log {
    daily
    rotate 7
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/nginx.pid ; then
            sudo /usr/sbin/nginx -s reopen 2>/dev/null || true
        else
            /bin/kill -USR1 `cat /var/run/nginx.pid` 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

else

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config set ApacheLogRotate='7'"

    # Apache/RHEL
    if sudo test -f /etc/logrotate.d/httpd ; then

        sudo cat >/etc/logrotate.d/httpd <<'EOF'
# Note that logs are not compressed unless "compress" is configured,
# which can be done either here or globally in /etc/logrotate.conf.
/var/log/httpd/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
    endscript
}
EOF

    fi

    # Apache/Debian
    if sudo test -f /etc/logrotate.d/apache2 ; then
        sudo cat >/etc/logrotate.d/apache2 <<'EOF'
# Note that logs are not compressed unless "compress" is configured,
# which can be done either here or globally in /etc/logrotate.conf.
/var/log/apache2/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/apache2.pid ; then
            sudo /usr/sbin/apachectl graceful > /dev/null 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

    # Nginx - RHEL/CentOS/Fedora
    if sudo test -f /etc/logrotate.d/nginx ; then
        sudo cat >/etc/logrotate.d/nginx <<'EOF'
/var/log/nginx/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/nginx.pid ; then
            /bin/kill -USR1 `cat /var/run/nginx.pid` 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

    # Nginx - Debian/Ubuntu (alternative path)
    if sudo test -f /etc/logrotate.d/nginx ; then
        sudo cat >/etc/logrotate.d/nginx <<'EOF'
/var/log/nginx/*.log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        if sudo test -f /var/run/nginx.pid ; then
            sudo /usr/sbin/nginx -s reopen 2>/dev/null || true
        else
            /bin/kill -USR1 `cat /var/run/nginx.pid` 2>/dev/null || true
        fi
    endscript
}
EOF
    fi

fi
