#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/purge "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

GetZoneID() {
    Domain=$1

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

Domain=$1
AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

if [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo "[$N/$C] Purge Everything for $Domain..."

            ZoneID=$(GetZoneID "$Domain")

            sudo curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/purge_cache" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data '{"purge_everything":true}'

        fi

    done

else

    if sudo test -d "/home/$Domain/www" ; then

        echo "[$N/$C] Purge Everything for $Domain..."

        ZoneID=$(GetZoneID "$Domain")

        sudo curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/purge_cache" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data '{"purge_everything":true}'

    fi

fi
