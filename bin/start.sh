#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if sudo test ! -f /root/.config/rclone/rclone.conf ; then
    sudo mkdir -p /root/.config/rclone
    sudo touch /root/.config/rclone/rclone.conf
fi

if sudo test ! -f /etc/profile.d/nano.sh ; then

    sudo mkdir -p /etc/profile.d
    {
        echo "export VISUAL=nano"
        echo "export EDITOR=nano"
    } | sudo tee /etc/profile.d/nano.sh >/dev/null

fi

if sudo test ! -f /usr/local/goadmio/linux/os.db  || sudo test ! -f /usr/local/goadmio/linux/version.db ; then
    sudo /go/os
fi

if sudo test ! -f /usr/local/goadmio/linux/ws.db ; then
    sudo /go/ws
fi

if sudo test ! -f /usr/local/goadmio/db/elapsed.db ; then
    echo "0" | sudo tee /usr/local/goadmio/db/elapsed.db >/dev/null
fi

if sudo test ! -f /usr/local/goadmio/include/config/config.php ; then
    sudo /go/config
    sudo /go/connect
fi

if sudo test ! -f /usr/local/goadmio/include/config/machine.db ; then
    sudo /go/machine
fi

if sudo test ! -d /usr/local/goadmio/home/go/phpmyadmin ; then
    sudo /go/phpmyadmin
fi

if sudo test ! -d /usr/local/goadmio/template ; then
    sudo /go/default
    sudo /go/template
fi

if sudo test ! -d /usr/local/goadmio/home/go/webmail/roundcube/config ; then
    sudo /go/roundcube
fi

if sudo test ! -d /usr/local/goadmio/home/go/webmail/snappymail/data ; then
    sudo /go/snappymail
fi

if sudo test ! -d /usr/local/goadmio/includes/vendor/phpmailer ; then
    sudo /go/vendor
fi

if sudo test -f "$HOME/.bash_profile" ; then

    if ! grep -q ":/go" "$HOME/.bash_profile"; then
        sudo sed -i "s/PATH=\$PATH:\$HOME\/bin/PATH=\$PATH:\$HOME\/bin:\/go/g" "$HOME/.bash_profile"
    fi

    if ! grep -q ":/go" "$HOME/.bash_profile"; then
        echo "PATH=\"\$PATH:/go\"" | sudo tee -a "$HOME/.bash_profile" >/dev/null
    fi

fi

if sudo test -f "$HOME/.profile" ; then
    if ! grep -q ":/go" "$HOME/.profile"; then
        echo "PATH=\"\$PATH:/go\"" | sudo tee -a "$HOME/.profile" >/dev/null
    fi
fi

DiskSpacePercent=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g')
if [ "$DiskSpacePercent" -ge "95" ]; then
    echo "Your disk space is running low."
fi

UserNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/user.db "SELECT count(*) from User")
if [ "$UserNo" -eq "0" ]; then
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/user.db "INSERT INTO User (UserGroup,Username,Password,Email) VALUES ('1','','','')"
fi

if [ ! -e /go ]; then
    rm -f /go
    sudo ln -s /usr/local/goadmio/bin /go
fi
