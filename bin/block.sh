#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/block "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

Local=0

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

GetZoneID() {
    Domain="$1"

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

IP=$1
Extension=$2

if [ "$IP" = "$IPv4" ] || [ "$IP" = "$IPv6" ]; then
    echo "Cannot block server IP address."
    exit 1
fi

if [ "$Extension" = "" ]; then
    Extension="log"
fi

if [[ "$3" = *"."* ]]; then

    Domain=$3
    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

fi

if [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.0/24$ ]] && [[ ! $IP =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
    echo "Invalid IP \"$IP\""
    exit 1
fi

Country=$(COUNTRY "$IP")

if sudo test -f /var/go/etc/white ; then

    if grep -q "^$IP" /var/go/etc/white; then
        echo "IP $IP is from whitelisted"
        echo "" | sudo tee /var/log/go/block/$IP.white >/dev/null
        exit 1
    fi

    IPString=$(echo "$IP" | awk -F '.' '{print $1 "." $2 "." $3 "\\.\\*"}')

    if grep -q "^$IPString" /var/go/etc/white; then
        echo "IP $IP is from whitelisted"
        echo "" | sudo tee /var/log/go/block/$IP.white >/dev/null
        exit 1
    fi

    IPString=$(echo "$IP" | awk -F '.' '{print $1 "." $2 "\\.\\*"}')

    if grep -q "^$IPString" /var/go/etc/white; then
        echo "IP $IP is from whitelisted"
        echo "" | sudo tee /var/log/go/block/$IP.white >/dev/null
        exit 1
    fi

    IPString=$(echo "$IP" | awk -F '.' '{print $1 "\\.\\*"}')

    if grep -q "^$IPString" /var/go/etc/white; then
        echo "IP $IP is from whitelisted"
        echo "" | sudo tee /var/log/go/block/$IP.white >/dev/null
        exit 1
    fi

fi

if sudo test -f /var/go/etc/whitefiles ; then

    Line="/var/go/etc/whitefiles"
    while IFS= read File; do

        if [ "$File" != "" ]; then

            FileNo=$(sudo awk -F'|' '{ if ($3 == "'"$IP"'" && $11 ~ /'"$File"'/) print $2; else if ($4 == "'"$IP"'" && $11 ~ /'"$File"'/) print $2 }' $LOG | wc -l)

            if [ "$FileNo" -ge 1 ]; then

                echo "$IP access whitelisted file ($File)"

                exit 1

            fi

        fi

    done <"$Line"

fi

Countries=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/country.db "select Code from Country where Whitelist='1';" | tr -d '\r' | tr '\n' ' ' | xargs echo -n)
if [[ ${#Countries} -ge 2 ]]; then

    if [[ ! ${#Country} -eq 2 ]]; then
        echo "Can not Detect a Country Code"
        exit 1
    fi

    if [[ "$Countries" = *"$Country"* ]]; then

        echo "IP $IP ($Country) From Whitelisted Countries ($Countries)"
        exit 1

    fi

fi

if [ "$Extension" = "ssh" ]; then
    sudo curl -s -m 7 "https://go.blackhost.com/file.php?IP=$IP&Hostname=$Hostname&ServerIP=$ServerIP&Type=SSH" >/dev/null
else
    sudo curl -s -m 7 "https://go.blackhost.com/file.php?IP=$IP&Hostname=$Hostname&ServerIP=$ServerIP&Type=BOT" >/dev/null
fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    TimeStamp=$(date +'%s')

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "INSERT OR IGNORE INTO Block (IP,Country,Domain,Username,TimeStamp) VALUES ('$IP','$Country','$Domain','$Username','$TimeStamp')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ddos.db "DELETE FROM DDos where IP='$IP'"

    if [[ "$IP" = *"."* ]]; then

        if firewall-cmd --zone=public --list-rich-rules 2>/dev/null | grep -q \"$IP\"; then

            Local=1
            echo "Blocking IPv4 $IP ($Country) [Local] (IP Found)..."

        else

            echo "Blocking IPv4 $IP ($Country) [Local]..."

            if [ "$Extension" = "bot" ] || [ "$Extension" = "ssh" ]; then
                sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$IP' drop"
            else
                sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$IP' forward-port port=443 protocol='tcp' to-port=2080"
            fi

            sudo firewall-cmd --reload >/dev/null 2>&1

        fi

    fi

    if [[ "$IP" = *":"* ]]; then

        if firewall-cmd --zone=public --list-rich-rules 2>/dev/null | grep -q \"$IP\"; then

            Local=1
            echo "Blocking IPv6 $IP ($Country) [Local] (IP Found)..."

        else

            echo "Blocking IPv6 $IP ($Country) [Local]..."

            if [ "$Extension" = "bot" ] || [ "$Extension" = "403" ]; then
                sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv6' source address='$IP' drop"
            else
                sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv6' source address='$IP' forward-port port=443 protocol='tcp' to-port=2080" >/dev/null 2>&1
                sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv6' source address='$IP' drop"
            fi

            sudo firewall-cmd --reload >/dev/null 2>&1

        fi

    fi

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    TimeStamp=$(date +'%s')

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "INSERT OR IGNORE INTO Block (IP,Country,Domain,Username,TimeStamp) VALUES ('$IP','$Country','$Domain','$Username','$TimeStamp')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ddos.db "DELETE FROM DDos where IP='$IP'"

    sudo ufw deny from $IP to any

fi

if [[ ! "$Extension" = "ssh" ]] && [[ "$Local" -eq "0" ]]; then

    # Block via Cloudflare WAF
    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            echo -ne "[$N/$C] Blocking IP $IP ($Country) [$Domain] | "

            if [[ $(dig $Domain +short | tail -n1) = "$ServerIP" ]]; then

                ProxyOFFNo=$(($ProxyOFFNo + 1))

                if [ "$ProxyOFFNo" -gt "5" ]; then
                    echo -ne "Proxy Off | Too Many | Break"
                    break
                fi

                echo -ne "Proxy Off."

            else

                if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                    ZoneID=$(GetZoneID "$Domain")

                    if [ "$ZoneID" = "" ]; then

                        echo -ne "No Zone ID."

                    else

                        Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules" \
                            -H "Authorization: Bearer $APIToken" \
                            -H "Content-Type: application/json" \
                            --data "{\"mode\": \"block\",\"configuration\": {\"target\": \"ip\",\"value\": \"$IP\"},\"notes\": \"$IP\"}")

                        if [[ "$Status" = *"created_on"* ]]; then

                            echo -ne "Success."

                        elif [[ "$Status" = *"duplicate"* ]]; then

                            echo -ne "Already Exists."

                        else

                            echo -ne "Failed."

                        fi

                    fi

                else

                    echo -ne "Subdomain."

                fi

            fi

            echo ""

        fi

    done

fi

if [[ "$IP" = *"."* ]] || [[ "$IP" = *":"* ]]; then

    if [[ ! "$IP" = *"/"* ]]; then

        if [ "$Extension" = "bot" ]; then
            Country=$3
            Company=$4
            BotName=$5
            echo "Country: $Country" | sudo tee /var/log/go/block/$IP.$Extension >/dev/null
            echo "Company: $Company" | sudo tee -a /var/log/go/block/$IP.$Extension >/dev/null
            echo "Bot Name: $BotName" | sudo tee -a /var/log/go/block/$IP.$Extension >/dev/null
            sudo grep "|$IP|" $LOG | sudo tee -a /var/log/go/block/$IP.$Extension >/dev/null
        else
            Country=$3
            Company=$4
            echo "Country: $Country" | sudo tee /var/log/go/block/$IP.$Extension >/dev/null
            echo "Company: $Company" | sudo tee -a /var/log/go/block/$IP.$Extension >/dev/null
            sudo grep "|$IP|" $LOG | sudo tee -a /var/log/go/block/$IP.$Extension >/dev/null
        fi

    fi

fi

echo ""
