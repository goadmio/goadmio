#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(sudo cat /usr/local/goadmio/linux/os.db)

if sudo test ! -f /etc/ssh/sshd_config.bak ; then
    if sudo  test -f /etc/ssh/sshd_config ; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    fi
fi

if [ "$1" = "restart" ]; then

    if [ "$OS" = "Ubuntu" ]; then
        sudo systemctl restart ssh
    else
        sudo systemctl restart sshd
    fi

    exit 0

fi

if sudo test -f /usr/local/goadmio/include/config/config.php; then
    SSHUsername=$(sudo grep -oP 'SSHUsername="\K[^"]+' /usr/local/goadmio/include/config/config.php)
fi

if sudo test ! -f /etc/ssh/sshd_config.bak ; then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
fi

if command -v sqlite3 &>/dev/null; then
    PermitRootLogin=$(($(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT PermitRootLogin FROM Config WHERE ConfigID=1")))
    
    SSHPort=$(($(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT SSHPort FROM Config WHERE ConfigID=1")))
    SSHPort=${SSHPort:-22}
else
    SSHPort=22
fi

if [[ "$@" = *"--serversync"* ]]; then

    MaxSessions="250"
    MaxStartups="250"
    MaxAuthTries="100"
    ClientAliveInterval="60"
    ClientAliveCountMax="5"

else

    MaxSessions="10"
    MaxStartups="10:30:100"
    MaxAuthTries="6"
    ClientAliveInterval="0"
    ClientAliveCountMax="3"

fi

if [ "$SSHPort" -eq "0" ] || [ "$SSHPort" -eq "22" ]; then
    echo "Port 22" | sudo tee /etc/ssh/sshd_config >/dev/null
else
    echo "Port $SSHPort" | sudo tee /etc/ssh/sshd_config >/dev/null
fi

echo "MaxSessions $MaxSessions" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "MaxStartups $MaxStartups" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "MaxAuthTries $MaxAuthTries" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "ClientAliveInterval $ClientAliveInterval" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "ClientAliveCountMax $ClientAliveCountMax" | sudo tee -a /etc/ssh/sshd_config >/dev/null

echo "SyslogFacility AUTHPRIV" | sudo tee -a /etc/ssh/sshd_config >/dev/null

if [ "$PermitRootLogin" = "1" ]; then
    echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null
else
    echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
fi

echo "AuthorizedKeysFile      .ssh/authorized_keys" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "ChallengeResponseAuthentication no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "GSSAPIAuthentication yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "GSSAPICleanupCredentials no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "X11Forwarding yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "PrintMotd no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "AcceptEnv LANG LC_*" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "Subsystem sftp internal-sftp" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "" | sudo tee -a /etc/ssh/sshd_config >/dev/null

if sudo grep -q "Include /etc/ssh/sshd_config.d/\*.conf" /etc/ssh/sshd_config.bak; then
    echo "# AlmaLinix & RockyLinux" | sudo tee -a /etc/ssh/sshd_config >/dev/null
    echo "Include /etc/ssh/sshd_config.d/*.conf" | sudo tee -a /etc/ssh/sshd_config >/dev/null
fi

if sudo grep -q "TrustedUserCAKeys /etc/ssh/lightsail_instance_ca.pub" /etc/ssh/sshd_config.bak; then
    echo "# AWS Lightsail" | sudo tee -a /etc/ssh/sshd_config >/dev/null
    echo "TrustedUserCAKeys /etc/ssh/lightsail_instance_ca.pub" | sudo tee -a /etc/ssh/sshd_config >/dev/null
fi

if sudo grep -q "CASignatureAlgorithms +ssh-rsa" /etc/ssh/sshd_config.bak; then
    echo "CASignatureAlgorithms +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config >/dev/null
fi

if [ "$SSHUsername" != "" ]; then

    ShellDomains=$(sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/site.db "select Domain from Site where Shell=1" | sed 's/^/!/' | paste -sd, -)

    echo "" | sudo tee -a /etc/ssh/sshd_config >/dev/null
    
    if [[ "$ShellDomains" = *"."* ]]; then
        echo "Match User *,!root,$ShellDomains,!go,!$SSHUsername" | sudo tee -a /etc/ssh/sshd_config >/dev/null
    else
        echo "Match User *,!root,!go,!$SSHUsername" | sudo tee -a /etc/ssh/sshd_config >/dev/null
    fi

    echo "    ChrootDirectory %h" | sudo tee -a /etc/ssh/sshd_config >/dev/null

fi

echo "" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "Match Group Jailed" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "    ChrootDirectory %h" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "    AllowTcpForwarding no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
echo "    X11Forwarding no" | sudo tee -a /etc/ssh/sshd_config >/dev/null

if [ "$OS" = "Ubuntu" ]; then
    sudo systemctl restart ssh
else
    sudo systemctl restart sshd
fi