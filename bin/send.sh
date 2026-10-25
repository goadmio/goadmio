#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

TimeStamp=$(date +'%s')

if sudo test -f /usr/local/goadmio/tmp/wa.db ; then
    LockStamp=$(</usr/local/goadmio/tmp/wa.db)
    Diff=$((TimeStamp - LockStamp))
    Wait=$((50 - $Diff))

    if [ "$Diff" -lt "50" ]; then
        echo "Please wait $Wait seconds"
        exit 1
    fi
fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)
AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
AlternativeAdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AlternativeAdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

Err=0

if ! command -v npx &>/dev/null; then
    sudo /go/nodejs
    exit 1
fi

if sudo test -f "/etc/wa" ; then
    DBName=$(</etc/wa)
else
    DBName="crm"
fi

TimeStamp=$(date +'%s')

# Add Fo lder Names to Array
FolderArray=("/whatsapp/"*)
FolderArray=($(shuf -e "${FolderArray[@]}"))

Sent=0
N=0

# SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT CONCAT(ID,'|',Mobile,'|',Subject,'|',Message) from $DBName.Whatsapp where ID>=1 ORDER BY Priority DESC,ID DESC limit 15;")
SQL=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT CONCAT(ID,'|',Mobile,'|',Subject,'|',Message) from $DBName.Whatsapp where CID=2 ORDER BY ID ASC limit 15;")
while read -r Result; do

    IFS='|' read -r -a Row <<<"$Result"

    ID="${Row[0]}"
    To="${Row[1]}"
    Subject="${Row[2]}"
    Message="${Row[3]}"

    ID=$(printf "%.0f" "$ID")

    To=$(echo "$To" | sed "s/[^0-9]//g")

    if [[ "$ID" -gt 0 ]]; then

        if [[ "$To" = 0* ]] || [[ "${#To}" -lt 10 ]]; then

            echo "Invalid mobile number $To"
            sudo mariadb -e "DELETE FROM $DBName.Whatsapp WHERE ID='$ID';"

        else

            Device=""

            # Rotate Folders
            Folder="${FolderArray[0]}"
            FolderArray=("${FolderArray[@]:1}")
            FolderArray+=("$Folder")

            Mobile=$(basename "$Folder")

            Send=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT Send from $DBName.Member where Mobile='$Mobile';")
            Max=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT Max from $DBName.Member where Mobile='$Mobile';")
            T=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT TimeStamp from $DBName.Member where Mobile='$Mobile';")

            Send=$((Send))
            Max=$((Max))
            T=$((T))

            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
            echo "Sender: $Mobile ($Send/$Max)"

            if [[ "$Max" -eq 0 ]]; then

                echo "Mobile $Mobile not have an account"

                sudo mariadb -uroot -p$MySQLRootPassword -N -e "INSERT IGNORE INTO $DBName.Member (BalanceID,FullName,Mobile,OTP,IP,PWD) VALUES ('1','Unknown','$Mobile','000000','$TimeStamp','$TimeStamp')"

            fi

            D=$((TimeStamp - T))

            if [ "$Send" -lt "$Max" ] && [ "$D" -gt "300" ]; then

                if sudo test -d "$Folder" ; then

                    Check=$(npx mudslide send $To "$Message" -c $Folder)

                    # Try Again
                    if [ "$Check" = "" ]; then
                        Check=$(npx mudslide send $To "$Message" -c $Folder)
                    fi

                    if [ "$Check" = "" ]; then

                        Device="$Folder"

                        if sudo test -f $Folder/failed ; then
                            sudo sed -i 's/[0-9]\+/echo $((& + 1))/e' $Folder/failed
                        else
                            echo "0" >$Folder/failed
                        fi

                        Failed=$(<$Folder/failed)
                        if [[ "$Failed" -gt "10" ]]; then
                            sudo rm -rf $Folder
                        fi

                    elif [[ "$Check" = *"error"* ]] || [[ "$Check" != *"Done"* ]]; then

                        Device="$Folder"

                        if sudo test -f $Folder/failed ; then
                            sudo sed -i 's/[0-9]\+/echo $((& + 1))/e' $Folder/failed
                        else
                            echo "0" >$Folder/failed
                        fi

                        Failed=$(<$Folder/failed)
                        if [[ "$Failed" -gt "10" ]]; then
                            sudo rm -rf $Folder
                        fi

                    else

                        N=$(($N + 1))

                        Sent=1

                        if [ "$N" -eq "1" ]; then
                            echo "$TimeStamp" | sudo tee /usr/local/goadmio/tmp/wa.db >/dev/null
                        fi

                        echo "Sending \"$Subject\" To $To (From $Folder)..."

                        sudo mariadb -e "DELETE FROM $DBName.Whatsapp WHERE ID='$ID';"

                        sudo mariadb -uroot -p$MySQLRootPassword -N -e "UPDATE $DBName.Member Set Whatsapp=Whatsapp+1,Send=Send+1,TimeStamp='$TimeStamp' where Mobile='$Mobile';"

                        echo "0" >$Folder/failed

                        sleep 3

                    fi

                fi

                if [ "$Device" != "" ] && [[ "$Err" -eq "0" ]]; then

                    Err=1

                    # /go/sendwhatsapp "*WhatsApp Linked Device Logged Out ($Device)*\n\nWhatsApp device not logged in ($ServerIP)" "Linked Device"

                fi

            fi

        fi

    fi

done <<<"$SQL"

if [ "$N" -eq "0" ] || [ "$Sent" -eq "1" ]; then
    sudo rm -rf /usr/local/goadmio/tmp/wa.db
fi
