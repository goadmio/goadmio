#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/503 "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

ERROR503() {
    Domain=$1

    if sudo test -d /home/$Domain/www ; then

        sudo rm -rf /home/$Domain/www/503.shtml

        if sudo test ! -f /home/$Domain/www/503.shtml ; then

            sudo cp /usr/local/goadmio/home/503.shtml /home/$Domain/www/503.shtml

        fi

    fi
}

if [ $# -eq 0 ] || [ "$Domain" = "all" ]; then

    cd /home
    for Domain in *; do
        ERROR503 "$Domain"
    done

else

    ERROR503 "$Domain"

fi
