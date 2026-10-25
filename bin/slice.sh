#!/bin/bash

# Logging
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $*" | sudo tee -a /var/log/go/$(basename "$0").log >/dev/null

MemoryLimit=$(sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/config.db "select MemoryLimit from Config")
CPULimit=$(sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/config.db "select CPULimit from Config")

if ! [[ "$CPULimit" =~ ^[0-9]+$ ]] || ! [[ "$MemoryLimit" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid CPU or Memory limit values"
    exit 1
fi

if [ "$CPULimit" -eq 100 ] && [ "$MemoryLimit" -eq 100 ]; then

    sudo rm -rf /etc/systemd/system/user-.slice.d

elif [ "$CPULimit" -ge 5 ] && [ "$MemoryLimit" -ge 5 ]; then

    sudo mkdir -p /etc/systemd/system/user-.slice.d
    sudo rm -rf /etc/systemd/system/user-.slice.d/*

    File="/etc/systemd/system/user-.slice.d/all.conf"

    sudo cat >"$File" <<EOF
[Slice]
CPUQuota=${CPULimit}%
MemoryHigh=${MemoryLimit}%
MemoryMax=${MemoryLimit}%
EOF

fi

sudo systemctl daemon-reload

At=$(for Job in $(atq | awk '{print $1}'); do at -c $Job | grep "/go/"; done)
if [[ ! "$At" = *"mariadbqouta"* ]]; then
    echo "/go/mariadbqouta" | at now + 3 minute >/dev/null 2>&1
fi
