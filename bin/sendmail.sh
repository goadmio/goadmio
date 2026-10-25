#!/bin/bash
# Run in background
if [[ " $* " != *" --bg "* ]]; then
    sudo nohup /go/sendmail --bg "$@" >>/var/log/go/background/sendmail.log 2>&1 &
    exit 0
fi
# Drop --bg so "$@" is the real arguments again
shift   
# End Run in background

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Q=$(sudo /usr/bin/mailq | grep -c "^[A-F0-9]")

Subject=$1
Message=$2
Keyword=$3

TimeStamp=$(date +'%s')

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/log.db "INSERT OR IGNORE INTO Log (Subject,Message,Keyword,TimeStamp) VALUES ('$Subject','$Message','$Keyword','$TimeStamp')"

if command -v firewall-cmd &>/dev/null; then

    if [[ $(firewall-cmd --permanent --direct --get-rules ipv4 filter OUTPUT | grep -- "--dport 25") = *"25"* ]]; then

        echo "Port 25 is blocked."
        exit 1

    fi

fi

Version=$(sudo /usr/sbin/sendmail -d0.1 -bt </dev/null | grep Version | awk '{print $2}')
if [[ ! "$Version" = *"."* ]]; then
    sudo /usr/bin/dnf -y install sendmail
fi

if [ "$Q" -le 100 ]; then

    if [[ "$4" = *"@"* ]]; then
        AdminEmail=$4
    else

        AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")

    fi

    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    Hostname=$(</etc/hostname)

    MemoryUsage=$(free | grep Mem | awk '{print int($3/$2 * 100.0)}')

    Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
    LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
    ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $Threads)}")

    IFS='.' read -r -a Array <<<"$Hostname"

    if [ "${Array[3]}" == "" ]; then

        Domain="${Array[1]}.${Array[2]}"

    else

        Domain="${Array[1]}.${Array[2]}.${Array[3]}"

    fi

    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    DomainIP=$(dig $Domain +short)

    if [ "$DomainIP" = "$ServerIP" ]; then

        SenderEmail="goadmio@$Domain"

    else

        SenderEmail="goadmio@$Hostname"

    fi

    C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "SELECT count(*) FROM Notify WHERE Keyword='$Keyword' and Email='1'")

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/notify.db "UPDATE Notify SET Alert=Alert+1 WHERE Keyword='$Keyword';"

    if [ "$C" -ge "1" ]; then

        if [[ "$AdminEmail" = *"@"* ]]; then

            IFS=',' read -ra EmailArray <<<"$AdminEmail"
            for Email in "${EmailArray[@]}"; do

                # echo -e "$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%\nType: $Keyword" | mailx -s "$Subject" -r "Go Notifications<$SenderEmail>" $Email
                timeout 3s bash -c "echo -e \"$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%\nType: $Keyword\" | mailx -s \"$Subject\" -r \"Go Notifications<$SenderEmail>\" $Email"

            done

        fi

        if [[ "$@" = *"--detect"* ]]; then

            Whois=$(whois $Domain)
            AdminEmail=$(echo "$Whois" | grep -oP '(?<=Admin Email:).*')
            AdminEmail="${AdminEmail//$'\r'/}"
            AdminEmail=$(echo $AdminEmail | sed -e 's/^[ \t]*//')

            if [[ "$AdminEmail" = *"@"* ]]; then

                # echo -e "$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%" | mailx -s "$Subject" -r "Go Notifications<$SenderEmail>" $AdminEmail
                timeout 3s bash -c "echo -e \"$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%\" | mailx -s \"$Subject\" -r \"Go Notifications<$SenderEmail>\" $AdminEmail"

            fi

            TechEmail=$(echo "$Whois" | grep -oP '(?<=Tech Email:).*')
            TechEmail="${TechEmail//$'\r'/}"
            TechEmail=$(echo $TechEmail | sed -e 's/^[ \t]*//')

            if [[ "$TechEmail" = *"@"* ]] && [ "$AdminEmail" != $TechEmail ]; then

                # echo -e "$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%" | mailx -s "$Subject" -r "Go Notifications<$SenderEmail>" $TechEmail
                timeout 3s bash -c "echo -e \"$Message\n\nServer IP: $ServerIP\nHostname: $Hostname\nMemory Usage: ${MemoryUsage}%\nServer Load: ${ServerLoad}%\" | mailx -s \"$Subject\" -r \"Go Notifications<$SenderEmail>\" $TechEmail"

            fi

        fi

    fi

fi
