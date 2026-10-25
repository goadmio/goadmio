#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/undelivered "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

TimeStamp=$(date +'%s')

H=$(date +"%H")

if [ "$Domain" != "" ]; then

    if sudo test -d "/home/$Domain/mail" ; then

        echo "Deleting undeliverable emails on domain $Domain"
        sudo find /home/$Domain/mail -type f -exec grep -li "Undelivered" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "Undeliverable" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "delivery failed" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "DELIVERY FAILURE:" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "delivery problems" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "Returned mail" {} \; -delete
        sudo find /home/$Domain/mail -type f -exec grep -li "failure notice" {} \; -delete

    else

        echo "Deleting all undeliverable emails"
        sudo find /home/*/mail -type f -exec grep -li "Undelivered" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "Undeliverable" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "delivery failed" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "DELIVERY FAILURE:" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "delivery problems" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "Returned mail" {} \; -delete
        sudo find /home/*/mail -type f -exec grep -li "failure notice" {} \; -delete

    fi

    exit 1

fi

OUTPUT="|#|Email Account|To|Date|"

sudo rm -rf /usr/local/goadmio/tmp/undelivered.db

Spam=0

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/mail" ; then

        cd /home/$Domain/mail
        for Folder in *; do

            N=0

            Directory="/home/$Domain/mail/$Folder/cur"

            if sudo test -d "$Directory" ; then

                cd $Directory

                # Newest
                unset -v latest
                for File in *; do

                    if sudo test -f "/home/$Domain/mail/$Folder/cur/$File" ; then

                        N=$(($N + 1))

                        Date=$(date -r /home/$Domain/mail/$Folder/cur/$File +"%Y-%m-%d")

                        Name=""
                        ReceiverName=""
                        EmailTo=""

                        To=$(sudo grep "^To: .*$" /home/$Domain/mail/$Folder/cur/$File)
                        To=${To//"To: "/}
                        To=${To//"'"/}
                        To=${To//"\""/}
                        To=${To//"\""/}
                        To=${To//"$Folder@$Domain"/}
                        To=${To//" "/}
                        EmailTo="$To"
                        # Get text between "<" and ">"
                        EmailTo=$(echo "$EmailTo" | cut -d "<" -f2 | cut -d ">" -f1)

                        # TRIM String
                        EmailTo=$(echo $EmailTo | sed -e 's/^[ \t]*//')

                        Subject=$(sudo grep "^Subject: .*>$" /home/$Domain/mail/$Folder/cur/$File)

                        if [ "$EmailTo" = "" ]; then
                            EmailTo="-"
                        fi

                        if [ "$N" -gt "1000" ]; then
                            break
                        fi

                        if grep -q "Undelivered Mail" /home/$Domain/mail/$Folder/cur/$File; then

                            Spam=$(($Spam + 1))

                            OUTPUT="$OUTPUT\n|$Spam|$Folder@$Domain|$EmailTo|$Date|"

                            echo "$EmailTo" | sudo tee -a /usr/local/goadmio/tmp/undelivered.db >/dev/null

                            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/undelivered.db "INSERT OR IGNORE INTO Undelivered (Domain,Email,Date) VALUES ('$Domain','$EmailTo','$Date')"

                        fi

                    fi

                done

            fi

            # NEW

            Directory="/home/$Domain/mail/$Folder/new"

            if sudo test -d "$Directory" ; then

                cd $Directory

                # Newest
                unset -v latest
                for File in *; do

                    if sudo test -f "/home/$Domain/mail/$Folder/new/$File" ; then

                        N=$(($N + 1))

                        Date=$(date -r /home/$Domain/mail/$Folder/new/$File +"%Y-%m-%d")

                        Name=""
                        ReceiverName=""
                        EmailTo=""

                        To=$(sudo grep "^To: .*$" /home/$Domain/mail/$Folder/new/$File)
                        To=${To//"To: "/}
                        To=${To//"'"/}
                        To=${To//"\""/}
                        To=${To//"\""/}
                        To=${To//"$Folder@$Domain"/}
                        To=${To//" "/}
                        EmailTo="$To"
                        # Get text between "<" and ">"
                        EmailTo=$(echo "$EmailTo" | cut -d "<" -f2 | cut -d ">" -f1)

                        # TRIM String
                        EmailTo=$(echo $EmailTo | sed -e 's/^[ \t]*//')

                        Subject=$(sudo grep "^Subject: .*>$" /home/$Domain/mail/$Folder/new/$File)

                        if [ "$EmailFrom" = "" ]; then
                            EmailFrom="-"
                        fi

                        if [ "$N" -gt "1000" ]; then
                            break
                        fi

                        if grep -q "Undelivered Mail" /home/$Domain/mail/$Folder/new/$File; then

                            Spam=$(($Spam + 1))

                            OUTPUT="$OUTPUT\n|$Spam|$Folder@$Domain|$EmailTo|$Date|"

                            echo "$EmailTo" | sudo tee -a /usr/local/goadmio/tmp/undelivered.db >/dev/null

                            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/undelivered.db "INSERT OR IGNORE INTO Undelivered (Domain,Email,Date) VALUES ('$Domain','$EmailTo','$Date')"

                        fi

                    fi

                done

            fi

        done

    fi

done

echo -ne $OUTPUT | column -t -s "|" -o " │ "
