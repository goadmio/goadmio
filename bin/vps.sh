#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Action=$1
IP=$2
Value=$3
Port=$4

if [ "$Port" = "" ]; then
    Port="22"
fi

if [ "$3" = "" ]; then
    Password=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
else
    Password="$Value"
fi

if sudo test -f /var/go/etc/go.key ; then

    MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}' | base64)
    RemotePassword=$(sudo openssl base64 -d -aes-128-cbc -d -pbkdf2 -nosalt -md md5 -in /var/go/etc/go.key -pass pass:"$MAC")

else

    echo "REMOTE: Invalid password"
    exit 1

fi

if [ $# -eq 0 ]; then

    # Check Expired VPS and STOP IT

    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    sudo curl --silent --output /dev/nul "http://$ServerIP/go/vps.php?Action=Renew"

    Date=$(date +'%Y-%m-%d')

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select ID || ',' || ServerIP || ',' || IP || ',' || ExpiresOn from VPS where ExpiresOn<='$Date' and CustomerID>=1;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        ID="${Row[0]}"
        ServerIP="${Row[1]}"
        IP="${Row[2]}"
        ExpiresOn="${Row[3]}"

        Days=$((($(date -d "$Date" +%s) - $(date -d "$ExpiresOn" +%s)) / 86400))

        echo "Stopping VPS:"
        echo "Server IP: $ServerIP"
        echo "VPS IP: $IP"
        echo "ID: $ID"
        echo "Expired: $Days days ago"
        echo ""

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID &> /dev/null"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct set $ID --onboot 0 &> /dev/null"

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID &> /dev/null"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --onboot 0 &> /dev/null"

        if [ "$Days" -ge "7" ]; then

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "UPDATE VPS SET CustomerID=0,File='' where IP='$IP'"

        fi

    done

    # Stop All Not Assigned
    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select ID || ',' || ServerIP || ',' || IP from VPS where CustomerID=0;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        ID="${Row[0]}"
        ServerIP="${Row[1]}"
        IP="${Row[2]}"

        echo "Stopping VPS (Not Assigned):"
        echo "Server IP: $ServerIP"
        echo "VPS IP: $IP"
        echo "ID: $ID"
        echo ""

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID &> /dev/null"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct set $ID --onboot 0 &> /dev/null"

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID &> /dev/null"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --onboot 0 &> /dev/null"

    done

    exit 1

fi

if [ "$Action" = "resellerclub" ]; then

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select VPSID || ',' || IP FROM VPS ORDER BY VPSID;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        VPSID="${Row[0]}"
        IP="${Row[1]}"

        Hostname="vps$VPSID.blackhost.com"
        NSHostname="ns$VPSID.blackhost.com"

        echo "$Hostname -> $IP..."

        sudo curl "https://test.httpapi.com/api/dns/manage/add-ipv4-record.json?auth-userid=61678&api-key=Gkn0gtHe4sYoF8xgl5Rbwlq0QEeEzLiL&domain-name=blackhost.com&host=vps$VPSID&value=$IP"

        if [ "$2" != "" ] && [ "$3" != "" ]; then

            if [[ "$IP" = "188.40.248."* ]]; then

                sudo curl -u $2:$3 https://robot-ws.your-server.de/rdns/$IP -d ptr=$Hostname

            fi

        fi

    done

    exit 1

fi

if [ "$Action" = "diskusage" ]; then

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/server.db "select ServerIP from Server")
    for ServerIP in $SQL; do

        DiskUsage=$(sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "df -h / | sed -e /Filesystem/d | awk '{ print \$5 }' | sed 's/[^0-9]*//g'")
        MemoryUsage=$(sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "free | grep Mem | awk '{print \$3/\$2 * 100.0}'")

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/server.db "UPDATE Server SET DiskUsage='$DiskUsage',MemoryUsage='$MemoryUsage' where ServerIP='$ServerIP'"

        echo "$ServerIP | Disk Usage: ${DiskUsage}%, Memory Usage: ${MemoryUsage}%"

    done

    exit 1

fi

VPSID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select VPSID from VPS where IP='$IP'")
ServerIP=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select ServerIP from VPS where IP='$IP'")
ID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select ID from VPS where IP='$IP'")
File=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select File from VPS where IP='$IP'")
Hostname=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select Hostname from VPS where IP='$IP'")
Cores=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select Cores from VPS where IP='$IP'")
DiskSpace=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select DiskSpace from VPS where IP='$IP'")
Memory=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select Memory from VPS where IP='$IP'")
MAC=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select MAC from VPS where IP='$IP'")
Gateway=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select Gateway from VPS where IP='$IP'")
CIDR=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "select CIDR from VPS where IP='$IP'")

