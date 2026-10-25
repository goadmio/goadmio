#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/expire "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

AdminEmail=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminEmail from Config")
AdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdminMobile from Config")
AlternativeAdminMobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AlternativeAdminMobile from Config")
WAInstanceID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAInstanceID from Config")
WAAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select WAAPIKey from Config")

cd /home
for Domain in *; do

    if sudo test -d "/home/$Domain/www" ; then

        Whois=$(whois $Domain)
        DomainExpiresOn=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="registrar registration expiration date"{print $2;exit}')
        DomainExpiresOn=$(echo $DomainExpiresOn | sed -e 's/^[ \t]*//')
        DomainExpiresOn="${DomainExpiresOn:0:10}"

        if [[ "$DomainExpiresOn" = *"-"* ]]; then

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site set DomainExpiresOn='$DomainExpiresOn' where Domain='$Domain'"

        fi

    fi

done

Date=$(date +'%Y-%m-%d')
MDate=$(date -d "1 month" +"%Y-%m-%d")

SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain || ',' || DomainExpiresOn from Site where DomainExpiresOn<'$MDate';")
for Result in $SQL; do

    IFS=',' read -r -a Row <<<"$Result"

    Domain="${Row[0]}"
    DomainExpiresOn="${Row[1]}"
    let Days=($(date +%s -d $DomainExpiresOn) - $(date +%s -d $Date))/86400

    Mobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Mobile from Site where Domain='$Domain'")

    echo "$Domain Domain Expires On $DomainExpiresOn ($Days days left)"

    Email="info@$Domain"
    sudo /go/sendmail "$Domain Domain Expires On $DomainExpiresOn ($Days days left)" "Dear customer,\n\nThe domain name below will expire within next days.\nRenew now before it's too late!\n\n$Domain : ($Days days left)\n\nTo make sure the domain doesn't expire, renew it now.\n\nIf the domain expires, you will be able to renew it for a maximum of 10 days after the renewal date.\n\nDuring this time, the domain will not be accessible. All the services attached to it will no longer be functional (website, emails, etc.).\n\nBest regards,\nGoAdmio Team\nwww.goadmio.com" "Domain Expiration" "$Email"
    sudo /go/sendwhatsapp "*$Domain Domain Expires On $DomainExpiresOn ($Days days left)*\n\n$Domain Domain Expires On $DomainExpiresOn ($Days days left)" "Domain Expiration"

    if [ "$Mobile" != "" ]; then

        sudo /go/sendwhatsapp "*$Domain Domain Expires On $DomainExpiresOn ($Days days left)*\n\n$Domain Domain Expires On $DomainExpiresOn ($Days days left)" "Domain Expiration"

    fi

done

SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain || ',' || ExpiresOn from Site where ExpiresOn<'$MDate';")
for Result in $SQL; do

    IFS=',' read -r -a Row <<<"$Result"

    Domain="${Row[0]}"
    ExpiresOn="${Row[1]}"
    let Days=($(date +%s -d $ExpiresOn) - $(date +%s -d $Date))/86400

    Mobile=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Mobile from Site where Domain='$Domain'")

    echo "$Domain Hosting Expires On $ExpiresOn ($Days days left)"

    Email="info@$Domain"
    sudo /go/sendmail "$Domain Hosting Expires On $ExpiresOn ($Days days left)" "Dear Customer,Øœ\n\nThe website below will expire within next days.\nRenew now before it's too late!\n\n$Domain : ($Days days left)\n\nTo make sure the website doesn't expire, renew it now.\n\nIf the website expires, you will be able to renew it for a maximum of 10 days after the renewal date.\n\nDuring this time, the website will not be accessible. All the services attached to it will no longer be functional (emails, etc.).\n\nBest regards,\nGoAdmio Team\nwww.goadmio.com" "Hosting Expiration" "$Email"
    sudo /go/sendwhatsapp "*$Domain Hosting Expires On $ExpiresOn ($Days days left)*\n\n$Domain Hosting Expires On $ExpiresOn ($Days days left)" "Hosting Expiration"

    if [ "$Mobile" != "" ]; then

        sudo /go/sendwhatsapp "*$Domain Hosting Expires On $ExpiresOn ($Days days left)*\n\n$Domain Hosting Expires On $ExpiresOn ($Days days left)" "Hosting Expiration"

    fi

done
