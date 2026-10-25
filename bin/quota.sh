#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/quota "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" = "off" ]; then

    quotaoff -avug >/dev/null 2>&1
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Quota='0'"
    echo "Quota is successfully disabled."
    exit 1

fi

if sudo test -f /etc/fstab ; then
    if sudo test ! -f /etc/fstab.bak ; then
        sudo cp /etc/fstab /etc/fstab.bak
    fi
fi

# Enable Qouta On "/home"
if grep -q "/home" /etc/fstab; then
    if ! grep -qE "usrquota" /etc/fstab; then
        sudo sed -i '/^[^#].*[[:space:]]\/home[[:space:]].*ext4/s/defaults/defaults,usrquota,grpquota/; /^[^#].*[[:space:]]\/home[[:space:]].*xfs/s/defaults/defaults,usrquota,grpquota/' /etc/fstab
        sudo systemctl daemon-reload
    fi
fi

# Enable Qouta On "/"
if ! grep -qE "usrquota" /etc/fstab; then
    sudo sed -i '/^[^#].*\/ .*ext4/s/defaults/defaults,usrquota,grpquota/' /etc/fstab
    sudo systemctl daemon-reload
fi

# Initialize quota files
if grep -q "/home" /etc/fstab; then
    MountedOn="/home"
else
    MountedOn="/"
fi

Filesystem=$(df --output=source / | tail -n 1)

mount -o remount $MountedOn

quotacheck -cugm -f -F vfsv1 $MountedOn >/dev/null 2>&1

quotacheck -avugm >/dev/null 2>&1

if [ "$1" = "on" ]; then

    Output=$(quotaon -avug 2>&1)

    if [ "$Output" = "" ] || [[ "$Output" = *"resource busy"* ]] || [[ "$Output" = *"switch"* ]] || [[ "$Output" = *"deprecated"* ]]; then

        echo "Failed to enable quotas."
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Quota='0'"

        echo ""
        echo "To enable quotas, Please run those commands in Rescue Mode:"
        echo "tune2fs -O quota $Filesystem"
        echo "reboot"
        echo ""
        exit 1

    else

        echo "Quota is successfully enabled."
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Quota='1'"

    fi

fi

# Verify quotas are enabled
# repquota -a
# quota -uvs go.org | tail -1 | awk '{print $7}'

Quota=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select Quota from Config")

if [ "$Quota" -eq "1" ]; then

    N=0
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if sudo test -d /home/$Domain/www ; then

            N=$(($N + 1))

            Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

            DiskSpace=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select DiskSpace/1024 from Site where Domain='$Domain'")
            DiskSpace=$(printf "%.0f" "$DiskSpace")

            Inode=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Inode from Site where Domain='$Domain'")
            Inode=$(printf "%.0f" "$Inode")

            if [ "$DiskSpace" -gt 0 ] || [ "$Inode" -gt 0 ]; then

                echo "[$N/$C] $Domain Disk Space $DiskSpace KB"
                setquota -u $Username 0 $DiskSpace 0 $Inode $MountedOn

                InodeUsed=$(quota -uvs $Username | tail -1 | awk '{print $5}')
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET InodeUsed='$InodeUsed' where Domain='$Domain'"

            fi

        fi

    done

else

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET InodeUsed='0'"

fi