Device=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/distro.db "select Device from Distro where File='$File'")

ID=$(($ID))
if [ ! "$ID" -ge "100" ]; then

    echo "Invalid Contaner ID $ID"
    exit 1

fi

if [ "$Hostname" = "" ]; then

    Hostname="vps$VPSID.blackhost.com"

fi

if [[ "$File" = *"centos"* ]] || [[ "$File" = *"almalinux"* ]] || [[ "$File" = *"rockylinux"* ]]; then

    OSType="centos"

elif [[ "$File" = *"fedora"* ]]; then

    OSType="fedora"

elif [[ "$File" = *"debian"* ]]; then

    OSType="debian"

elif [[ "$File" = *"ubuntu"* ]]; then

    OSType="ubuntu"

elif [[ "$File" = *"opensuse"* ]]; then

    OSType="opensuse"

elif [[ "$File" = *"archlinux"* ]]; then

    OSType="archlinux"

elif [[ "$File" = *"devuan"* ]]; then

    OSType="devuan"

elif [[ "$File" = *"alpine"* ]]; then

    OSType="alpine"

elif [[ "$File" = *"gentoo"* ]]; then

    OSType="gentoo"

elif [[ "$File" = *"nixos"* ]]; then

    OSType="nixos"

else

    OSType="unmanaged"

fi

