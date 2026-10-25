#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/brevo "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

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

Brevo() {
    Domain=$1

    echo "[$N] $Domain"

    # https://app.brevo.com/security/authorised_ips

    ZoneID=$(GetZoneID "$Domain")

    for i in {1..2}; do

        # Delete _dmarc record
        # First, get the DNS record ID for _dmarc.$Domain
        Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=_dmarc.$Domain" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json")

        # Extract ID using jq (recommended) or grep
        if command -v jq &>/dev/null; then
            ID=$(echo "$Code" | jq -r '.result[0].id // empty')
        else
            # Fallback to grep (less reliable)
            ID=$(echo "$Code" | grep -oP '"id":"\K[^"]+' | head -1)
        fi

        # Check if ID was found
        if [ -n "$ID" ] && [ "$ID" != "null" ]; then
            echo "Found _dmarc record with ID: $ID"

            # Delete the record
            DeleteResult=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
                -H "Authorization: Bearer $APIToken" \
                -H "Content-Type: application/json")

            # Check if deletion was successful
            if echo "$DeleteResult" | grep -q '"success":true'; then
                echo "Successfully deleted _dmarc record"
            else
                echo "Failed to delete _dmarc record"
                echo "$DeleteResult"
            fi
        else
            echo "No _dmarc record found for $Domain"
        fi

    done

    # Brevo DKIM 1 CNAME Record
    DomainDASH="${Domain//./-}"
    BrevoDKIM1="b1.${DomainDASH}.dkim.brevo.com"
    BrevoDKIM2="b2.${DomainDASH}.dkim.brevo.com"

    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"CNAME\",\"name\":\"brevo1._domainkey\",\"content\":\"$BrevoDKIM1\",\"ttl\":3600,\"proxied\":false}"

    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"CNAME\",\"name\":\"brevo2._domainkey\",\"content\":\"$BrevoDKIM2\",\"ttl\":3600,\"proxied\":false}"

    # Brevo TXT (DMARC)
    sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"TXT\",\"name\":\"_dmarc\",\"content\":\"v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com\",\"ttl\":3600,\"proxied\":false}"

    # if get BrevoCode one time do not get it again
    if [[ ! "$BrevoCode" = *"brevo"* ]]; then

        Code=$(curl --request POST \
            --url https://api.brevo.com/v3/senders/domains \
            --header 'accept: application/json' \
            --header "api-key: $BrevoAPIKey" \
            --header 'content-type: application/json' \
            --data "{\"name\":\"$Domain\"}")

    fi

    BrevoCode=$(echo "$Code" | jq -r '.dns_records.brevo_code.value')

    if [[ "$BrevoCode" = *"brevo"* ]]; then

        # Brevo TXT (Verification)
        sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
            -H "Authorization: Bearer $APIToken" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"$BrevoCode\",\"ttl\":3600,\"proxied\":false}"

    fi

    Code=$(curl --request PUT \
        --url https://api.brevo.com/v3/senders/domains/$Domain/authenticate \
        --header 'accept: application/json' \
        --header "api-key: $BrevoAPIKey")

    if [[ "$Code" = *"cannot"* ]]; then

        sleep 10

        Code=$(curl --request PUT \
            --url https://api.brevo.com/v3/senders/domains/$Domain/authenticate \
            --header 'accept: application/json' \
            --header "api-key: $BrevoAPIKey")

    fi

}

BrevoAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select BrevoAPIKey FROM Config where ConfigID=1")
BrevoCredit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select BrevoCredit FROM Config where ConfigID=1")

if [ "$1" = "check" ]; then

    if [ ! "$BrevoAPIKey" = "" ]; then

        Credit=$(curl -s -X GET 'https://api.brevo.com/v3/account' \
            -H 'Accept: application/json' \
            -H "api-key: $BrevoAPIKey" |
            jq '.plan[0].credits')

        if [ "$BrevoCredit" = "$Credit" ]; then

            SMTPUser=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail WHERE SentToday>=1 ORDER BY SentToday DESC LIMIT 1")
            SMTPPass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Pass from Mail WHERE Email='$SMTPUser'")

            if [[ "$SMTPUser" = *"@"* ]]; then

                # Send Message Via Global SMTP Relay
                echo "Test Message" | mailx -s "Test Subject" -r "Go <$SMTPUser>" gbp.uae@gmail.com

                sleep 3

                Credit=$(curl -s -X GET 'https://api.brevo.com/v3/account' \
                    -H 'Accept: application/json' \
                    -H "api-key: $BrevoAPIKey" |
                    jq '.plan[0].credits')

                if [ "$BrevoCredit" = "$Credit" ]; then

                    # Deactivate Brevo
                    echo "Deactivate Brevo..."
                    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "UPDATE SMTP SET Active=0 where SMTPHost like '%brevo.com%'"

                    sudo /go/vmail

                else

                    echo "Message Sent | Brevo Working | Credits ($Credit)..."
                    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET BrevoCredit='$Credit' where ConfigID=1"

                fi

            fi

        else

            echo "Brevo Working | Credits ($Credit)..."
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET BrevoCredit='$Credit' where ConfigID=1"

        fi

    fi

    exit 1

fi

if [ "$1" = "config" ]; then

    echo "<?php" | sudo tee /usr/local/goadmio/include/config/brevo.php >/dev/null
    echo "\$BrevoAPIKey=\"$BrevoAPIKey\";" | sudo tee -a /usr/local/goadmio/include/config/brevo.php >/dev/null
    echo "?>" | sudo tee -a /usr/local/goadmio/include/config/brevo.php >/dev/null

    sudo chmod 777 /usr/local/goadmio/include/config/brevo.php

    exit 1

fi

if [ "$1" = "auth" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain ; then

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then

                echo "[$N] Authenticate $Domain..."

                sudo curl --request PUT \
                    --url https://api.brevo.com/v3/senders/domains/$Domain/authenticate \
                    --header 'accept: application/json' \
                    --header "api-key: $BrevoAPIKey"

            fi

        fi

    done

    exit 1

fi

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [[ "$1" = *"."* ]]; then

    Domain=$1
    Brevo "$Domain"

else

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain ; then

            if [[ $(ROOTDomain "$Domain") = "1" ]]; then
                Brevo "$Domain"
            fi

        fi

    done

fi
