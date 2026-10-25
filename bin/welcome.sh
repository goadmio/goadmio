#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)
Hostname=$(</etc/hostname)

IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

if sudo test -f /var/lib/sqlite/config.db ; then
    GoVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT Version from Config")
    GoVersion=$(echo "$GoVersion" | sed -E 's/([0-9]{2})([0-9])([0-9])([0-9])/\1.\2.\3/')
fi

# Shell Welcome Message
sudo tee /etc/motd < /go/logo.img > /dev/null
echo "" | sudo tee -a /etc/motd >/dev/null
echo "If you have questions or need help, don't hesitate to get in touch." | sudo tee -a /etc/motd >/dev/null
echo "Email: support@goadmio.com" | sudo tee -a /etc/motd >/dev/null
echo "Website: www.goadmio.com" | sudo tee -a /etc/motd >/dev/null
echo "" | sudo tee -a /etc/motd >/dev/null

echo "OS: $OS $VERSION" | sudo tee -a /etc/motd >/dev/null

Machine=$(hostnamectl status | grep "Virtualization")
if [[ "$Machine" = *"kvm"* ]]; then

    echo "Virtualization: KVM" | sudo tee -a /etc/motd >/dev/null

elif [[ "$Machine" = *"openvz"* ]]; then

    echo "Virtualization: OpenVZ" | sudo tee -a /etc/motd >/dev/null

elif [[ "$Machine" = *"xen"* ]]; then

    echo "Virtualization: Xen" | sudo tee -a /etc/motd >/dev/null

fi

echo "IPv4: $IPv4" | sudo tee -a /etc/motd >/dev/null
if [[ "$IPv6" = *":"* ]]; then
    echo "IPv6: $IPv6" | sudo tee -a /etc/motd >/dev/null
fi
echo "Hostname: $Hostname" | sudo tee -a /etc/motd >/dev/null

if [[ "$GoVersion" = *"."* ]]; then
    echo "GoAdmio Version: $GoVersion" | sudo tee -a /etc/motd >/dev/null
fi

echo "" | sudo tee -a /etc/motd >/dev/null

# Check Disk Usage
DiskUsage=$(df -h / | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g')
if [ "$DiskUsage" -ge "90" ]; then

    echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
    echo "Warning: Your disk space is running low (Disk Usage: ${DiskUsage}%)" | sudo tee -a /etc/motd >/dev/null

fi

# Check Memory Usage
MemoryUsage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
MemoryUsage=${MemoryUsage%.*}

if [ "$MemoryUsage" -ge "70" ]; then

    echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
    echo "Warning: Memory Usage ${MemoryUsage}%" | sudo tee -a /etc/motd >/dev/null

fi

CPUThreads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $CPUThreads)}")

if [ "$ServerLoad" -gt "100" ]; then

    echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
    echo "Warning: High load average (Server Load: ${ServerLoad}%)" | sudo tee -a /etc/motd >/dev/null

fi

if sudo test -f /usr/bin/mailq ; then

    MailQueue=$(sudo /usr/bin/mailq | grep -c "^[A-F0-9]")
    if [ "$MailQueue" -ge "100" ]; then

        echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
        echo "Warning: Mail queue has $MailQueue emails" | sudo tee -a /etc/motd >/dev/null

    fi

fi

if command -v ufw &>/dev/null; then

    if [[ $(sudo ufw status | grep -i "25.*DENY.*OUT") = *"25"* ]]; then

        echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
        echo "Warning: Port 25 has been blocked to prevent SPAM issues on your server. To unblock port run \"/go/smtp unblock\"." | sudo tee -a /etc/motd >/dev/null

    fi

fi

if command -v firewall-cmd &>/dev/null; then

    if [[ $(sudo firewall-cmd --permanent --direct --get-rules ipv4 filter OUTPUT | grep -- "--dport 25") = *"25"* ]]; then

        echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
        echo "Warning: Port 25 has been blocked to prevent SPAM issues on your server. To unblock port run \"/go/smtp unblock\"." | sudo tee -a /etc/motd >/dev/null

    fi

fi

echo "────────────────────────────────────────────────────────────────────────────────────────────────────" | sudo tee -a /etc/motd >/dev/null
echo "" | sudo tee -a /etc/motd >/dev/null
