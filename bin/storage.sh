#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test -f "/var/go/etc/storage" ; then
    Dir=$(</var/go/etc/storage)
    Dir=$(echo "$Dir" | sed 's/[^A-Za-z0-9\-]//g')
else
    Dir="storage"
fi

if grep -q "\[ "$Dir"\]" /root/.config/rclone/rclone.conf; then

    sudo mkdir -p /$Dir
    sudo rclone mount $Dir:$Dir /$Dir --daemon --allow-other --allow-non-empty --vfs-cache-mode full --cache-dir /tmp/rclone --vfs-cache-max-size 10G --vfs-cache-max-age 72h --transfers 32 --checkers 32 --buffer-size 128M

else

    echo "Rclone [$Dir] not found in file:"
    echo "/root/.config/rclone/rclone.conf"
    exit 1

fi
