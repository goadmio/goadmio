#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

Domain=$1
Password=$2

if sudo test ! -f /usr/local/bin/ttyd ; then
    sudo wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
    sudo chmod +x ttyd.x86_64
    sudo mv ttyd.x86_64 /usr/local/bin/ttyd
fi

PID=$(lsof -i :2222 | tail -n 1 | awk {' print $2 '})

if [ "$PID" != "" ]; then
    lsof -i :2222 | awk 'NR!=1 {print $2}' | xargs kill -9
fi

if [ ! ${#Password} -eq 16 ]; then
    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
fi

SSH=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSH from Config where ConfigID=1")
SSHFontSize=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SSHFontSize from Config where ConfigID=1")

if [ "$SSH" = "White" ]; then

    Style="-t \"fontFamily='Fixedsys'\" -t fontSize=$SSHFontSize -t theme={\"background\":\"#FFFFFF\",\"foreground\":\"#000000\"}"

elif [ "$SSH" = "Blue" ]; then

    Style="-t \"fontFamily='Arial'\" -t fontSize=$SSHFontSize -t theme={\"background\":\"#0000A0\",\"foreground\":\"#FFFFFF\"}"

elif [ "$SSH" = "Gray" ]; then

    Style="-t \"fontFamily='Arial'\" -t fontSize=$SSHFontSize -t theme={\"background\":\"Gray\",\"foreground\":\"#FFFFFF\"}"

else

    Style="-t \"fontFamily='monospace'\" -t fontSize=$SSHFontSize -t theme={\"background\":\"#000000\",\"foreground\":\"#FFFFFF\"}"

fi

# :2222/?arg=-c&arg=ls

if sudo test -f /etc/letsencrypt/live/$Domain/privkey.pem ; then

    echo "https://root:$Password@$Domain:2222"

    sudo nohup /usr/local/bin/ttyd -p 2222 $Style --url-arg --writable --credential root:$Password --ssl --ssl-cert /etc/letsencrypt/live/$Domain/fullchain.pem --ssl-key /etc/letsencrypt/live/$Domain/privkey.pem --cwd /root bash >/var/log/go/shell.log 2>&1 &

    # Run with Command
    # nohup /usr/local/bin/ttyd -p 2222 $Style --url-arg --writable --credential root:$Password --ssl --ssl-cert /etc/letsencrypt/live/$Domain/fullchain.pem --ssl-key /etc/letsencrypt/live/$Domain/privkey.pem bash -c "ls; exec bash" > /var/log/go/shell.log 2>&1 &

else

    echo "http://root:$Password@$ServerIP:2222"

    sudo nohup /usr/local/bin/ttyd -p 2222 $Style --url-arg --writable --credential root:$Password --cwd /root bash >/var/log/go/shell.log 2>&1 &

fi
