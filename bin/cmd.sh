#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if sudo test -f /etc/audit/rules.d/cmd.rules ; then

    # Real-time monitoring
    aureport -k

else

    sudo dnf -y remove audit
    sudo dnf -y remove audit-libs

    sudo rm -rf /etc/audit/rules.d/*

    sudo dnf -y install audit
    sudo dnf -y install audit-libs

    sudo cat >/etc/audit/rules.d/cmd.rules <<'EOF'
# Log all commands executed by users
-a always,exit -F arch=b64 -S execve -k exec_log
-a always,exit -F arch=b32 -S execve -k exec_log
EOF

    augenrules --load

    # Restart auditd
    # systemctl restart auditd
    # systemctl enable auditd

    # Real-time monitoring
    aureport -k

fi
