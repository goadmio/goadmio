#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/checkdkim "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if [ $# -eq 0 ]; then

    N=0
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if sudo test -d /home/$Domain/www ; then

            N=$(($N + 1))

            sudo /go/checkdkim $Domain

            printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

        fi

    done

    exit 1

fi

if sudo test -d /home/$Domain/www ; then

    Status=$(sudo opendkim-testkey -d $Domain -s dkim -vvv 2>/dev/null)

    if [[ "$Status" = *"OK"* ]]; then

        DkimLocal=$(sudo grep -oP 'p=\K[^";]*' /etc/opendkim/$Domain/dkim.txt)
        DkimDNS=$(dig TXT dkim._domainkey.$Domain +short | grep -oP 'p=\K[^";]*')

        if [ "$DkimLocal" = "$DkimDNS" ]; then
            echo "$Domain DKIM: Pass"
        else
            echo "$Domain DKIM: Invalid"
        fi

    else
        echo "$Domain DKIM: None"
    fi

fi
