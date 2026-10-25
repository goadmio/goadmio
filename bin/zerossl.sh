#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
APIKey=$2

if sudo test -d "/etc/ssl/$Domain" ; then

    cd /etc/ssl/$Domain

else

    echo "Directory /etc/ssl/$Domain"
    exit 1

fi

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

sudo openssl req -new -newkey rsa:2048 -nodes -out $Domain.csr -keyout privkey.pem -subj "/C=GB/ST=London/L=London/O=Example/OU=Testing/CN=$Domain" &>/dev/null

# Draft certificate at ZeroSSL
Code=$(curl -s -X POST https://api.zerossl.com/certificates?access_key="$APIKey" \
    --data-urlencode certificate_csr@$Domain.csr \
    -d certificate_domains="$Domain" \
    -d certificate_validity_days=90)

if [[ "$Code" = *"certificate_limit_reached"* ]]; then
    echo "Certificate Limit Reached"
    exit 1
fi

if [[ "$Code" = *"duplicate_certificates_found"* ]]; then
    echo "Duplicate Certificates Found"
    exit 1
fi

if [[ "$Code" = *"missing_access_key"* ]]; then
    echo "Missing Access Key"
    exit 1
fi

if [[ "$Code" = *"invalid_access_key"* ]]; then
    echo "Invalid Access Key"
    exit 1
fi

ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

if [ "$ID" = "" ]; then

    echo "Can not get SSL Domain ID"
    exit 1

fi

echo "Domain: $Domain"
echo "ID: $ID"

HOST=$(echo "$Code" | grep -oP '\"cname_validation_p1\":"\K[^"]+' | head -1)
VALUE=$(echo "$Code" | grep -oP '\"cname_validation_p2\":"\K[^"]+' | head -1)

ZoneID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select ZoneID FROM Site where Domain='$Domain'")

sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
    -H "Authorization: Bearer $APIToken" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"CNAME\",\"name\":\"$HOST\",\"content\":\"$VALUE\",\"ttl\":3600,\"proxied\":false}"

echo "Validate certificate at ZeroSSL..."
sleep 30
sudo curl --silent --output /dev/null -X POST "https://api.zerossl.com/certificates/$ID/challenges?access_key=$APIKey" \
    -d validation_method=CNAME_CSR_HASH
sleep 30

sudo rm -rf /etc/ssl/$Domain/certificate.zip
sudo curl -X GET "https://api.zerossl.com/certificates/$ID/download?access_key=$APIKey" -o certificate.zip

if unzip -t "certificate.zip" >/dev/null; then
    sudo unzip certificate.zip
else

    Check=$(</etc/ssl/$Domain/certificate.zip)

    if [[ "$Check" = *"certificate_not_issued"* ]]; then

        echo "Certificate Not Issued"

    elif [[ "$Check" = *"invalid_api_function"* ]]; then

        echo "Invalid API Function"

    else

        echo "The ZIP file is invalid or corrupted."

    fi

    exit 1

fi

if sudo test -f "certificate.crt"  && sudo test -f "ca_bundle.crt" ; then

    sudo rm -rf cert.pem
    sudo rm -rf bundle.pem

    sudo cp certificate.crt /etc/ssl/$Domain/cert.pem
    sudo cp ca_bundle.crt /etc/ssl/$Domain/bundle.pem

    sudo /go/conf --skip ssl --skip mailssl

fi
