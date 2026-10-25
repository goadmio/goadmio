#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/bandwidth "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

Date=$(date +'%Y-%m-%d')
TimeStamp=$(date +'%s')
TTL=$((TimeStamp - 86400))

Day=$(date +%d)
Month=$(date +%m)
Year=$(date +%Y)

StartMonthStamp=$(date -d "$(date +'%Y-%m-01')" +%s)

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

        Bandwidth=$(sudo awk -F'|' -v Domain="$Domain" -v TTL="$TTL" '$2 == Domain && $6 > TTL {B += $9} END {print B}' $LOG)
        Bandwidth=$((Bandwidth))
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bandwidth.db "INSERT OR IGNORE INTO Bandwidth (Domain,Username,Bandwidth,Date,TimeStamp) VALUES ('$Domain','$Username','$Bandwidth','$Date','$TimeStamp')"
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bandwidth.db "UPDATE Bandwidth SET Bandwidth='$Bandwidth' WHERE Domain='$Domain' and Date='$Date'"

        HTTPBandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bandwidth.db "SELECT SUM(Bandwidth) AS HTTP FROM Bandwidth where Domain='$Domain' and TimeStamp>='$StartMonthStamp'")
        HTTPBandwidth=$(printf "%.0f" "$HTTPBandwidth")

        FTPBandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "SELECT SUM(FileSize) AS FTP FROM Ftplog where Username='$Username' and Date like '%$MonthName $Year%'")
        FTPBandwidth=$(printf "%.0f" "$FTPBandwidth")

        BandwidthUsed=$(($HTTPBandwidth + $FTPBandwidth))

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "update Site SET BandwidthUsed='$BandwidthUsed' where Domain='$Domain'"

    fi

done
