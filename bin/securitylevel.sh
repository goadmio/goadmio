#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/securitylevel "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
SecurityLevel=$2

if [ "$SecurityLevel" = "underattack" ] || [ "$SecurityLevel" = "under_attack" ] || [ "$SecurityLevel" = "under attack" ]; then
    SecurityLevel="under_attack"
elif [ "$SecurityLevel" = "high" ]; then
    SecurityLevel="high"
else
    SecurityLevel="medium"
fi

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

            echo "[$N/$C] $Domain ($SecurityLevel)..."

            ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

            # Security Level: medium | high | under_attack
            sudo curl --silent -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/security_level" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data "{\"value\": \"$SecurityLevel\"}"

            echo ""

        fi

    done

else

    if sudo test -d "/home/$Domain/www" ; then

        echo "$Domain ($SecurityLevel)..."

        ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

        # Security Level: medium | high | under_attack
        sudo curl --silent -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/security_level" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"value\": \"$SecurityLevel\"}"

        echo ""

    fi

fi
