#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/ssl "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="$1"

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

CheckCNAME=0

GetZoneID() {
    Domain="$1"

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

CheckCNAMEExists() {
    Domain="$1"

    if [ "$CheckCNAME" -eq "1" ]; then

        Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json")

        ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

        if [ "$ZoneID" != "" ]; then

            CNAME=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            if [[ ! "$CNAME" = *"www.$Domain"* ]]; then
                echo "CNAME Record www.$Domain does not exist"
            fi

            if [[ ! "$CNAME" = *"webmail.$Domain"* ]]; then
                echo "CNAME Record webmail.$Domain does not exist"
            fi

            if [[ ! "$CNAME" = *"go.$Domain"* ]]; then
                echo "CNAME Record go.$Domain does not exist"
            fi

            if [[ ! "$CNAME" = *"smtp.$Domain"* ]]; then
                echo "CNAME Record smtp.$Domain does not exist"
            fi

            if [[ ! "$CNAME" = *"imap.$Domain"* ]]; then
                echo "CNAME Record imap.$Domain does not exist"
            fi

        fi

    fi

}

if [ "$Domain" = "bulk" ] || [ "$Domain" = "--bulk" ]; then

    sudo /go/proxy all off
    sudo /go/conf --force --skip mailssl
    sudo /go/conf --skip mailssl
    sudo /go/conf --limit --skip mailssl
    sudo /go/proxy all on
    exit 1

fi

if [ "$Domain" = "stop" ] || [ "$Domain" = "kill" ]; then

    pkill -9 -f "/usr/bin/certbot"
    sudo rm -f /var/lib/letsencrypt/./usr/bin/certbot.lock

    exit 1

fi

# Only 2 Parts TLDs & Ends With .??? or More
TLDs=(".in.net" ".com.museum")
ROOTDomain() {
    TLDDomain="$1"
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

if [ "$WS" = "Apache" ]; then

    Plugin="--apache"

    if [[ $* = *"--zerossl"* ]]; then
        Plugin="--apache --server https://acme.zerossl.com/v2/DV90"
    fi

else

    Plugin="--nginx"

    if [[ $* = *"--zerossl"* ]]; then
        Plugin="--nginx --server https://acme.zerossl.com/v2/DV90"
    fi

fi

if [[ $* = *"--standalone"* ]] || [[ $* = *"--quick"* ]]; then

    Plugin="--standalone"

    if [[ $* = *"--zerossl"* ]]; then
        Plugin="--standalone --server https://acme.zerossl.com/v2/DV90"
    fi

fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

IP=$(curl -s -4 checkip.amazonaws.com)

if [ "$Domain" = "all" ]; then

    Max=1

    sudo rm -rf /home/*/www/.well-known

    E=0
    N=0
    X=0

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home || exit
    for Domain in *; do

        if sudo test -f "/home/$Domain/www/ssl" ; then

            printf "SKIPPING: SSL certificate installation for $Domain\nReason: File \"ssl\" exists at /home/$Domain/www\nTo install a new SSL certificate:\nRemove existing file: rm -f /home/$Domain/www/ssl\nThen re-run the SSL installation\n"

            echo ""

        elif sudo test -d "/home/$Domain/www" ; then

            if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                APACHE="/etc/httpd/vhost/$Domain.conf"
                APACHESSL="/etc/httpd/vhost/$Domain-le-ssl.conf"

                NGINX="/etc/nginx/vhost/$Domain.conf"
                NGINXSSL="/etc/nginx/vhost/$Domain.conf"

            elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                APACHE="/etc/apache2/vhost/$Domain.conf"
                APACHESSL="/etc/apache2/vhost/$Domain-le-ssl.conf"

                NGINX="/etc/nginx/vhost/$Domain.conf"
                NGINXSSL="/etc/nginx/vhost/$Domain.conf"

            fi

            if [[ "$Domain" = *.* ]]; then

                # For CloudFlare Proxy OR Root Domain
                ZoneID=$(GetZoneID "$Domain")
                if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then

                    if [[ $* = *"--www"* ]]; then
                        Param="-d $Domain -d www.$Domain"
                    elif [[ $* = *"--go"* ]]; then
                        Param="-d $Domain -d www.$Domain -d go.$Domain"
                    elif [[ $* = *"--webmail"* ]]; then
                        Param="-d $Domain -d www.$Domain -d webmail.$Domain"
                    else
                        CheckCNAME=1
                        Param="-d $Domain -d www.$Domain -d go.$Domain -d webmail.$Domain -d smtp.$Domain -d imap.$Domain"
                    fi

                else
                    # Subdomain
                    Param="-d $Domain"
                fi

                SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where Domain='$Domain';")
                for AliasDomain in $SQL; do

                    AliasDomainIP=$(dig "$AliasDomain" +short | tail -n1)
                    if [ "$AliasDomainIP" = "$ServerIP" ]; then
                        Param="$Param -d $AliasDomain"
                    fi

                    AliasDomainIP=$(dig "www.$AliasDomain" +short | tail -n1)
                    if [ "$AliasDomainIP" = "$ServerIP" ]; then
                        Param="$Param -d www.$AliasDomain"
                    fi

                done

                if sudo test ! -d "/etc/letsencrypt/live/$Domain" || [[ $* = *"--force"* ]]; then

                    if sudo test -f "/etc/ssl/$Domain/cert.pem" ; then

                        echo "Paid SSL Certificate already installed."
                        echo "To Delete Paid SSL Certificate Run:"
                        echo "/go/openssl $Domain delete"

                    else

                        X=$(($X + 1))

                        sudo rm -rf "$APACHESSL"
                        sudo rm -rf "$NGINXSSL"

                        sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain" &>/dev/null
                        sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain"-* &>/dev/null

                        sleep 1
                        sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" $Param &>/dev/null
                        Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
                        Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
                        SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

                        if [[ ! $Days =~ ^[0-9]+$ ]]; then

                            # Try Again (All Params)
                            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain" &>/dev/null
                            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain"-* &>/dev/null

                            sleep 1
                            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" $Param &>/dev/null
                            Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
                            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
                            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

                        fi

                        if [[ ! $Days =~ ^[0-9]+$ ]]; then

                            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" -d "$Domain" -d "www.$Domain" &>/dev/null
                            Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
                            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
                            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

                            if [[ "$Days" =~ ^[0-9]+$ ]]; then
                                echo "NOTICE: This certificate will NOT cover (webmail.$Domain & go.$Domain & smtp.$Domain & imap.$Domain)"
                                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"
                            fi

                        fi

                        if [[ ! $Days =~ ^[0-9]+$ ]]; then

                            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" -d "webmail.$Domain" &>/dev/null
                            Code=$(sudo certbot certificates -d "webmail.$Domain" 2>/dev/null)
                            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
                            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

                            if [[ "$Days" =~ ^[0-9]+$ ]]; then
                                echo "NOTICE: This certificate will ONLY cover (webmail.$Domain)"
                                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"
                            fi

                        fi

                        if [[ "$Days" =~ ^[0-9]+$ ]]; then
                            Months=$((($Days + 1) / 30))
                            echo "[$X/$C] SSL Certificate Installed Successfully ($Domain - $Months Months)"
                            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"
                            RELOAD=1
                        else

                            echo "[$X/$C] Error: Can not Install SSL Certificate ($Domain)"

                            if [[ "$@" = *"--create ssl"* ]]; then

                                if sudo test -d "/home/$Domain/www" ; then
                                    echo "" | sudo tee "/home/$Domain/www/ssl" >/dev/null
                                    echo "File /home/$Domain/www/ssl	Created successfully."
                                fi

                            fi

                            DomainIP=$(dig "$Domain" +short | tail -n1)
                            if [ "$DomainIP" = "$ServerIP" ]; then

                                DomainIP=$(dig "www.$Domain" +short | tail -n1)
                                if [ "$DomainIP" != "$ServerIP" ]; then

                                    CheckCNAMEExists "$Domain"

                                    echo "Domain www.$Domain Points To $DomainIP (Expected $ServerIP)"

                                fi

                                DomainIP=$(dig "webmail.$Domain" +short | tail -n1)
                                if [ "$DomainIP" != "$ServerIP" ]; then

                                    CheckCNAMEExists "$Domain"

                                    if [ "$DomainIP" = "" ]; then
                                        echo "Domain webmail.$Domain Does Not Resolve"
                                    else
                                        echo "Domain webmail.$Domain Points To $DomainIP (Expected $ServerIP)"
                                    fi

                                fi

                                DomainIP=$(dig "go.$Domain" +short | tail -n1)
                                if [ "$DomainIP" != "$ServerIP" ]; then

                                    CheckCNAMEExists "$Domain"

                                    if [ "$DomainIP" = "" ]; then
                                        echo "Domain go.$Domain Does Not Resolve"
                                    else
                                        echo "Domain go.$Domain Points To $DomainIP (Expected $ServerIP)"
                                    fi

                                fi

                            else

                                CheckCNAMEExists "$Domain"

                                echo "Domain $Domain Points To $DomainIP (Expected $ServerIP)"

                            fi

                        fi

                        # Create VHOST CONF
                        sudo /go/apache "$Domain"
                        sudo /go/nginx "$Domain"

                        printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

                    fi

                fi

            fi

        fi

    done

    if [ "$RELOAD" = "1" ]; then
        sudo /go/reload "| Executed by $(basename "$0")"
    fi

else

    if sudo test -d "/home/$Domain/www" ; then

        sudo rm -rf "/etc/letsencrypt/archive/$Domain"
        sudo rm -rf "/etc/letsencrypt/live/$Domain"

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

            APACHE="/etc/httpd/vhost/$Domain.conf"
            APACHESSL="/etc/httpd/vhost/$Domain-le-ssl.conf"

            NGINX="/etc/nginx/vhost/$Domain.conf"

            sudo rm -rf "$APACHESSL"
            sudo rm -rf "$NGINX"

        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

            APACHE="/etc/apache2/vhost/$Domain.conf"
            APACHESSL="/etc/apache2/vhost/$Domain-le-ssl.conf"

            NGINX="/etc/nginx/vhost/$Domain.conf"

            sudo rm -rf "$APACHESSL"
            sudo rm -rf "$NGINX"

        fi

        if sudo test -f "/etc/ssl/$Domain/cert.pem" ; then

            echo "Paid SSL Certificate already installed..."
            echo "To Delete Paid SSL Certificate Run:"
            echo "/go/openssl $Domain delete"

            if [[ "$@" = *"--progress"* ]]; then
                echo "1"
            fi

            exit 1

        fi

        # For CloudFlare Proxy OR Root Domain
        ZoneID=$(GetZoneID "$Domain")
        if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then

            if [[ $* = *"--www"* ]] || [[ $* = *"--limit"* ]]; then
                Param="-d $Domain -d www.$Domain"
            elif [[ $* = *"--go"* ]]; then
                Param="-d $Domain -d www.$Domain -d go.$Domain"
            elif [[ $* = *"--webmail"* ]]; then
                Param="-d $Domain -d www.$Domain -d webmail.$Domain"
            else
                CheckCNAME=1
                Param="-d $Domain -d www.$Domain -d go.$Domain -d webmail.$Domain -d smtp.$Domain -d imap.$Domain"
            fi

        else
            # Subdomain
            Param="-d $Domain"
        fi

        SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where Domain='$Domain';")
        for AliasDomain in $SQL; do

            AliasDomainIP=$(dig "$AliasDomain" +short | tail -n1)
            if [ "$AliasDomainIP" = "$ServerIP" ]; then
                Param="$Param -d $AliasDomain"
            fi

            AliasDomainIP=$(dig "www.$AliasDomain" +short | tail -n1)
            if [ "$AliasDomainIP" = "$ServerIP" ]; then
                Param="$Param -d www.$AliasDomain"
            fi

        done

        sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain" &>/dev/null
        sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain"-* &>/dev/null

        sleep 1
        sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" $Param &>/dev/null
        Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
        Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
        SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

        if [[ ! $Days =~ ^[0-9]+$ ]]; then

            # Try Again (All Params)
            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain" &>/dev/null
            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Domain"-* &>/dev/null

            sleep 1
            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" $Param &>/dev/null
            Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

        fi

        if [[ ! $Days =~ ^[0-9]+$ ]]; then

            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" -d "$Domain" -d "www.$Domain" &>/dev/null
            Code=$(sudo certbot certificates -d "$Domain" 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

            if [[ "$Days" =~ ^[0-9]+$ ]]; then

                echo "NOTICE: This certificate will NOT cover (webmail.$Domain & go.$Domain & smtp.$Domain & imap.$Domain)..."
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"

                if [[ "$@" = *"--progress"* ]]; then
                    echo "100"
                fi

            fi

        fi

        if [[ ! $Days =~ ^[0-9]+$ ]]; then

            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Domain" -m "info@$Domain" -d "webmail.$Domain" &>/dev/null
            Code=$(sudo certbot certificates -d "webmail.$Domain" 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

            if [[ "$Days" =~ ^[0-9]+$ ]]; then

                echo "NOTICE: This certificate will ONLY cover (webmail.$Domain)..."
                sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"

                if [[ "$@" = *"--progress"* ]]; then
                    echo "100"
                fi

            fi

        fi

        if [[ "$Days" =~ ^[0-9]+$ ]]; then

            Months=$((($Days + 1) / 30))
            echo "SSL Certificate Installed Successfully ($Domain - $Months Months)..."
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"
            RELOAD=1

            if [[ "$@" = *"--progress"* ]]; then
                echo "100"
            fi

        else

            echo "Error: Can not Install SSL Certificate ($Domain)..."

            if [[ "$@" = *"--progress"* ]]; then
                echo "1"
            fi

            DomainIP=$(dig "$Domain" +short | tail -n1)
            if [ "$DomainIP" = "$ServerIP" ]; then

                DomainIP=$(dig "www.$Domain" +short | tail -n1)
                if [ "$DomainIP" != "$ServerIP" ]; then

                    CheckCNAMEExists "$Domain"

                    echo "Domain www.$Domain Points To $DomainIP (Expected $ServerIP)..."

                    if [[ "$@" = *"--progress"* ]]; then
                        echo "1"
                    fi

                fi

                DomainIP=$(dig "webmail.$Domain" +short | tail -n1)
                if [ "$DomainIP" != "$ServerIP" ]; then

                    CheckCNAMEExists "$Domain"

                    if [ "$DomainIP" = "" ]; then

                        echo "Domain webmail.$Domain Does Not Resolve..."

                        if [[ "$@" = *"--progress"* ]]; then
                            echo "1"
                        fi

                    else

                        echo "Domain webmail.$Domain Points To $DomainIP (Expected $ServerIP)..."

                        if [[ "$@" = *"--progress"* ]]; then
                            echo "1"
                        fi

                    fi

                fi

                DomainIP=$(dig "go.$Domain" +short | tail -n1)
                if [ "$DomainIP" != "$ServerIP" ]; then

                    CheckCNAMEExists "$Domain"

                    if [ "$DomainIP" = "" ]; then

                        echo "Domain go.$Domain Does Not Resolve..."

                        if [[ "$@" = *"--progress"* ]]; then
                            echo "1"
                        fi

                    else

                        echo "Domain go.$Domain Points To $DomainIP (Expected $ServerIP)..."

                        if [[ "$@" = *"--progress"* ]]; then
                            echo "1"
                        fi

                    fi

                fi

            else

                CheckCNAMEExists "$Domain"

                echo "Domain $Domain Points To $DomainIP (Expected $ServerIP)..."

                if [[ "$@" = *"--progress"* ]]; then
                    echo "1"
                fi

            fi

        fi

        # Create VHOST CONF
        sudo /go/apache "$Domain"
        sudo /go/nginx "$Domain"
        sudo /go/reload "| Executed by $(basename "$0")"

    else

        Subdomain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "select Subdomain from Subdomain where Subdomain='$1'")
        if [[ "$Subdomain" = *"."* ]]; then

            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Subdomain" &>/dev/null
            sudo /usr/bin/certbot delete --noninteractive --cert-name "$Subdomain"-* &>/dev/null

            sudo /usr/bin/certbot certonly $Plugin --noninteractive --quiet --agree-tos --cert-name "$Subdomain" -m "info@$Subdomain" -d "$Subdomain" &>/dev/null
            Code=$(sudo certbot certificates -d "$Subdomain" 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

            if [[ "$Days" =~ ^[0-9]+$ ]]; then

                Months=$((($Days + 1) / 30))
                echo "SSL Certificate Installed Successfully ($Subdomain - 3 Months)..."

                sudo /go/apache-subdomain "$Subdomain"
                sudo /go/nginx-subdomain "$Subdomain"

                RELOAD=1

                if [[ "$@" = *"--progress"* ]]; then
                    echo "100"
                fi

            else

                echo "Error: Can not Install SSL Certificate ($Subdomain)..."

            fi

        else

            echo "Domain $Domain does not exist..."

            if [[ "$@" = *"--progress"* ]]; then
                echo "1"
            fi

        fi

    fi

fi

if [[ ! "$@" = *"--skipbackupssl"* ]]; then

    BackupSSL=1
    LockFile="/usr/local/goadmio/lock/backup-ssl.lock"
    if sudo test -f "$LockFile" ; then
        if [[ $(($(date +%s) - $(stat -c %Y "$LockFile" 2>/dev/null))) -le "86400" ]]; then
            BackupSSL=0
        fi
    fi

    if [ "$BackupSSL" -eq "1" ]; then

        echo "Backup SSL..."
        sudo /go/backup ssl

        echo "$(basename "$0")" | sudo tee "$LockFile" >/dev/null

    fi

fi