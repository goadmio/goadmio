#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo mkdir -p /mnt

sudo mkdir -p /mnt0
sudo mkdir -p /mnt1
sudo mkdir -p /mnt2
sudo mkdir -p /mnt3

# md0
# md1
# md2 (3 Hard Disks RAID 10)
# md3
mount /dev/md0 /mnt0
mount /dev/md1 /mnt1
mount /dev/md2 /mnt2
mount /dev/md3 /mnt3

if sudo test -d /mnt0/home ; then
    mount /dev/md0 /mnt
fi

if sudo test -d /mnt1/home ; then
    mount /dev/md1 /mnt
fi

if sudo test -d /mnt2/home ; then
    mount /dev/md2 /mnt
fi

if sudo test -d /mnt3/home ; then
    mount /dev/md3 /mnt
fi

mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
mount -t tmpfs tmpfs /mnt/run/lock
chroot-prepare /mnt
chroot /mnt /bin/bash

# Run MariaDB (RUN AFTER chroot)
sudo /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql &
