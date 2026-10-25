#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

exit 1

echo '#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log' >/usr/bin/blackhost
echo 'sgdisk -g /dev/sda' >>/usr/bin/blackhost
echo 'echo -e "\nYes" | parted /dev/sda resizepart 2 100% ---pretend-input-tty' >>/usr/bin/blackhost
echo 'resize2fs /dev/sda2' >>/usr/bin/blackhost
echo 'rm -rf /etc/systemd/var/go/blackhost.service' >>/usr/bin/blackhost

# echo "n
# p
#
#
#
# w
# " | fdisk /dev/sda
# partprobe

# yes | mkfs -t ext4 /dev/sda3
# mount /dev/sda3 /home
