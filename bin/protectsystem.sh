#!/bin/bash

# Create directory first
sudo mkdir -p /etc/systemd/system/php8.5-fpm.service.d

# Create override file
sudo cat >/etc/systemd/system/php8.5-fpm.service.d/override.conf <<'EOF'
[Service]
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
NoNewPrivileges=true
ReadWritePaths=/home
ReadWritePaths=/backup
ReadWritePaths=/var
ReadWritePaths=/tmp
ReadWritePaths=/run
ReadOnlyPaths=/usr/local/goadmio/includes
StateDirectory=php-fpm
CacheDirectory=php-fpm
RuntimeDirectory=php-fpm
LogsDirectory=php-fpm
EOF

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart php8.5-fpm
sudo systemctl status php8.5-fpm
