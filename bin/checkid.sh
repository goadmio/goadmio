#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/checkid "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

N=0
Reload=0
C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

cd /home
for Domain in *; do

    if sudo test -d /home/$Domain/www ; then

        Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

        N=$(($N + 1))

        if ! id "$Username" &>/dev/null; then

            echo "Fix $Domain ($Username)"
            sudo sed -i "/^$Username:/d" /etc/shadow

            Reload=1
            sudo /go/adduser $Username

        fi

    fi

done

if [ "$Reload" -eq "1" ]; then

    sudo /go/fpm "| Executed by $(basename "$0")"

fi
