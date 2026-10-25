#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/checkmx "$@"
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

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        # Count MX Records
        CountMX=$(dig +noall +answer -t mx $Domain | wc -l)

        MXPriority=$(dig +noall +answer -t mx $Domain | awk '{print $5}')

        if [[ "$CountMX" -eq "0" ]]; then

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                echo -e "\e[0;31mNo MX Record: Please add MX for domain ${Domain}\e[0m"

            fi

        elif [[ "$CountMX" -eq "1" ]]; then

            if [ "$MXPriority" != "0" ] && [ "$MXPriority" != "1" ]; then

                echo -e "\e[0;31mInvalid MX priority ($MXPriority): Please change MX priority to 0 for domain ${Domain}\e[0m"

            fi

        fi

    fi

done
