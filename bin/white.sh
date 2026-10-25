#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/white "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

IP=$1

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [ "$IP" = "" ]; then
    IP="$ServerIP"
fi

GetZoneID() {
    Domain=$1

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

# Only 2 Parts TLDs & Ends With .??? or More
TLDs=(".in.net" ".com.museum")
ROOTDomain() {
    TLDDomain=$1
    TLDDomain=$(echo "$TLDDomain" | xargs)

    Dots=$(sudo grep -o "\." <<<"$TLDDomain" | wc -l)
    if [[ "$Dots" -eq "1" ]]; then
        echo "1"
        return
    fi

    # All 2 Parts TLDs ends with ".??"
    TLDDomain=$(echo "$TLDDomain" | sed -E 's/\.(ac|am|av|co|dr|ed|gc|gg|go|gr|id|lg|me|ms|ne|or|pe|re|tm|tv|adm|adv|agr|arq|art|aso|asn|ato|bel|bio|bmd|biz|cim|cng|cnt|com|dni|ecn|edu|eng|eti|fnd|fot|fst|gen|gob|gov|imb|ind|inf|int|iwi|jor|lel|ltd|mat|med|mil|mod|msk|mus|net|nhs|nom|not|ntr|odo|org|plc|pol|prd|pro|psc|psi|qsl|rec|res|sch|slg|spb|srv|tmp|trd|tur|vet|web|zlg|blog|firm|flog|geek|govt|info)\.[a-zA-Z]{2}$//')

    for TLD in "${TLDs[@]}"; do
        TLDDomain=$(echo "$TLDDomain" | sed "s/$TLD//g")
    done

    Dots=$(sudo grep -o "\." <<<"$TLDDomain" | wc -l)

    if [ "$Dots" -ge "1" ]; then
        # Subdomain
        echo "0"
    else
        # Main Domain
        echo "1"
    fi

}

if sudo test -f /var/go/etc/white ; then

    if grep -Fxq "$IP" /var/go/etc/white; then
        echo "IP $IP found"
        exit 1
    fi

    if [[ "$IP" =~ ^[0-9] ]]; then
        sudo sed -i "/^$IP/d" /var/go/etc/white
    fi

fi

if [[ "$IP" =~ ^[0-9] ]]; then

    echo "$IP" | sudo tee -a /var/go/etc/white >/dev/null

fi

# Count Websites
C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
N=0

cd /home
for Domain in *; do

    if [[ "$Domain" = *"."* ]]; then

        if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                N=$(($N + 1))

                ZoneID=$(GetZoneID "$Domain")

                if [ "$ZoneID" = "" ]; then

                    echo "[$N/$C] Cannot Get Zone ID for $Domain..."

                else

                    echo "[$N/$C] Allow $IP for $Domain..."

                    # Allow Server IP (AlLOW CURL & GET FILE CONTENT)
                    sudo curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "{\"mode\": \"whitelist\",\"configuration\": {\"target\": \"ip\",\"value\": \"$IP\"},\"notes\": \"Allow Server IP\"}"

                    echo ""

                fi

            else

                echo "[$N/$C] $Domain (Subdomain)..."

            fi

        fi

    fi

done

/go/fail2ban