#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

StorageType=$(lsblk -d -o ROTA | tail -n +2 | head -n 1 | awk {'print $1'} | sed 's/0/SSD/' | sed 's/1/HDD/')
NVME=$(lsblk -d -o NAME | tail -n +2 | head -n 1 | awk {'print $1'})
if [[ "$NVME" = *"nvme"* ]]; then
    StorageType="NVMe SSD"
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! command -v hdparm &>/dev/null; then
        sudo dnf -y install hdparm
    fi

    if ! command -v smartctl &>/dev/null; then
        sudo dnf -y install smartmontools
    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    if ! command -v hdparm &>/dev/null; then
        sudo apt -y install hdparm
    fi

    if ! command -v smartctl &>/dev/null; then
        sudo apt -y install smartmontools
    fi

fi

echo "Hard Disk Storage Type: $StorageType"

# Find the Largest Disk Partition
Partition=$(df -h | sort -rh -k 2 | awk {'print $1'} | grep "/" | head -n 1)

ReadSpeed=$(hdparm -t $Partition | tail -n 1 | awk {'print $11,$12'})
WriteSpeed=$(hdparm -t --direct $Partition | tail -n 1 | awk {'print $11,$12'})

echo "Hard Disk Read Speed: $ReadSpeed"
echo "Hard Disk Write Speed: $WriteSpeed"

Hard=$(smartctl --scan | head -n 1 | awk {'print $1'})
Hours=$(smartctl -a $Hard | grep "Power On Hours" | awk {'print $4'} | sed 's/[^0-9]//g')

if [ "$Hours" = "" ]; then
    Hours=$(smartctl -a $Hard | grep "Power_On_Hours" | awk {'print $10'} | sed 's/[^0-9]//g')
fi

Days=$((Hours / 24))

if [ "$Days" != "0" ]; then
    echo "Hard Disk Working Days: $Days"
fi

PercentageUsed=$(smartctl -a $Hard | grep -E "Percentage Used" | awk {'print $3'})

if [[ "$PercentageUsed" = *"%"* ]]; then
    echo "Hard Disk Percentage Used: $PercentageUsed"

    P=$(echo "$PercentageUsed" | sed 's/[^0-9]//g')

else

    PercentageUsed=$(smartctl -a $Hard | grep -E "Percentage_Used" | awk {'print $2'})

    if [[ "$PercentageUsed" = *"%"* ]]; then
        echo "Hard Disk Percentage Used: $PercentageUsed"

        P=$(echo "$PercentageUsed" | sed 's/[^0-9]//g')

    fi

fi

P=$((P))

if [ "$P" -ge "1" ]; then
    HardDiskHealth=$((100 - $P))
    echo "Hard Disk Health: ${HardDiskHealth}%"
fi
