#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/delcache "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)

if [[ ! $@ = *"--force"* ]]; then

    DU=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | grep -oP '\d+')

    if [ "$DU" -gt "90" ]; then

        echo "Free Disk Space Percentage: $DU%"

        sudo /go/delcache smart --force

        exit 1

    fi

    CPUThreads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
    LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
    ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $CPUThreads)}")

    if [ "$ServerLoad" -gt "75" ]; then

        echo "Server Load Percentage: $ServerLoad%"
        echo "Deleting cache not recommended now."

        exit 1

    fi

    # Check Memory Usage
    MemoryUsage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    MemoryUsage=${MemoryUsage%.*}

    if [ "$MemoryUsage" -gt "75" ]; then

        echo "Memory Usage Percentage: $MemoryUsage%"
        echo "Deleting cache not recommended now."

        exit 1

    fi

fi

if [[ ! $@ = *"--force"* ]]; then

    if [[ "$Hostname" = *".mls.eg"* ]] || [[ "$Hostname" = *".mls.com.eg"* ]] || [[ "$Hostname" = *".mlseg.com"* ]] || [[ "$Hostname" = *"propertyads"* ]] || [[ "$Hostname" = *"mlsrealty"* ]] || [[ "$Hostname" = *"4crm.net"* ]]; then

        echo "Please wait..."

    else

        echo "Clear Cache not Allowed on $Hostname."

        exit 1

    fi

fi

if [ $# -eq 0 ]; then

    echo "1) All HTML Files"
    echo "2) index.html"
    echo "3) index.html & List & Location (City & District)"
    echo "4) ORN"
    echo "5) 30 Days Ago"
    echo "6) Invalid"

    read -p "Action: " -e Action

else

    Action=$1

fi

if [[ "$Action" = *"."* ]]; then

    echo "Deleting all cache files for domain $1..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /var/cache/$1 /var/cache/$1-$R
    sudo mkdir /var/cache/$1
    sudo chmod 777 /var/cache/$1

    sudo rm -rf /home/$1/www/index.html

    if [[ "$@" = *"--tag"* ]]; then
        sudo find /home/$1/www -maxdepth 1 -type f -name "*-??.html" -exec rm -f {} \;
        sudo find /home/$1/www -maxdepth 1 -type f -name "????????????????????????????????.html" -exec rm -f {} \;
    else
        # Keep TAG (Fulltext)
        sudo find /home/$1/www -maxdepth 1 -type f -name "*-??.html" ! -name "*-tag-*" -exec rm -f {} \;
    fi

    sudo find /home/$1/www -maxdepth 1 -type f -name "*-.html" -exec rm -f {} \;
    sudo find /home/$1/www -maxdepth 1 -type f -name "????????????????????????????????.html" -exec rm -f {} \;

    sudo rm -rf /var/cache/$1-*

    sudo /go/purge $1

fi

if [ "$Action" = "1" ] || [ "$Action" = "All" ] || [ "$Action" = "all" ]; then

    echo "Deleting all cache files..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo rm -rf /home/*/www/index.html
    sudo find /home/*/www -maxdepth 1 -type f -name "*-.html" -exec rm -f {} \;

    if [ "$@" = "--tag" ]; then
        sudo find /home/*/www -maxdepth 1 -type f -name "*-??.html" -exec rm -f {} \;
        sudo find /home/*/www -maxdepth 1 -type f -name "????????????????????????????????.html" -exec rm -f {} \;
    else
        # Keep TAG (Fulltext)
        sudo find /home/*/www -maxdepth 1 -type f -name "*-??.html" ! -name "*-tag-*" -exec rm -f {} \;
    fi

    sudo rm -rf /home/$1/cache-*

    sudo /go/purge all

fi

if [ "$Action" = "2" ] || [ "$Action" = "index" ] || [ "$Action" = "index.html" ]; then

    echo "Deleting index cache files..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo find /home/*/www -maxdepth 1 -type f \( -name "index.html" -o -name "mls-??.html" \) -exec rm -f {} \;

    sudo rm -rf /home/$1/cache-*

    /bin/systemctl force-reload memcached.service

fi

if [ "$Action" = "3" ] || [ "$Action" = "smart" ] || [ "$Action" = "Smart" ]; then

    echo "Deleting (Smart Cache)..."

    sudo find /home/*/www -maxdepth 1 -type f -name "*-??.html" -mtime +30 -exec rm -f {} \;

    sudo find /home/*/www -maxdepth 1 -type f -name "index.html" -mtime +1 -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-??.html" -mtime +1 -exec rm -f {} \;

    sudo find /home/*/www -maxdepth 1 -type f -name "mls-list*-?-??.html" -mtime +1 -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-district*-?-??.html" -mtime +1 -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-city*-?-??.html" -mtime +1 -exec rm -f {} \;

    sudo find /cache -type f -mtime +7 -exec rm -f {} \;

fi

if [ "$Action" = "3" ] || [ "$Action" = "location" ] || [ "$Action" = "Location" ] || [ "$Action" = "list" ] || [ "$Action" = "List" ]; then

    echo "Deleting location cache files & index files..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo find /home/*/www -maxdepth 1 -type f -name "mls-list*.html" -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-city*.html" -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-district*.html" -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-region*.html" -exec rm -f {} \;

    sudo rm -rf /home/*/www/index.html
    sudo rm -rf /home/*/www/mls-??.html

    sudo rm -rf /home/$1/cache-*

    /bin/systemctl force-reload memcached.service

fi

if [ "$Action" = "4" ]; then

    echo "Deleting ORN cache files..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo rm -rf /home/*/www/mls-orn*-??.html
    /bin/systemctl force-reload memcached.service

    sudo rm -rf /home/$1/cache-*

fi

if [ "$Action" = "weekly" ]; then

    echo "Deleting all cache files from 7 days ago..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo find /home/*/www -maxdepth 1 -type f -name "*-??.html" -mtime +7 -exec rm -f {} \;

    sudo rm -rf /home/$1/cache-*

fi

if [ "$Action" = "5" ] || [ "$Action" = "monthly" ]; then

    echo "Deleting all cache files from 30 days ago..."

    R=$((RANDOM % 1000000 + 1))

    sudo mv /home/$1/cache /home/$1/cache-$R
    sudo mkdir /home/$1/cache
    sudo chmod 777 /home/$1/cache

    sudo rm -rf /home/*/www/index.html
    sudo rm -rf /home/*/www/mls-??.html

    sudo find /home/*/www -maxdepth 1 -type f -name "*-??.html" -mtime +30 -exec rm -f {} \;

    sudo rm -rf /home/$1/cache-*

fi

if [ "$Action" = "6" ]; then

    echo "Deleting invalid cache files..."

    sudo find /home/*/www -maxdepth 1 -type f -name "index.html" -size -20k -exec rm -f {} \;
    sudo find /home/*/www -maxdepth 1 -type f -name "mls-*.html" -size -20k -exec rm -f {} \;

    /bin/systemctl force-reload memcached.service

fi

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        sudo mkdir -p /home/$1/cache
        sudo chmod 777 /home/$1/cache

    fi

done
