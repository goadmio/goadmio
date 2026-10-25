#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2
Value=$3

SMTPHostname=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SMTPHostname from Config where ConfigID=1")
SMTPHostnameDots=$(sudo grep -o "\." <<<"$SMTPHostname" | wc -l)

ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [[ $@ = *"--setup"* ]]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET DynadotAPIKey='$1'"

    exit 1

fi

DynadotAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select DynadotAPIKey from Config")

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

SPF=$(echo "v=spf1 +a +mx +ip4:$ServerIP ~all" | jq -sRr @uri)

Code=$(sudo cat /etc/opendkim/$Domain/dkim.txt | sed -n '2p')
IFS='"' read -r -a Array <<<"$Code"
DKIM=$(echo "v=DKIM1; k=rsa; ${Array[1]}" | jq -sRr @uri)

if [[ $(ROOTDomain "$Domain") = "1" ]]; then

    sudo curl -X GET "https://api.dynadot.com/api3.xml?key=$DynadotAPIKey&command=set_dns2&domain=$Domain&main_record_type0=a&main_record0=$ServerIP&main_record_type1=mx&main_record1=imap.$Domain&main_recordx1=0\
&sub_record_type0=cname&sub_record0=$Domain&subdomain0=*\
&sub_record_type1=cname&sub_record1=$Domain&subdomain1=www\
&sub_record_type2=cname&sub_record2=$Domain&subdomain2=go\
&sub_record_type3=cname&sub_record3=$Domain&subdomain3=ftp\
&sub_record_type4=cname&sub_record4=$Domain&subdomain4=webmail\
&sub_record_type5=cname&sub_record5=$Domain&subdomain5=imap\
&sub_record_type6=cname&sub_record6=$Domain&subdomain6=smtp\
&sub_record_type7=cname&sub_record7=$Domain&subdomain7=m\
&sub_record_type8=txt&sub_record8=$SPF&subdomain8=$Domain&sub_record_type9=txt&sub_record9=$DKIM&subdomain9=dkim._domainkey\
"

else

    # Subdomain
    Subdomain="$Domain"
    Domain=$(echo "$Subdomain" | sed 's/^[^.]*.//')

    String=$(echo "$Subdomain" | cut -d'.' -f1)

    sudo curl -X GET "https://api.dynadot.com/api3.xml?key=$DynadotAPIKey&command=set_dns2&domain=$Domain&add_dns_to_current_setting=1\
&sub_record_type0=a&sub_record0=$ServerIP&subdomain0=$String"

fi

echo ""
