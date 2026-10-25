#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

# e0444fee15d2b94251d9c53b
ForwardEmailAPIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ForwardEmailAPIToken FROM Config")

if [ "$ForwardEmailAPIToken" = "" ]; then
    echo "There is no Forward Email API Key"
    exit 1
fi

GetZoneID() {
    Domain=$1

    Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
        -H "Authorization: Bearer $APIToken" \
        -H "Content-Type: application/json")

    ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

    echo "$ZoneID"
}

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")
ServerIP=$(curl -s -4 checkip.amazonaws.com)

AddDomain=$(curl --silent -X POST https://api.forwardemail.net/v1/domains \
    -u "$ForwardEmailAPIToken:" \
    -d "domain=$Domain")

DeletePasswordID=$(curl -s -X GET "https://api.forwardemail.net/v1/domains/$Domain/catch-all-passwords" -u "$ForwardEmailAPIToken:" | jq -r '.[0].id')
DeleteStatus=$(curl --silent -X DELETE "https://api.forwardemail.net/v1/domains/$Domain/catch-all-passwords/$DeletePasswordID" -u "$ForwardEmailAPIToken:")

# Generate Random Passwword
SMTPPass=$(curl --silent -X POST https://api.forwardemail.net/v1/domains/$Domain/catch-all-passwords -u "$ForwardEmailAPIToken:" | jq -r '.password')

# GET DKIM and DMARC
Code=$(curl --silent -X GET "https://api.forwardemail.net/v1/domains/$Domain" -u "$ForwardEmailAPIToken:" -H "Content-Type: application/json")

DKIMName=$(echo "$Code" | jq -r '.smtp_dns_records.dkim.name')
DKIMValue=$(echo "$Code" | jq -r '.smtp_dns_records.dkim.value')
DMARCName=$(echo "$Code" | jq -r '.smtp_dns_records.dmarc.name')
DMARCValue=$(echo "$Code" | jq -r '.smtp_dns_records.dmarc.value')

VerificationCode=$(echo "$Code" | jq -r '.verification_record')
VerificationValue="forward-email-site-verification=$VerificationCode"

ZoneID=$(GetZoneID "$Domain")

if [ "$ZoneID" = "" ]; then
    echo "Cannot Get Cloudflare Zone ID for $Domain..."
    exit 1
fi

Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
    -H "Authorization: Bearer $APIToken" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"TXT\",\"name\":\"$DKIMName\",\"content\":\"$DKIMValue\",\"ttl\":3600,\"proxied\":false}")

sudo /go/cloudflare --domain $Domain --type dmarc --value "$DMARCValue"
sudo /go/cloudflare --domain $Domain --type txt --value "$VerificationValue"

sudo /go/cloudflare --domain $Domain --type cname --name "fe-bounces" --value "forwardemail.net"

sleep 5

# Verify Now
Verify=$(curl --silent -X PUT "https://api.forwardemail.net/v1/domains/$Domain" -u "$ForwardEmailAPIToken:" -H "Content-Type: application/json")

echo "SMTP Password: $SMTPPass"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site set SMTPHost='smtp.forwardemail.net',SMTPUser='goadmio@$Domain',SMTPPass='$SMTPPass',SMTPPort='587',SMTPActive='1' WHERE Domain='$Domain'"

sudo /go/vmail
