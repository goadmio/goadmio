#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

exit 1

sudo apt -y install lvm2
/etc/init.d/lvm2 start

/sbin/pvcreate /dev/sda
/sbin/pvcreate /dev/sdb
/sbin/pvcreate /dev/sdc
/sbin/pvcreate /dev/sdd

/sbin/vgcreate hdd /dev/sda /dev/sdb /dev/sdc /dev/sdd
# /sbin/vgremove hdd
lvcreate -n p01 -l 100%FREE hdd

mkfs.ext4 /dev/hdd/p01
sudo mkdir /home2
mount /dev/hdd/p01 /home2

# /etc/fstab
/dev/hdd/p01 /home2 ext4 defaults 0 0

#
# mount -a /dev/hdd/p01 /var/lib/vz
# /dev/hdd/p01 /var/lib/vz ext4 defaults 0 0
