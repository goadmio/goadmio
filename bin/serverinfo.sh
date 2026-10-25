#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

DetectDDR() {
    local model
    model=$(lscpu | grep "Model name" | sed -E 's/Model name:\s*//g' | tr '[:upper:]' '[:lower:]')

    case "$model" in
    # DDR5 patterns
    *sapphire* | *emerald* | *granite* | *genoa* | *turin* | *bergamo* | *alder* | *raptor* | *epyc*9*)
        echo "DDR5"
        ;;
    # DDR4 patterns
    *broadwell* | *haswell* | *skylake* | *cascade* | *cooper* | *ice* | *xeon*scalable* | *epyc*7* | *kaby* | *coffee* | *zen*2* | *zen*3*)
        echo "DDR4"
        ;;
    # DDR3 patterns
    *sandy* | *ivy* | *westmere* | *xeon*e5*v1* | *xeon*e5*v2* | *opteron* | *bulldozer* | *piledriver* | *zen*1*)
        echo "DDR3"
        ;;
    *)
        echo ""
        ;;
    esac
}

ServerDiskSpace=$(df -h /home | sed -e /Filesystem/d | awk '{ print $2 }')
ServerDiskUsed=$(df -h /home | sed -e /Filesystem/d | awk '{ print $3 }')
ServerDiskPercent=$(df -h /home | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/%//')

if command -v inxi &>/dev/null; then
    Memory=$(inxi -m -c 0 | grep "RAM:" | sed 's/.*total: \([0-9.]*\).*/\1/')

    if [[ $(free -m | grep Mem | awk '{ print $2 }') -le "1024" ]]; then
        Memory=$(sudo awk "BEGIN {printf \"%.2f\", $Memory / 1024}")
    fi
fi

Memory=$(printf "%.0f" "$Memory")

if [ "$Memory" -eq "0" ]; then
    if [[ $(free -m | grep Mem | awk '{ print $2 }') -le "1024" ]]; then
        Memory=$(free -h | grep Mem | awk '{ print $2 }' | sed 's/Mi//')
        Memory=$(sudo awk "BEGIN {printf \"%.2f\", $Memory / 1024}")
    else
        Memory=$(free -h | grep Mem | awk '{ print $2 }' | sed 's/Gi//')
    fi
fi

MemoryUsed=$(sudo awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%.2f\n", (t-a)/1024/1024}' /proc/meminfo)
MemoryPercent=$(free | awk '/Mem/{printf("%d"), int($3/$2*100)}')

Swap=$(free -h | grep Swap | awk {'print $2'} | sed 's/Gi/GB/i')
Swappiness=$(sudo cat /proc/sys/vm/swappiness)

Cores=$(lscpu -p | grep -v "^#" | cut -d, -f2 | sort -u | wc -l)
Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
CoresUsed=$(sudo awk '{print $1}' </proc/loadavg)
CoresPercent=$(sudo awk "BEGIN {print int($CoresUsed * 100 / $Threads + 0.5 )}")

IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)
Hostname=$(</etc/hostname)
OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

WS=$(</usr/local/goadmio/linux/ws.db)

if [ "$WS" = "Apache" ]; then

    # Apache Version

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        WSVersion=$(httpd -V | grep 'version' | awk '{ print $3 }' | sed 's/[^0-9.]//g')
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
        WSVersion=$(apache2 -v | grep 'Server version' | awk '{print $3}' | cut -d'/' -f2)
    fi

elif [ "$WS" = "NGINX" ]; then
    # NGINX Version
    WSVersion=$(nginx -v 2>&1 | sed "s/[^0-9.]//g")
fi

MariaDBVersion=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT VERSION();" | sed "s/[^0-9.]//g")
PostgreSQLVersion=$(psql -V 2>/dev/null | awk '{print $3}')
SQLiteVersion=$(sudo sqlite3 --version | awk '{print $1}')

Architecture=$(uname -m)
KernelVersion=$(uname -r | cut -d'-' -f1)

Processor=$(sudo grep -m1 -E 'vendor_id|model name' /proc/cpuinfo)

if [[ "$Processor" = *"Intel"* ]]; then
    Processor="Intel"
elif [[ "$Processor" = *"AMD"* ]]; then
    Processor="AMD"
else
    Processor=""
fi

StorageType=$(lsblk -d -o ROTA | tail -n +2 | head -n 1 | awk {'print $1'} | sed 's/0/SSD/' | sed 's/1/HDD/')
NVME=$(lsblk -d -o NAME | tail -n +2 | head -n 1 | awk {'print $1'})
if [[ "$NVME" = *"nvme"* ]]; then
    StorageType="NVMe SSD"
fi

Machine=$(hostnamectl status | grep "Virtualization")
if [[ "$Machine" = *"kvm"* ]]; then
    Virtualization="KVM"
elif [[ "$Machine" = *"openvz"* ]]; then
    Virtualization="OpenVZ"
elif [[ "$Machine" = *"xen"* ]]; then
    Virtualization="Xen"
fi

RAMType=$(dmidecode --type 17 | grep "Type: DDR" | head -1 | awk {'print $2'})

if [ "$RAMType" = "" ]; then
    RAMType=$(DetectDDR)
fi

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET IPv4='$IPv4',IPv6='$IPv6',Hostname='$Hostname'"

echo "$ServerDiskSpace|$ServerDiskUsed|$ServerDiskPercent|$Memory|$MemoryUsed|$MemoryPercent|$Swap|$Swappiness|$Cores|$Threads|$CoresUsed|$CoresPercent|$IPv4|$IPv6|$Hostname|$OS|$VERSION|$WS|$WSVersion|$Virtualization|$MariaDBVersion|$PostgreSQLVersion|$SQLiteVersion|$Architecture|$KernelVersion|$Processor|$StorageType|$RAMType"
