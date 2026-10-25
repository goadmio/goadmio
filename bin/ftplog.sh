#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

TimeStamp=$(date +'%s')

FTPLog="/var/log/vsftpd.log"

# Read file starting from the end...
tac $FTPLog | while IFS= read Line; do

    N=$(($N + 1))
    T=$(($TimeStamp - $N))

    Line=${Line/\'/}
    UniqueLog=$(echo -n "$Line" | md5sum)

    IFS=' ' read -r -a Array <<<"$Line"

    Date="${Array[0]} ${Array[2]} ${Array[1]} ${Array[4]}"
    Time="${Array[3]}"

    TransferTime="${Array[5]}"

    IP=$(echo "$Line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

    FileSize="${Array[7]}"
    FileName="${Array[8]}"
    Mode="${Array[9]}"

    if [ "$Mode" = "a" ]; then
        Mode="ASCII"
    fi

    if [ "$Mode" = "b" ]; then
        Mode="Binary"
    fi

    Operation="${Array[10]}"

    if [ "$Operation" = "_" ]; then
        Operation="No Special"
    fi

    Direction="${Array[11]}"

    if [ "$Direction" = "i" ]; then
        Direction="Upload"
    fi

    if [ "$Direction" = "o" ]; then
        Direction="Download"
    fi

    AccessMode="${Array[12]}"

    if [ "$AccessMode" = "a" ]; then
        AccessMode="Anon"
    fi

    if [ "$AccessMode" = "g" ]; then
        AccessMode="Guest"
    fi

    if [ "$AccessMode" = "r" ]; then
        AccessMode="Regular"
    fi

    Username="${Array[13]}"
    Domain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Username='$Username'")

    Completed="${Array[17]}"

    if [ "$Completed" = "c" ]; then
        Completed="Yes"
    fi

    if [ "$Completed" = "i" ]; then
        Completed="No"
    fi

    if [[ "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "INSERT INTO Ftplog (Domain,Username,Date,Time,TransferTime,IP,Country,Descr,FileSize,FileName,Mode,Operation,Direction,AccessMode,Completed,UniqueLog,TimeStamp) VALUES ('$Domain','$Username','$Date','$Time','$TransferTime','$IP','$Country','$Descr','$FileSize','$FileName','$Mode','$Operation','$Direction','$AccessMode','$Completed','$UniqueLog','$T')"
        if [ $? -ne "0" ]; then
            # MySQL error
            echo "Break..."
            break
        fi

    fi

done

# Country
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "select IP from Ftplog where Country='' GROUP BY IP" | sudo tee /usr/local/goadmio/tmp/ftplog.db >/dev/null

File="/usr/local/goadmio/tmp/ftplog.db"
while IFS= read IP; do

    if [[ "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

        Whois=$(WHOIS "$IP")
        Country=$(echo "$Whois" | awk 'tolower($1) == "country:" { print $2;exit }')
        Descr=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="descr"{print $2;exit}')

        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}')

        if [ "$Organization" = "" ]; then
            Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}')
        fi

        Organization=$(echo $Organization | sed -e 's/^[ \t]*//')

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftplog.db "UPDATE Ftplog SET Country='$Country',Descr='$Descr',Organization='$Organization' where IP='$IP'"

    fi

done <"$File"
