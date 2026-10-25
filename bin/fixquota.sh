#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/fixquota "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo /go/ftplog

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Day=$(date +%d)
Month=$(date +%m)
Year=$(date +%Y)

MonthName=$(date +%b)

StartMonthStamp=$(date -d "$(date +'%Y-%m-01')" +%s)

TimeStamp=$(date +'%s')

HostingExpired=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/template.db "select Code from Template where Name='Hosting Expired'")

# MySQL Database Size
SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT schema_name FROM information_schema.schemata where schema_name!='performance_schema' and schema_name!='information_schema' and schema_name!='sys';")
for Database in $SQL; do

    Size=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT SUM(DATA_LENGTH + INDEX_LENGTH) AS Size FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$Database';")
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "UPDATE Mysql SET Size='$Size' WHERE Name='$Database';"

done

OUTPUT="Domain Space Bandwidth"

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")

        if [ "$DomainExists" = "$Domain" ]; then

            Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

            MySQLSize=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mysql.db "select sum(Size) from Mysql where Domain='$Domain'")
            MySQLSize=$(printf "%.0f" "$MySQLSize")

            SpaceUsed=$(du -b -s /home/$Domain | awk '{ print $1 }' | sed 's/[^0-9]//g')
            SpaceUsed=$(($SpaceUsed + $MySQLSize))

            MailSpaceUsed=$(du -b -s /home/$Domain/mail | awk '{ print $1 }' | sed 's/[^0-9]//g')

            # HTTPBandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/httplog.db "SELECT SUM(ResponseSize) AS HTTP FROM Httplog where Domain='$Domain' and TimeStamp>='$StartMonthStamp'")
            HTTPBandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bandwidth.db "SELECT SUM(Bandwidth) AS HTTP FROM Bandwidth where Domain='$Domain' and TimeStamp>='$StartMonthStamp'")
            HTTPBandwidth=$(printf "%.0f" "$HTTPBandwidth")

            FTPBandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "SELECT SUM(FileSize) AS FTP FROM Ftplog where Username='$Username' and Date like '%$MonthName $Year%'")
            FTPBandwidth=$(printf "%.0f" "$FTPBandwidth")

            BandwidthUsed=$(($HTTPBandwidth + $FTPBandwidth))

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "update Site SET SpaceUsed='$SpaceUsed',BandwidthUsed='$BandwidthUsed',MailSpaceUsed='$MailSpaceUsed' where Domain='$Domain'"

            DiskSpace=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select DiskSpace FROM Site where Domain='$Domain'")
            DiskSpace=$(printf "%.0f" "$DiskSpace")

            if [ "$SpaceUsed" -ge "$DiskSpace" ] && [ "$DiskSpace" -ne 0 ]; then

                echo "$Domain Disk quota exceeded. disable FTP uploading..."
                echo "write_enable=NO" | sudo tee -a /etc/vsftpd/permission/$Domain >/dev/null
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPUpload=-1 where Domain='$Domain'"

                # Will Send Email Instead Suspend
                # /go/suspend $Domain " | $Domain Disk quota exceeded ($SpaceUsed/$DiskSpace)"

            else

                if sudo test -f "/etc/vsftpd/permission/$Domain" ; then

                    FTPUpload=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select FTPUpload FROM Site where Domain='$Domain'")

                    if [ "$FTPUpload" = "-1" ]; then

                        sudo sed -i "/^download_enable/d" /etc/vsftpd/permission/$Domain
                        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPUpload=1 where Domain='$Domain'"
                        echo "$Domain enable FTP uploading..."

                        sudo /go/unsuspend $Domain

                    fi
                fi

            fi

            Bandwidth=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Bandwidth FROM Site where Domain='$Domain'")

            if [ "$BandwidthUsed" -ge "$Bandwidth" ] && [ "$Bandwidth" -ne 0 ]; then

                echo "Suspend $Domain Bandwidth Limit Exceeded."

                # Will Send Email Instead Suspend
                # /go/suspend $Domain " | $Domain Bandwidth Limit Exceeded ($BandwidthUsed/$Bandwidth)"

            fi

            ExpiresOn=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ExpiresOn from Site where Domain='$Domain'")
            ExpiresOnStamp=$(date -d "$ExpiresOn" +"%s")

            if [ "$TimeStamp" -gt $ExpiresOnStamp ]; then

                echo "Suspend $Domain Web Hosting Expired."
                sudo /go/suspend $Domain " | Suspend $Domain Web Hosting Expired (Expires On: $ExpiresOn)"

            fi

            OUTPUT="$OUTPUT\n$Domain $SpaceUsed $BandwidthUsed"

        fi

    fi

done

echo -ne $OUTPUT | column -t

sudo systemctl restart vsftpd
