#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)
Hostname=$(</etc/hostname)

DomainNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "SELECT COUNT(*) from Site")

if [[ "$Hostname" = "smtp."* ]]; then

    IMAPHostname="${Hostname/smtp./imap.}"

    if [ $(dig $IMAPHostname +short | tail -n1) = "$ServerIP" ]; then
        echo "$IMAPHostname" | sudo tee /etc/imap >/dev/null
    else
        echo "$Hostname" | sudo tee /etc/imap >/dev/null
    fi

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

if sudo test -f /etc/imap ; then

    IMAPHostname=$(</etc/imap)

else

    IMAPHostname="$Hostname"

fi

HostnameDots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)
IMAPHostnameDots=$(sudo grep -o "\." <<<"$IMAPHostname" | wc -l)

# creating SSL Cert
sudo mkdir -p /etc/postfix/ssl
cd /etc/postfix/ssl/
sudo openssl genrsa -des3 -rand /etc/hosts -out smtpd.key -passout pass:6000 1024 &>/dev/null
sudo chmod 600 smtpd.key
sudo openssl req -new -key smtpd.key -out smtpd.csr -passin pass:6000 -subj "/CN=$Hostname/O=My Company Name LTD./C=EG"
sudo openssl x509 -req -days 365 -in smtpd.csr -signkey smtpd.key -out smtpd.crt -passin pass:6000 &>/dev/null
sudo openssl rsa -in smtpd.key -out smtpd.key.unencrypted -passin pass:6000 &>/dev/null
sudo mv -f smtpd.key.unencrypted smtpd.key
sudo openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -passout pass:6000 -days 365 -subj "/CN=$Hostname/O=My Company Name LTD./C=EG" &>/dev/null

if [ "$WS" = "NGINX" ]; then

    Plugin="--nginx"

else

    Plugin="--apache"

fi

if sudo test -d "/etc/letsencrypt/live/$Hostname" ; then

    Code=$(sudo certbot certificates -d $Hostname 2>/dev/null)
    Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
    Days=${Days:-0}

    if [ "$Days" -le "7" ] && [[ "$Hostname" = *"."* ]]; then

        sudo rm -rf /etc/letsencrypt/live/$Hostname

        if [[ "$IMAPHostname" = *"."* ]]; then
            sudo rm -rf /etc/letsencrypt/live/$IMAPHostname
        fi

        sudo /go/go

    fi

fi

if sudo test ! -d "/etc/letsencrypt/live/$Hostname" || [[ $@ = *"--force"* ]]; then

    if [ "$HostnameDots" -ge "2" ] && [ "$IMAPHostnameDots" -ge "2" ]; then

        if [ "$Hostname" = "$IMAPHostname" ]; then

            echo "Installing SSL Certificates on SMTP/IMAP Server Hostname $Hostname..."

            sudo certbot delete --noninteractive --quiet --cert-name $Hostname &>/dev/null
            sudo certbot delete --noninteractive --quiet --cert-name $Hostname-* &>/dev/null
            sudo certbot $Plugin certonly --noninteractive --quiet --agree-tos --email info@$Hostname -d $Hostname --cert-name $Hostname

            Code=$(sudo certbot certificates -d $Hostname 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

            if [[ "$Days" =~ ^[0-9]+$ ]]; then

                echo "SSL Certificate Installed Successfully for Hostname ($Hostname - 3 Months)..."

                sudo /go/go
                sudo /go/reload "| Executed by $(basename "$0")"

            else

                echo "Error: Can not Install SSL Certificate for Hostname ($Hostname)..."

            fi

        else

            echo "Installing SSL Certificates on SMTP/IMAP Server Hostname ($Hostname and $IMAPHostname)..."

            sudo certbot delete --noninteractive --quiet --cert-name $Hostname &>/dev/null
            sudo certbot delete --noninteractive --quiet --cert-name $Hostname-* &>/dev/null
            sudo certbot $Plugin certonly --noninteractive --quiet --agree-tos --email info@$Hostname -d $Hostname -d $IMAPHostname --cert-name $Hostname

            Code=$(sudo certbot certificates -d $Hostname 2>/dev/null)
            Days=$(echo "$Code" | grep days | awk '{print $6}' | tail -1)
            SSLExpiresOn=$(echo "$Code" | grep days | awk '{print $3}' | tail -1)

            if [[ "$Days" =~ ^[0-9]+$ ]]; then

                echo "SSL Certificate Installed Successfully for Hostname ($Hostname and $IMAPHostname - 3 Months)..."

                sudo /go/go
                sudo /go/reload "| Executed by $(basename "$0")"

            else

                echo "Error: Can not Install SSL Certificate for Hostname ($Hostname and $IMAPHostname)..."

            fi

        fi

        printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

    fi

fi

if [ "$DomainNo" -ge "1" ]; then
    sudo /go/vmail
fi
