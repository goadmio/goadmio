#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/fightmode "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
FightMode=$2

if [ "$FightMode" = "on" ] || [ "$FightMode" = "true" ] || [ "$FightMode" = "1" ]; then
    FightMode="on"
else
    FightMode="off"
fi

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

GetZoneID() {
    Domain=$1

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

if [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo "[$N/$C] $Domain ($FightMode)..."

            ZoneID=$(GetZoneID "$Domain")

            if [ "$FightMode" = "on" ]; then

                # Bot fight mode & Block AI bots
                sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/bot_management" \
                    -H "Authorization: Bearer $APIToken" \
                    -H "Content-Type: application/json" \
                    --data "{\"fight_mode\":true,\"ai_bots_protection\":\"block\"}"

            else

                # Bot fight mode & Block AI bots
                sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/bot_management" \
                    -H "Authorization: Bearer $APIToken" \
                    -H "Content-Type: application/json" \
                    --data "{\"fight_mode\":false,\"ai_bots_protection\":\"disabled\"}"

            fi

        fi

    done

else

    if sudo test -d "/home/$Domain/www" ; then

        echo "$Domain ($FightMode)..."

        ZoneID=$(GetZoneID "$Domain")

        if [ "$FightMode" = "on" ]; then

            # Bot fight mode & Block AI bots
            sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/bot_management" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data "{\"fight_mode\":true,\"ai_bots_protection\":\"block\"}"

        else

            # Bot fight mode & Block AI bots
            sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/bot_management" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data "{\"fight_mode\":false,\"ai_bots_protection\":\"disabled\"}"

        fi

    fi

fi
