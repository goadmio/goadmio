#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/checkssl "$@"
fi
echo "$(date +'[%b %d %H:%M:%S]#') $(basename "$0") $@" >>"/var/log/go/$(basename "$0").log"

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

Type="SSL Checker"

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [ "$1" = "count" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain/www ; then

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                Count=$(($(certbot certificates --cert-name "$Domain" 2>/dev/null | grep "Domains:" | awk '{print NF-1}') + 0))

                if [ "$Count" -le "10" ]; then

                    N=$(($N + 1))

                    D=$(sudo certbot certificates --cert-name $Domain 2>/dev/null | grep "Domains:")

                    echo "[$N] $Domain ($Count) - $D"

                    if [[ "$@" = *"--install"* ]]; then
                        sudo /go/ssl $Domain
                    fi

                fi

            fi

        fi

    done

    exit 1

fi

N=0
E=0
P=0
C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

cd /home
for Domain in *; do

    if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain ; then

        N=$(($N + 1))

        Code=$(sudo certbot certificates -d $Domain 2>/dev/null)
        Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
        SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

        if [ "$Days" = "" ]; then

            H=$(curl -sIv https://$Domain 2>&1)

            if [[ ! "$H" = *"verify ok"* ]]; then

                E=$(($E + 1))
                echo -e "\033[0;31mSSL Certificate not installed ($Domain)\033[0m"
                Err="${Err}- SSL Certificate not installed ($Domain)\n"

            else

                E=$(($E + 1))
                echo -e "\033[0;31mCan not verify SSL Certificate ($Domain)\033[0m"
                Err="${Err}- Can not verify SSL Certificate ($Domain)\n"

            fi

        else

            echo "[$N/$C] Checking $Domain ($Days days)..."
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLExpiresOn='$SSLExpiresOn' WHERE Domain='$Domain'"

            if [ "$Days" -le "14" ]; then
                E=$(($E + 1))
                echo "SSL Certificate Expiring in $Days Days ($Domain)"
                Err="${Err}- SSL Certificate Expiring in $Days Days ($Domain)\n"
            fi

            if [ "$Days" -ge "1" ] && [ "$Days" -le "10" ]; then
                # Priority Error
                P=$(($P + 1))
                ErrP="${ErrP}- SSL Certificate Expiring in $Days Days ($Domain)\n"
            fi

            if [ "$Days" -ge "1" ] && [ "$Days" -le "10" ]; then

                if [ "$Days" -ge "1" ] && [ "$Days" -le "3" ]; then
                    rm -rf /etc/letsencrypt/live/$Domain
                    rm -rf /etc/letsencrypt/archive/$Domain
                fi

                sudo /go/ssl $Domain
            
            fi

            SourceCode=$(curl -s -i "https://$Domain")
            if [[ "$SourceCode" = *"</html>"* ]] || [[ "$SourceCode" = *"</body>"* ]]; then
                S=1
            else
                if [[ ! "$SourceCode" = *"cloudflare"* ]]; then
                    echo -e "\033[0;31mSSL Installed but website not responding ($Domain)\033[0m"
                fi
            fi

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                SourceCode=$(curl -s -i "https://webmail.$Domain")
                if [[ "$SourceCode" = *"</html>"* ]] || [[ "$SourceCode" = *"</body>"* ]]; then
                    S=1
                else
                    if [[ ! "$SourceCode" = *"cloudflare"* ]]; then
                        echo -e "\033[0;31mSSL Not Installed for (webmail.$Domain)\033[0m"
                    fi
                fi

                SourceCode=$(curl -s -i "https://go.$Domain")
                if [[ "$SourceCode" = *"</html>"* ]] || [[ "$SourceCode" = *"</body>"* ]]; then
                    S=1
                else
                    if [[ ! "$SourceCode" = *"cloudflare"* ]]; then
                        echo -e "\033[0;31mSSL Not Installed for (go.$Domain)\033[0m"
                    fi
                fi

            fi

        fi

    fi

done

if [ "$P" -gt "0" ]; then

    sudo /go/sendmail "SSL Certificate Checker ($P Domains)" "$ErrP" "SSL Expiry"
    sudo /go/sendwhatsapp "*SSL Certificate Checker ($P Domains)*\n\n$ErrP" "SSL Expiry"

elif [ "$E" -gt "0" ]; then

    sudo /go/sendmail "SSL Certificate Checker ($E Domains)" "$Err" "SSL Checker"
    sudo /go/sendwhatsapp "*SSL Certificate Checker ($E Domains)*\n\n$Err" "SSL Checker"

fi
