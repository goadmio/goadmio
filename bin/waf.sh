#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/waf "$@"
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

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

if [ "$1" = "reset" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo "[$N/$C] Bulk Unbocking [$Domain]..."

            ZoneID=$(GetZoneID "$Domain")

            # Remove custom rules (Max custom rules: 5)
            for DeleteNo in {1..5}; do

                # Make it Unused
                Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules?mode=block" \
                    -H "Authorization: Bearer $APIToken" \
                    -H "Content-Type: application/json")

                ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | head -1)

                if [[ ! "$ID" = "" ]]; then

                    sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules/$ID" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json"

                fi

            done

            for DeleteNo in {1..5}; do

                # Delete Filter
                Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/filters" \
                    -H "Authorization: Bearer $APIToken" \
                    -H "Content-Type: application/json")

                ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | head -1)

                if [[ ! "$ID" = "" ]]; then

                    sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/filters/$ID" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json"

                fi

            done

        fi

    done

    exit 1

fi

if [ $# -eq 1 ]; then

    Domain="all"
    IP=$1

else

    Domain=$1
    IP=$2

fi

if [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo "[$N/$C] Blocking IP $IP [$Domain]..."

            ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

            sudo curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data "{\"mode\": \"block\",\"configuration\": {\"target\": \"ip\",\"value\": \"$IP\"},\"notes\": \"Blocking IP due to malicious activity\"}"

        fi

    done

else

    if sudo test -d "/home/$Domain/www" ; then

        echo "Blocking IP $IP [$Domain]..."

        ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

        sudo curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"mode\": \"block\",\"configuration\": {\"target\": \"ip\",\"value\": \"$IP\"},\"notes\": \"Blocking IP due to malicious activity\"}"

    fi

fi
