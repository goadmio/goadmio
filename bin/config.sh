#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$1
SSHUsername=$2

if [[ $@ = *"--force"* ]]; then
    sudo rm -rf /usr/local/goadmio/include/config/config.php
fi

if [ $# -ne 2 ]; then

    if sudo test -f /usr/local/goadmio/include/config/config.php ; then

        echo "/usr/local/goadmio/include/config/config.php File Already Exists."

        exit 1

    else

        sudo mkdir -p /usr/local/goadmio/include/config

        # Get SSHUsername & DBPass
        ServerIP=$(curl -s -4 checkip.amazonaws.com)
        MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}')
        SSHUsername=$(echo -n "$ServerIP|$MAC" | md5sum | awk '{print "go" substr($1, 0, 14)}')
        SMTPPass=$(echo -n "$MAC|$(date +%s)" | md5sum | awk '{print $1}')

        if sudo test -f /root/.my.cnf ; then
            MySQLRootPassword=$(sudo grep '^password=' /root/.my.cnf | sed 's/password=//')
        fi

        ResetSSHD="1"

    fi

fi

if [ "$#" -eq "2" ]; then
    SSHPort="33"
elif sudo test -f /etc/sysconfig/dropbear  || sudo test -f /etc/default/dropbear ; then
    SSHPort=$(($(/go/dropbear port)))
elif sudo test -f /etc/ssh/sshd_config ; then
    SSHPort=$(($(sudo grep Port /etc/ssh/sshd_config | awk {'print $2'})))
else
    SSHPort="22"
fi

if [ "$SSHPort" -eq "0" ]; then
    SSHPort="22"
fi

# Config
echo "<?php" | sudo tee /usr/local/goadmio/include/config/config.php >/dev/null
echo "if (substr(getcwd(),0,18) == \"/usr/local/goadmio\")" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "{" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$DBHost=\"localhost\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$DBName=\"go\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$DBUser=\"root\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$DBPass=\"$MySQLRootPassword\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$SSHHost=\"localhost\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$SSHUsername=\"$SSHUsername\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "\$SSHPort=\"$SSHPort\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "else" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "{" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "echo \"Invalid GoAdmio Path (Run: /go/config --force)\";" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "exit;" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null
echo "?>" | sudo tee -a /usr/local/goadmio/include/config/config.php >/dev/null

if [ "$ResetSSHD" = "1" ]; then

    # Reset PORT to 22
    sudo /go/ssh

fi
