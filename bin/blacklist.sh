#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/blacklist "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

Action=$1

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

# Colors For Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "$Action" != "reset" ] && [ "$Action" != "remove" ]; then

    if [[ $(sudo find /home -maxdepth 1 -type d -name "*goadmio*" | wc -l) -ge 1 ]]; then

        echo "GoAdmio Website(s) exists"
        sudo find /home -maxdepth 1 -type d -name "*goadmio*"

        exit 1
    fi

fi

# Block Blacklist IPs (Local Firewall)

if [ "$OS" = "Debian" ] || [ "$OS" = "Ubuntu" ]; then
    sudo ufw show added >/usr/local/goadmio/tmp/ufw.db
fi

if [ "$Action" = "reset" ] || [ "$Action" = "remove" ]; then

    sudo /go/firewall reset

else

    if [ $# -eq 0 ] || [ "$1" = "local" ]; then

        N=0
        DDos=$(sudo wget "https://go.blackhost.com/file.php?Action=Blacklist&Type=BOT&Limit=2500" -q -O - | tr -d '\r')
        C=$(echo "$DDos" | wc -l)
        echo -e "${YELLOW}Blocking DDoS Attack ($C IPs)...${NC}"
        while read IP; do

            # TRIM
            IP=$(echo $IP | xargs echo -n)
            IP=$(echo "$IP" | tr -cd 'a-fA-F0-9/:.')

            N=$(($N + 1))

            if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                if ! grep -q "\"$IP\"" /etc/firewalld/zones/public.xml; then

                    if [[ "$IP" = *"."* ]]; then
                        echo "[$N/$C] Blocking IPv4 $IP"
                        sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$IP' reject"
                    fi

                    if [[ "$IP" = *":"* ]]; then
                        echo "[$N/$C] Blocking IPv6 $IP"
                        sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv6' source address='$IP' reject"
                    fi

                fi

            elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                if ! grep -q "from $IP" /usr/local/goadmio/tmp/ufw.db; then

                    if [[ "$IP" = *"."* ]]; then
                        echo "[$N/$C] Blocking IPv4 $IP"
                        sudo ufw deny from $IP to any
                    fi

                    if [[ "$IP" = *":"* ]]; then
                        echo "[$N/$C] Blocking IPv6 $IP"
                        sudo ufw deny from $IP to any
                    fi

                fi

            fi

        done <<<"$DDos"

        N=0
        Datacenter=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/datacenter.db "select Subnet from Datacenter where Block='1' and Subnet like '%.%' LIMIT 2500;" | tr -d '\r')
        C=$(echo "$Datacenter" | wc -l)
        echo -e "${YELLOW}Blocking Datacenter ($C IPs)...${NC}"
        while read IP; do

            # TRIM
            IP=$(echo $IP | xargs echo -n)
            IP=$(echo "$IP" | tr -cd 'a-fA-F0-9/:.')

            N=$(($N + 1))

            if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                if ! grep -q "\"$IP\"" /etc/firewalld/zones/public.xml; then

                    if [[ "$IP" = *"."* ]]; then
                        echo "[$N/$C] Blocking IPv4 $IP"
                        sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$IP' reject"
                    fi

                    if [[ "$IP" = *":"* ]]; then
                        echo "[$N/$C] Blocking IPv6 $IP"
                        sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv6' source address='$IP' reject"
                    fi

                fi

            elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                if ! grep -q "from $IP" /usr/local/goadmio/tmp/ufw.db; then

                    if [[ "$IP" = *"."* ]]; then
                        echo "[$N/$C] Blocking IPv4 $IP"
                        sudo ufw deny from $IP to any
                    fi

                    if [[ "$IP" = *":"* ]]; then
                        echo "[$N/$C] Blocking IPv6 $IP"
                        sudo ufw deny from $IP to any
                    fi

                fi

            fi

        done <<<"$Datacenter"

    fi

fi

if [ $# -eq 0 ] || [ "$1" = "cloudflare" ]; then

    # Block Blacklist IPs & Datacenter IPs (Cloudflare)
    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
    N=0

    BlacklistIP1=$(sudo wget "https://go.blackhost.com/file.php?Action=Blacklist&Type=BOT&Limit=248" -q -O - | tr -d '\r' | tr '\n' ' ')
    BlacklistIP2=$(sudo wget "https://go.blackhost.com/file.php?Action=Blacklist&Type=BOT&Limit=248&From=248" -q -O - | tr -d '\r' | tr '\n' ' ')
    BlacklistIP3=$(sudo wget "https://go.blackhost.com/file.php?Action=Blacklist&Type=BOT&Limit=248&From=496" -q -O - | tr -d '\r' | tr '\n' ' ')
    DatacenterIP1=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/datacenter.db "select Subnet from Datacenter where Block='1' LIMIT 248;" | tr -d '\r' | tr '\n' ' ')
    DatacenterIP2=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/datacenter.db "select Subnet from Datacenter where Block='1' LIMIT 248,248;" | tr -d '\r' | tr '\n' ' ')

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            N=$(($N + 1))

            if [ "$Action" = "reset" ] || [ "$Action" = "remove" ]; then
                echo "[$N/$C] Bulk Unbocking [$Domain]..."
            else
                echo "[$N/$C] Bulk Blocking [$Domain]..."
            fi

            ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

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

            if [ "$Action" != "reset" ] && [ "$Action" != "remove" ]; then

                if [[ "$BlacklistIP1" = *"."* ]]; then
                    # Add
                    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "[
					   {
						 \"action\": \"block\",
						 \"description\": \"Block DDoS Attack IPs (1)\",
						 \"filter\": {
						   \"expression\": \"(ip.src in {$BlacklistIP1})\",
						   \"paused\": false
						 }
					   }
					 ]"

                fi

                if [[ "$BlacklistIP2" = *"."* ]]; then
                    # Add
                    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "[
					   {
						 \"action\": \"block\",
						 \"description\": \"Block DDoS Attack IPs (2)\",
						 \"filter\": {
						   \"expression\": \"(ip.src in {$BlacklistIP2})\",
						   \"paused\": false
						 }
					   }
					 ]"

                fi

                if [[ "$BlacklistIP3" = *"."* ]]; then
                    # Add
                    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "[
					   {
						 \"action\": \"block\",
						 \"description\": \"Block DDoS Attack IPs (3)\",
						 \"filter\": {
						   \"expression\": \"(ip.src in {$BlacklistIP3})\",
						   \"paused\": false
						 }
					   }
					 ]"

                fi

                if [[ "$DatacenterIP1" = *"."* ]]; then

                    # Add
                    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "[
					   {
						 \"action\": \"block\",
						 \"description\": \"Block Datacenter IPs (1)\",
						 \"filter\": {
						   \"expression\": \"(ip.src in {$DatacenterIP1})\",
						   \"paused\": false
						 }
					   }
					 ]"

                fi

                if [[ "$DatacenterIP2" = *"."* ]]; then

                    # Add
                    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/rules" \
                        -H "Authorization: Bearer $APIToken" \
                        -H "Content-Type: application/json" \
                        --data "[
					   {
						 \"action\": \"block\",
						 \"description\": \"Block Datacenter IPs (2)\",
						 \"filter\": {
						   \"expression\": \"(ip.src in {$DatacenterIP2})\",
						   \"paused\": false
						 }
					   }
					 ]"

                fi

            fi

        fi

    done

fi
