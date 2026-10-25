#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/unblock "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# To block 116.10.191.* addresses:
# 116.10.191.0/24

# To block 116.10.*.* addresses:
# 116.10.0.0/16

# To block 116.*.*.* addresses:
# 116.0.0.0/8

IP=$1

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

GetZoneID() {
    Domain="$1"

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

if [ "$1" = "log" ]; then

    cd /var/log/go/block
    for File in *; do

        if sudo test -f /var/log/go/block/$File ; then

            IP=$(basename "$File" .${File##*.})

            if [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$IP" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then

                sudo /go/unblock $IP
                sudo rm -rf /var/log/go/block/$File

            fi

        fi

    done

    exit 1

fi

# Unblock All Blocked IPs for Domain on Cloudflare
if sudo test -d "/home/$1/www" ; then

    Domain=$1

    ZoneID=$(GetZoneID "$Domain")

    if [ "$ZoneID" != "" ]; then

        echo "Unblocking All IPs [$Domain]..."

        Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules?mode=block" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json")

        # Extract all rule IDs
        IDS=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+')

        C=$(echo "$IDS" | wc -l)

        # Loop through each ID and delete
        for ID in $IDS; do

            N=$(($N + 1))

            Status=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules/$ID" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            if [[ "$Status" = *"success"* ]]; then
                echo "[$N/$C] Unblocked rule ID: $ID - Status: Success."
            else
                echo "[$N/$C] Unblocked rule ID: $ID - Status: Failed."
            fi

        done

    fi

    exit 1

fi

if [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ ! $IP =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
    echo "Invalid IP \"$IP\""
    exit 1
fi

sudo curl -s -m 7 "https://go.blackhost.com/file.php?Action=Unblock&IP=$IP" >/dev/null

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "DELETE FROM Block where IP='$IP'"

    # /8
    IP8=$(echo "$IP" | awk -F '.' '{print $1 ".0.0.0/"}')
    # /14 /15 /16
    IP16=$(echo "$IP" | awk -F '.' '{print $1 "." $2 ".0.0/"}')
    # /24 /25 /26
    IP24=$(echo "$IP" | awk -F '.' '{print $1 "." $2 "." $3 ".0/"}')

    echo "Unblocking IP $IP"
    # Get all rich rules containing the IP and remove them
    sudo firewall-cmd --list-rich-rules | grep -E "$IP|$IP8|$IP16|$IP24" | while read Rule; do
        sudo firewall-cmd --permanent --remove-rich-rule="$Rule"
    done

    sudo firewall-cmd --reload

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/block.db "DELETE FROM Block where IP='$IP' and Username='$Username'"
    echo "Unblocking IP $IP"
    sudo ufw allow from $IP to any
    sudo ufw reload

fi

# Unblock via Cloudflare WAF
# Count Websites
C=$(sudo find /home -maxdepth 1 -type d -print | wc -l)
N=0

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        ZoneID=$(GetZoneID "$Domain")

        N=$(($N + 1))
        echo -ne "[$N/$C] Unblocking IP $IP [$Domain] | "

        if [ "$ZoneID" != "" ]; then

            Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules?mode=block&notes=$IP" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | head -1)

            Status=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules/$ID" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            if [[ "$Status" = *"success"* ]]; then

                echo -ne "Success."

            elif [[ "$Status" = *"not_found"* ]]; then

                echo -ne "Not Found."

            else

                echo -ne "Failed."

            fi

        else

            echo -ne "No Zone ID."

        fi

        echo ""

    fi

done

echo ""