if [ "$Action" = "reinstall" ]; then

    echo -ne "|0"

    if [[ "$File" = *".vma.zst" ]]; then

        if [ "$Device" = "IDE" ]; then

            # VM (IDE) Windows
            Memory=$(($Memory * 1000))
            echo -ne "|5"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID && pct destroy $ID &> /dev/null"
            echo -ne "|10"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID && qm destroy $ID &> /dev/null"
            echo -ne "|15"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qmrestore /var/lib/vz/template/cache/$File $ID -storage local &> /dev/null"
            echo -ne "|20"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --memory $Memory --cores $Cores --onboot 1 --agent 1 --net0 e1000=$MAC,bridge=vmbr0,firewall=1 &> /dev/null"
            echo -ne "|25"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm resize $ID ide0 +${DiskSpace}G &> /dev/null"
            echo -ne "|30"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm start $ID"

            To=$(($DiskSpace / 90 + 20))
            for ((N = 1; N <= $To; N += 1)); do

                P=$((60 / $To * $N + 30))
                echo -ne "|$P"
                sleep 10

            done

            sleep 30
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm guest passwd $ID Administrator --password '$Password'"
            echo -ne "|100"

        else

            # VM (SCSI) Linux
            Memory=$(($Memory * 1000))
            echo -ne "|5"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID && pct destroy $ID &> /dev/null"
            echo -ne "|10"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID && qm destroy $ID &> /dev/null"
            echo -ne "|15"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qmrestore /var/lib/vz/template/cache/$File $ID -storage local &> /dev/null"
            echo -ne "|20"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --memory $Memory --cores $Cores --onboot 1 --agent 1 --net0 virtio=$MAC,bridge=vmbr0,firewall=1 &> /dev/null"
            echo -ne "|25"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm resize $ID scsi0 +${DiskSpace}G &> /dev/null"
            echo -ne "|30"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm start $ID"

            To=$(($DiskSpace / 90 + 20))
            for ((N = 1; N <= $To; N += 1)); do

                P=$((60 / $To * $N + 30))
                echo -ne "|$P"
                sleep 10

            done

            sleep 30
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm guest passwd $ID root --password '$Password'"
            echo -ne "|100"

        fi

    else

        # CLX

        echo -ne "|10"
        Memory=$(($Memory * 1000))

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID && pct destroy $ID &> /dev/null"
        echo -ne "|20"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID && qm destroy $ID &> /dev/null"

        if [ "$Gateway" = "" ]; then

            echo "pct create $ID /var/lib/vz/template/cache/$File -arch amd64 -ostype $OSType -hostname '$Hostname' -cores $Cores -storage local -rootfs volume=local:$DiskSpace -memory $Memory -password '$Password' -features fuse=1,nesting=1 -unprivileged 1 -onboot 1 -net0 name=eth0,bridge=vmbr0,firewall=1,hwaddr=$MAC,ip=dhcp,type=veth"

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct create $ID /var/lib/vz/template/cache/$File -arch amd64 -ostype $OSType -hostname '$Hostname' -cores $Cores -storage local -rootfs volume=local:$DiskSpace -memory $Memory -password '$Password' -features fuse=1,nesting=1 -unprivileged 1 -onboot 1 -net0 name=eth0,bridge=vmbr0,firewall=1,hwaddr=$MAC,ip=dhcp,type=veth &> /dev/null"

        else

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct create $ID /var/lib/vz/template/cache/$File -arch amd64 -ostype $OSType -hostname '$Hostname' -cores $Cores -storage local -rootfs volume=local:$DiskSpace -memory $Memory -password '$Password' -features fuse=1,nesting=1 -unprivileged 1 -onboot 1 -net0 name=eth0,bridge=vmbr0,firewall=1,gw=$Gateway,ip=$IP/$CIDR,type=veth &> /dev/null"

        fi

        echo -ne "|30"
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct start $ID"
        echo -ne "|40"

        if [ "$OSType" = "centos" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'echo $Password | passwd root --stdin'"

        elif [ "$OSType" = "fedora" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'echo $Password | passwd root --stdin'"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl enable systemd-networkd'"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl restart systemd-networkd'"

        elif [ "$OSType" = "debian" ] || [ "$OSType" = "ubuntu" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'usermod --password \$(echo $Password | openssl passwd -1 -stdin) root'"

        else

            # Unknown operating system
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'usermod --password \$(echo $Password | openssl passwd -1 -stdin) root'"

        fi

        if [[ "$File" = *"-go"* ]]; then

            # After Install Gekkpanel
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl enable httpd && systemctl enable mariadb && systemctl enable php82-php-fpm && systemctl enable php74-php-fpm'"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl restart httpd && systemctl restart mariadb && systemctl restart php82-php-fpm && systemctl restart php74-php-fpm'"

        fi

        echo -ne "|100"

    fi

elif [ "$Action" = "reset" ]; then

    if [[ "$File" = *".vma.zst" ]]; then

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm start $ID &> /dev/null"

        sleep 5

        # Change Password (Windows)
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm guest passwd $ID Administrator --password '$Password'"
        # Change Password (Linux)
        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm guest passwd $ID root --password '$Password'"

        echo "$Password"

    else

        sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct start $ID &> /dev/null"

        if [ "$OSType" = "centos" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'echo $Password | passwd root --stdin' &> /dev/null"

        elif [ "$OSType" = "fedora" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'echo $Password | passwd root --stdin' &> /dev/null"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl enable systemd-networkd' &> /dev/null"
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'systemctl restart systemd-networkd' &> /dev/null"

        elif [ "$OSType" = "debian" ] || [ "$OSType" = "ubuntu" ]; then

            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'usermod --password \$(echo $Password | openssl passwd -1 -stdin) root'"

        else

            # Unknown operating system
            sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct exec $ID -- bash -c 'usermod --password \$(echo $Password | openssl passwd -1 -stdin) root'"

        fi

        echo "$Password"

    fi

elif [ "$Action" = "hostname" ]; then

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct set $ID -hostname $Value"

    echo "Hostname changhed to $Value"

elif [ "$Action" = "reboot" ]; then

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct reboot $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct start $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct fstrim $ID &> /dev/null"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm reboot $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm start $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm agent $ID fstrim &> /dev/null"

    echo "Server has been successfully restarted."

elif [ "$Action" = "suspend" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "UPDATE VPS SET Suspend=1 where IP='$IP'"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct stop $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct set $ID --onboot 0 &> /dev/null"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm stop $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --onboot 0 &> /dev/null"

    echo "Server $ID has been suspended."

elif [ "$Action" = "unsuspend" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/vps.db "UPDATE VPS SET Suspend=0 where IP='$IP'"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct start $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "pct set $ID --onboot 1 &> /dev/null"

    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm start $ID &> /dev/null"
    sudo sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q $ServerIP "qm set $ID --onboot 1 &> /dev/null"

    echo "Server $ID has been unsuspended."

elif [ "$Action" = "rdns" ]; then

    sudo curl -u user:pass https://robot-ws.your-server.de/rdns/95.216.236.66 -d ptr=smtp.blackhost.com

fi
