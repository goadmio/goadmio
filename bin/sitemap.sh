#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/sitemap "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

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

ServerIP=$(curl -s -4 checkip.amazonaws.com)
N=0
sudo /go/memorylimit -1

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www/module/property" ; then

        if [[ $(ROOTDomain "$Domain") = "1" ]]; then

            N=$(($N + 1))

            Proxy=0
            if [[ ! $(dig $Domain +short | tail -n1) = "$ServerIP" ]]; then

                echo "Change Proxy to Off $Domain..."
                sudo /go/proxy $Domain 0 --temporary
                sleep 10

                Proxy=1

            fi

            echo "[$N] Creating Sitemap $Domain..."

            ScriptUrl=$(sudo grep -oP 'ScriptUrl="\K[^"]+' /home/$Domain/www/include/config/config.php)

            sudo find /home/$Domain/www -maxdepth 1 -type f -name "*.xml" ! -name "BingSiteAuth.xml" -exec rm -f {} +

            echo "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=mls&Language=En&Service=Property"
            sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=mls&Language=En&Service=Property" >/dev/null

            echo "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=mls&Language=Ar&Service=Property"
            sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=mls&Language=Ar&Service=Property" >/dev/null

            echo "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=location&Language=En&Service=Property"
            sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=location&Language=En&Service=Property" >/dev/null

            echo "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=location&Language=Ar&Service=Property"
            sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" "$ScriptUrl/admin/iframe/sitemap.php?Sitemap=location&Language=Ar&Service=Property" >/dev/null

            if [ "$Proxy" -eq "1" ]; then
                sudo /go/proxy $Domain
            fi

        fi

    fi

done
