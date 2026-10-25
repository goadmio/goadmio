#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/contact "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

TimeStamp=$(date +'%s')

if [ "$Domain" = "" ] || [ "$Domain" = "all" ]; then

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *.* ]]; then

            if sudo test -d "/home/$Domain/mail" ; then
                echo "$Domain Contacts..."
                sudo /go/contact $Domain
            fi

        fi

    done

    exit 1

fi

cd /home/$Domain/mail
for Folder in *; do

    N=0

    Directory="/home/$Domain/mail/$Folder/cur"

    if sudo test -d "$Directory" ; then

        cd $Directory

        # Newest
        unset -v latest
        for File in *; do

            N=$(($N + 1))

            Name=""
            EmailFrom=""
            ReceiverName=""
            EmailTo=""

            From=$(sudo grep "^From: .*>$" /home/$Domain/mail/$Folder/cur/$File)
            From=${From//"From: "/}
            From=${From//">"/}
            From=${From//"'"/}
            From=${From//"\""/}
            IFS='<' read -r -a Array <<<"$From"
            Name="${Array[0]}"
            Name=$(echo $Name | sed -e 's/^[ \t]*//')
            EmailFrom="${Array[1]}"

            To=$(sudo grep "^To: .*>$" /home/$Domain/mail/$Folder/cur/$File)
            To=${To//"To: "/}
            To=${To//">"/}
            To=${To//"'"/}
            To=${To//"\""/}
            IFS='<' read -r -a Array <<<"$To"
            ReceiverName="${Array[0]}"
            ReceiverName=$(echo $ReceiverName | sed -e 's/^[ \t]*//')
            EmailTo="${Array[1]}"

            LYR=$(echo -n $File | md5sum | awk '{print $1}')

            if sudo test -f "/usr/local/goadmio/db/$LYR.db" ; then

                break

            fi

            echo "" | sudo tee /usr/local/goadmio/db/$LYR.db >/dev/null

            if [ "$N" -gt "1000" ]; then

                break

            fi

            if [ "$Name" != "" ] && [[ "$Name" != *"?"* ]] && [[ "$Name" != *"="* ]] && [[ "$Name" != *"Outlook"* ]] && [[ "$Name" != *"Delivery"* ]] && [[ "$EmailFrom" != *"reply"* ]] && [[ "$EmailFrom" != *"notification"* ]] && [[ "$EmailFrom" != *"facebook"* ]] && [[ "$EmailFrom" != *"linkedin"* ]] && [[ "$EmailFrom" != *"twitter"* ]] && [[ "$EmailFrom" = *"@"* ]]; then

                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/contact.db "INSERT OR IGNORE INTO Contact (Domain,Name,EmailFrom,EmailTo,TimeStamp) VALUES ('$Domain','$Name','$EmailFrom','$EmailTo','$TimeStamp')" >/dev/null 2>&1

            fi

        done

    fi

done
