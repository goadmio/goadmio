#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

LockFile="/usr/local/goadmio/lock/backup.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi

Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")
LoadAvg=$(sudo awk '{print $1}' </proc/loadavg)
ServerLoad=$(sudo awk "BEGIN {print int($LoadAvg * 100 / $Threads)}")

CRQ=$(sudo mariadb -e "SELECT CONCAT(ID,'|',USER,'|',DB,'|',COMMAND,'|',TIME,'|',STATE,'|',INFO) AS 'ID|USER|DB|COMMAND|TIME|STATE|INFO' FROM information_schema.PROCESSLIST WHERE DB IS NOT NULL;" | column -t -s "|")
if [ ! "$CRQ" = "" ]; then

    echo "Currently Running Queries:"
    echo "$CRQ"
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

fi

AQ=$(sudo mariadb -e "SELECT CONCAT(User,'|',COUNT(*)) AS 'User|Active Queries' FROM information_schema.processlist GROUP BY USER ORDER BY COUNT(*) DESC LIMIT 10;" | column -t -s "|")
if [ ! "$AQ" = "" ]; then

    echo "Active Queries:"
    echo "$AQ"
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

fi

HCT=$(sudo mariadb -e "SELECT CONCAT(db,'|',COUNT(*)) AS 'Database|Active Queries' FROM information_schema.PROCESSLIST WHERE db IS NOT NULL GROUP BY db ORDER BY SUM(TIME) DESC LIMIT 10;" | column -t -s "|")
if [ ! "$HCT" = "" ]; then

    echo "High CPU Threads:"
    echo "$HCT"
    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

fi

# Slow 100 Queries Run Today (AVG_TIMER_WAIT)
sudo mariadb -e "SELECT CONCAT(SCHEMA_NAME,'|',COUNT_STAR,'|',ROUND(AVG_TIMER_WAIT/1000000000000,6),'|',ROUND(SUM_TIMER_WAIT/1000000000000,6),'|',DIGEST_TEXT,'|',LAST_SEEN) AS 'Database|Exec Count|Avg Exec Time|Sum Exec Time|Query|Last Seen' FROM performance_schema.events_statements_summary_by_digest WHERE DATE(LAST_SEEN) = CURDATE() and SCHEMA_NAME!='NULL' ORDER BY AVG_TIMER_WAIT DESC LIMIT 100;" | column -t -s "|" | sudo tee /var/log/go/mysql/slow-$(date +"%Y-%m-%d").log >/dev/null

# Slowest 100 Queries Run Today (SUM_TIMER_WAIT)
sudo mariadb -e "SELECT CONCAT(SCHEMA_NAME,'|',COUNT_STAR,'|',ROUND(SUM_TIMER_WAIT/1000000000000,6),'|',ROUND(AVG_TIMER_WAIT/1000000000000,6),'|',DIGEST_TEXT,'|',LAST_SEEN) AS 'Database|Exec Count|Sum Exec Time|Avg Exec Time|Query|Last Seen' FROM performance_schema.events_statements_summary_by_digest WHERE DATE(LAST_SEEN) = CURDATE() and SCHEMA_NAME!='NULL' ORDER BY SUM_TIMER_WAIT DESC LIMIT 100;" | column -t -s "|" | sudo tee /var/log/go/mysql/slowest-$(date +"%Y-%m-%d").log >/dev/null

# Top 100 Queries Run Today
sudo mariadb -e "SELECT CONCAT (SCHEMA_NAME,'|',count_star,'|',digest_text) AS 'Database|Exec Count|Query' FROM performance_schema.events_statements_summary_by_digest WHERE last_seen >= CURDATE() and SCHEMA_NAME!='NULL' ORDER BY count_star DESC LIMIT 100;" | column -t -s "|" | sudo tee /var/log/go/mysql/top-$(date +"%Y-%m-%d").log >/dev/null

if [ "$ServerLoad" -ge "100" ]; then

    Name=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT db FROM information_schema.PROCESSLIST WHERE db IS NOT NULL GROUP BY db ORDER BY SUM(TIME) DESC LIMIT 1;")
    Domain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select Domain from Mysql where Name='$Name'")

    echo "Turn On Under Attack Mode: $Domain"
    echo $(date +"[%b %d %H:%M:%S]#") "Turn On Under Attack Mode: $Domain (/go/mysqltop)" | sudo tee -a /var/log/go/underattack.log >/dev/null

    sudo /go/underattack $Domain
    sudo /go/iptop underattack

    sudo /go/sendmail "Under DDoS Attack (CPU: ${ServerLoad}%)" "Website $Domain Under DDoS Attack" "Under Attack"
    sudo /go/sendwhatsapp "*Under DDoS Attack (CPU: ${ServerLoad}%)*\n\nWebsite $Domain Under DDoS Attack" "Under Attack"

elif [ "$ServerLoad" -ge "10" ]; then

    # Check Non-Human
    sudo /go/iptop robot

fi
