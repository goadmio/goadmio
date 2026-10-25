#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

ServerLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT ServerLimit FROM Config WHERE ConfigID=1")
DomainLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT DomainLimit FROM Config WHERE ConfigID=1")
ExternalLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT ExternalLimit FROM Config WHERE ConfigID=1")
UserLimit=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT UserLimit FROM Config WHERE ConfigID=1")

# SET General Config
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
    POSTFWD="/etc/postfwd/postfwd.cf"
elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
    POSTFWD="/etc/postfwd.cf"
fi

# Server Limit
echo "id=Server; client_address!=8.8.8.8; action=rate(sender/$ServerLimit/86400/REJECT Sorry, Daily limit exceeded: maximum $ServerLimit messages allowed for server per day)" >$POSTFWD

if [ ! "$ExternalLimit" -eq "0" ]; then
    # External IPs
    echo "id=External; client_address!=127.0.0.1; action=rate(sender/$ExternalLimit/86400/REJECT Sorry, Daily limit exceeded: maximum $ExternalLimit messages allowed for external IPs per day)" >>$POSTFWD
fi

N=0
sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/site.db "
	SELECT IFNULL(Domain,'') || '|' || IFNULL(PostfwdDomainLimit,'0') || '|' || IFNULL(PostfwdUserLimit,'0')
	FROM Site
	WHERE PostfwdIgnore=1 ORDER BY Domain
" | while IFS='|' read -r Domain PostfwdDomainLimit PostfwdUserLimit; do

    N=$(($N + 1))
    DomainEscaped=$(echo "$Domain" | sed 's/\./\\./g')

    if [ "$PostfwdDomainLimit" -ge "1" ]; then
        # Limit SMTP Messages per Domain/Day
        echo "id=Domain${N}; sender_domain==$Domain; action=rate(sender/$PostfwdDomainLimit/86400/REJECT Sorry, Daily limit exceeded: maximum $PostfwdDomainLimit messages allowed for domain \$\$sender_domain per day)" >>$POSTFWD
    fi

    if [ "$PostfwdUserLimit" -ge "1" ]; then
        echo "id=SASL${N}; sasl_username=~/@$DomainEscaped$/; action=rate(sender/$PostfwdUserLimit/3600/REJECT Sorry, exceeded $PostfwdUserLimit messages in 60 minutes for \$\$sasl_username)" >>$POSTFWD
    fi

done

N=0
SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "SELECT Domain FROM Site where PostfwdIgnore=1;")
for Domain in $SQL; do
    N=$(($N + 1))
    DomainEscaped=$(echo "$Domain" | sed 's/\./\\./g')
    echo "id=ExcludeDomain${N}; sender_domain==$Domain; action=ok" >>$POSTFWD
    echo "id=ExcludeSASL${N}; sasl_username=~/@$DomainEscaped$/; action=ok" >>$POSTFWD
done

if [ ! "$DomainLimit" -eq "0" ]; then
    # Limit SMTP Messages per Domain/Day
    echo "id=Domain; sender_domain=~/.*/; action=rate(sender/$DomainLimit/86400/REJECT Sorry, Daily limit exceeded: maximum $DomainLimit messages allowed for domain \$\$sender_domain per day)" >>$POSTFWD
fi

if [ ! "$UserLimit" -eq "0" ]; then
    echo "id=SASL; sasl_username=~/.*/; action=rate(sender/$UserLimit/3600/REJECT Sorry, exceeded $UserLimit messages in 60 minutes for \$\$sasl_username)" >>$POSTFWD
fi
