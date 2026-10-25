#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ConfigPassword=$1

Hostname=$(</etc/hostname)
AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
QueueNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select QueueNo from Config")
IMAPAlert=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select IMAPAlert from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

SSHLogin=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "SELECT count(*) FROM Notify WHERE Keyword='SSH Login' and (Email='1' or Whatsapp='1' or Missed='1')")

RemoteMariaDB=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT RemoteMariaDB from Config")
RemoteMariaDB=${RemoteMariaDB:-0}

if [ "$ConfigPassword" != "" ]; then

    ConfigPassword=$(echo -n "[$ConfigPassword]" | md5sum | awk '{print $1}')
    echo "$ConfigPassword" | sudo tee /etc/config >/dev/null

fi

if [ "$SSHLogin" -ge "1" ]; then

    # SSH login alert with sendmail
    echo "IP=\$(echo \$SSH_CONNECTION | cut -d ' ' -f 1)" | sudo tee /etc/ssh/sshrc >/dev/null
    echo "if [ \"\$IP\" != \"127.0.0.1\" ]; then" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "    Code=\$(curl --max-time 3 -s https://ipinfo.io/\$IP)" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "    Country=\$(echo \"\$Code\" | grep -oP '\"country\": \"\K[^\"]+' | sed 's/[^A-Za-z ]//g')" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "    City=\$(echo \"\$Code\" | grep -oP '\"city\": \"\K[^\"]+' | sed 's/[^A-Za-z ]//g')" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "    /go/sendmail \"SSH Login Alerts\" \"User \$USER just logged in from \$IP (\$City - \$Country)\" \"SSH Login\"" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "    /go/sendwhatsapp \"*SSH Login Alerts*\n\nUser \$USER just logged in from \$IP (\$City - \$Country)\" \"SSH Login\"" | sudo tee -a /etc/ssh/sshrc >/dev/null
    echo "fi" | sudo tee -a /etc/ssh/sshrc >/dev/null

else

    sudo rm -rf /etc/ssh/sshrc

fi

sudo /go/doveconf
sudo screen -d -m bash -c "/go/mail restart"

if [ "$RemoteMariaDB" -eq "1" ]; then
    sudo screen -d -m bash -c "/go/allow 3306"
else
    sudo screen -d -m bash -c "/go/deny 3306"
fi

sudo /go/ssh
sudo /go/go
sudo /go/reload "| Executed by $(basename "$0")"
