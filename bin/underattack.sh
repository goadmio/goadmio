#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/underattack "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
SecurityLevel=$2

TimeStamp=$(date +'%s')
UnderAttackStamp=$((TimeStamp - 3600))

if [ "$SecurityLevel" = "high" ] || [ "$SecurityLevel" = "false" ] || [ "$SecurityLevel" = "none" ] || [ "$SecurityLevel" = "no" ] || [ "$SecurityLevel" = "off" ] || [ "$SecurityLevel" = "0" ]; then
    SecurityLevel="high"
elif [ "$SecurityLevel" = "medium" ]; then
    SecurityLevel="medium"
else
    SecurityLevel="under_attack"
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

UnderAttack() {
    Domain=$1
    SecurityLevel=$2

    Proxy="true"

    if [ "$Proxy" = "true" ]; then
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0"
    else
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1"
    fi

    if sudo test -d "/home/$Domain/www" ; then

        ZoneID=$(GetZoneID "$Domain")

        # @
        Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Domain&per_page=1&order=type&direction=desc&match=all" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json")

        ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

        sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"proxied\":$Proxy}"

        # www
        Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=www.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json")

        ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

        sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"proxied\":$Proxy}"

        # Security Level: medium | high | under_attack
        sudo curl --silent -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/security_level" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"value\": \"$SecurityLevel\"}"

        echo ""

        if [ "$SecurityLevel" = "under_attack" ]; then

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET UnderAttackStamp='$TimeStamp' where Domain='$Domain'"

        fi

    fi

}

if [ $# -eq 0 ]; then

    # Turn Off
    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain || ',' || UnderAttackStamp from Site where UnderAttackStamp!=0 and UnderAttackStamp<=$UnderAttackStamp;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        Domain="${Row[0]}"
        UnderAttackStamp="${Row[1]}"

        echo "Turn Off Under Attack Mode: $Domain"
        echo $(date +"[%b %d %H:%M:%S]#") "Turn Off Under Attack Mode: $Domain" | sudo tee -a /var/log/go/underattack.log >/dev/null

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET UnderAttackStamp='0' where Domain='$Domain'"

        sudo /go/underattack $Domain medium
        sudo /go/proxy $Domain

    done

    exit 1

fi

if [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo "[$N/$C] $Domain ($SecurityLevel)..."

            UnderAttack "$Domain" "$SecurityLevel"

        fi

    done

else

    if sudo test -d "/home/$Domain/www" ; then

        if [ "$SecurityLevel" = "under_attack" ] && sudo test -f /home/$Domain/www/underattack ; then

            echo "Domain $Domain under attack mode disabled. To enable under attack mode remove file /home/$Domain/www/underattack"

        else

            echo "$Domain ($SecurityLevel)..."
            UnderAttack "$Domain" "$SecurityLevel"

        fi

    fi

fi
