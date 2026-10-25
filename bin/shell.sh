#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [[ "$@" = *"--disable"* ]] || [ "$Action" = "0" ]; then
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Shell=0 where Domain='$Domain'"
else

    if [[ "$Domain" = *"."* ]]; then
        sudo rm -rf /home/$Domain/{bin,lib,lib64}
    fi
    
    gpasswd -d $Username Jailed

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Shell=1,JailedShell=0 where Domain='$Domain'"

fi

sudo /go/ssh