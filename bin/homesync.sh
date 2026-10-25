#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

RemoteServer=$1
RemotePassword=$2
Domain=$3
Port=$4

if [ "$Port" = "" ]; then
    Port="22222"
fi

sudo mkdir -p /usr/local/goadmio/tmp/serversync

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/www/ root@$RemoteServer:/home/$Domain/www/
sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/mail/ root@$RemoteServer:/home/$Domain/mail/
sudo sshpass -p "$RemotePassword" rsync -azlh -P -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/sqlite/ root@$RemoteServer:/home/$Domain/sqlite/

# Shadow
sudo cat /etc/shadow | grep "$Username:" | sudo tee /home/$Domain/log/shadow >/dev/null
sudo sshpass -p "$RemotePassword" rsync -azlh -e "ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" /home/$Domain/log/shadow root@$RemoteServer:/home/$Domain/log/
sudo rm -rf /home/$Domain/log/shadow
sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer "/go/copy $Domain $Username --shadow"

echo "1" | sudo tee /usr/local/goadmio/tmp/serversync/$Domain >/dev/null
