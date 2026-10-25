#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/troubleshoot "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if [[ "$Domain" == "" || Domain = "all" ]]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if sudo test -d /home/$Domain/www ; then

            Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Domain='$Domain',Username='$Username' where Email like '%@$Domain'"

            # Create missing Email from folders
            sudo /go/mail --domain $Domain --action create
            sudo chown -R vmail:vmail /home/$Domain/mail

        fi

    done

else

    if sudo test -d /home/$Domain/www ; then

        Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Domain='$Domain',Username='$Username' where Email like '%@$Domain'"

        # Create missing Email from folders
        sudo /go/mail --domain $Domain --action create
        sudo chown -R vmail:vmail /home/$Domain/mail

        exit 1

    else

        echo "Domain $Domain does not exist"

    fi

fi
