#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/proxy "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if [ "$2" = "1" ] || [ "$2" = "on" ] || [ "$2" = "true" ] || [[ "$@" = *"--on"* ]] || [[ "$@" = *"--enable"* ]]; then
    P="true"
elif [ "$2" = "0" ] || [ "$2" = "off" ] || [ "$2" = "false" ] || [[ "$@" = *"--off"* ]] || [[ "$@" = *"--disable"* ]]; then
    P="false"
else
    G=1
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

PROXY() {
    Domain=$1
    Proxy=$2

    if [ "$Proxy" = "true" ]; then

        Proxy="true"

        if [[ ! "$@" = *"--temporary"* ]]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Proxy=1 where Domain='$Domain'"
        fi

    elif [ "$Proxy" = "false" ]; then

        Proxy="false"

        if [[ ! "$@" = *"--temporary"* ]]; then
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET Proxy=0 where Domain='$Domain'"
        fi

    fi

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

        Response=$(curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"proxied\":$Proxy}")

        Message=$(echo "$Response" | jq -r '.errors[0].message')

        if echo "$Response" | jq -e '.success == true' >/dev/null; then
            echo "$Domain | Success"
        else
            echo "$Domain | $Message"
        fi

        for CNAME in www webmail go; do

            Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=$CNAME.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

            sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json" \
                --data "{\"proxied\":$Proxy}"

        done

    fi

}

if [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
    N=0

    cd /home
    for Domain in *; do

        N=$(($N + 1))

        if [ "$G" = "1" ]; then

            P=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Proxy from Site where Domain='$Domain'")

            if [ "$P" = "0" ]; then
                P="false"
            else
                P="true"
            fi

        fi

        echo "[$N/$C] Proxy $Domain ($P)..."

        PROXY "$Domain" "$P" "$@"

    done

    sudo /go/conf --skip ssl --skip mailssl

else

    if sudo test -d "/home/$Domain/www" ; then

        if [ "$G" = "1" ]; then

            P=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Proxy from Site where Domain='$Domain'")

            if [ "$P" = "0" ]; then
                P="false"
            else
                P="true"
            fi

        fi

        echo "Proxy $Domain ($P)..."

        PROXY "$Domain" "$P" "$@"

        sudo /go/apache $Domain
        sudo /go/nginx $Domain
        sudo /go/reload "| Executed by $(basename "$0")"

    fi

fi
