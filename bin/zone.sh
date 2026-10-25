#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/zone "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    ZONE="/etc/zone"
    CONF="/etc/named.conf"

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    sudo mkdir -p /etc/bind/zone

    ZONE="/etc/bind/zone"
    CONF="/etc/bind/named.conf.local"

fi

# Check Errors
# named-checkconf
# sudo named-checkconf /etc/named.conf
# sudo named-checkzone goadmio.com /etc/zone/reverse.goadmio.com
# netstat -lnptu | grep named
# nslookup mlseg.com 89.40.15.140
# dig @173.249.10.60 -x 173.249.10.60
# dig @173.249.10.60 -t A mail.goadmio.com.

Domain=$1
Action=$2

MySQLRootPassword=$(sudo grep -oP 'DBPassword="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [ "$Action" = "delete" ]; then

    sudo sed -i "/zone \"$Domain\"/d" $CONF

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "DELETE from Zone where Domain='$Domain'"
    sudo rm -rf $ZONE/$Domain
    sudo rm -rf $ZONE/reverse.$Domain

    exit 1

fi

if sudo test ! -f /etc/nameservers ; then

    echo "Please Setup a Nameserver."

    exit 1

fi

if [ "$Domain" != "all" ]; then

    if sudo test ! -d /home/$Domain/www ; then

        if [ "$Action" != "main" ]; then

            echo "Domain \"$Domain\" not exists."

            exit 1

        fi

    fi

fi

if [ "$Action" != "" ] && [ "$Action" != "reset" ] && [ "$Action" != "update" ] && [ "$Action" != "main" ]; then

    echo "Invalid action."

    exit 1

fi

IP=$(curl -s -4 checkip.amazonaws.com)
IP=$(echo $IP | sed -e 's/^[ \t]*//')

IFS='.' read -r -a Array <<<"$IP"
ReverseIP="${Array[2]}.${Array[1]}.${Array[0]}"
# If the server has an IP address 20.30.40.50, its network ID will be 20.30.40, and the reverse zone name will be 40.30.20.in-addr.arpa.

Hostname=$(</etc/hostname)

NS1=$(head -n 1 /etc/nameservers)

if [ "$Domain" = "all" ]; then

    if [ "$Action" = "reset" ]; then
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "DELETE from Zone"
    fi

    if [ "$Action" = "reset" ] || [ "$Action" = "update" ]; then

        # Delete all type master; lines
        sudo sed -i "/type master;/d" $CONF

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "DELETE from Zone where Domain='$Domain'"

        # Create Main DNS
        MAIN=$(echo "$NS1" | cut -d '.' -f2-)
        sudo /go/zone $MAIN main

        # Edit Zone All Sites
        cd /home
        for Domain in *; do

            echo "Resetting DNS Zone $Domain..."

            if sudo test -d "/home/$Domain/www" ; then

                sudo /go/zone $Domain $Action --norestart

                sudo /go/installdkim $Domain

            fi

        done

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

            sudo systemctl daemon-reload
            sudo systemctl restart named

        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

            sudo systemctl daemon-reload
            sudo systemctl restart bind9

        fi

    fi

    exit 1

fi

if [ "$Action" = "update" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "DELETE from Zone where Domain='$Domain' and Custom=0"

fi

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if ! grep -q "Restart=always" /lib/systemd/var/go/named.service; then
        echo "Restart=always" >>/lib/systemd/var/go/named.service
    fi

    if ! grep -q "RestartSec=3" /lib/systemd/var/go/named.service; then
        echo "RestartSec=3" >>/lib/systemd/var/go/named.service
    fi

    sudo sed -i "s/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { 127.0.0.1;$IP; };/g" $CONF
    sudo sed -i "s/allow-query     { localhost; };/allow-query     { any; };/g" $CONF

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    echo "options {" | sudo tee /etc/bind/named.conf.options >/dev/null
    echo "directory \"/var/cache/bind\";" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "listen-on port 53 { localhost; $IP;};" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "listen-on-v6 port 53 { ::1; };" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "allow-query     { any; };" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "recursion yes;" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "dnssec-validation yes;" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "" | sudo tee -a /etc/bind/named.conf.options >/dev/null
    echo "};" | sudo tee -a /etc/bind/named.conf.options >/dev/null

fi

if ! grep -q "$ZONE/$Domain" $CONF; then
    echo "zone \"$Domain\" {type master;file \"$ZONE/$Domain\";};" >>$CONF
    # echo "zone \"$ReverseIP.in-addr.arpa\" {type master;file \"$ZONE/reverse.$Domain\";};" >> $CONF
fi

if [ "$Action" = "reset" ] || [ "$Action" = "update" ] || [ "$Action" = "main" ]; then

    File="/etc/nameservers"
    while IFS= read Nameservers; do

        if [[ "$Nameservers" = *"."* ]]; then

            IFS='.' read -r -a NSArray <<<"$Nameservers"

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','$Domain','NS','$Nameservers','86400','0')"
            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','${NSArray[0]}','A','$IP','14400','0')"

        fi

    done <"$File"

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','$Domain','A','$IP','14400','0')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','mail','A','$IP','14400','0')"

    # MX
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','$Domain','MX','$Domain','14400','0')"

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','www','CNAME','$Domain','14400','0')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','webmail','CNAME','$Domain','14400','0')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','go','CNAME','$Domain','14400','0')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','*','CNAME','$Domain','14400','0')"
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','ftp','CNAME','$Domain','14400','0')"

    # SPF
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','$Domain','TXT','v=spf1 +a +mx +ip4:$IP ~all','14400','0')"

    # DKIM
    DKIM=$(/go/installdkim $Domain dns)
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority) VALUES ('$Domain','dkim._domainkey.$Domain','TXT','$DKIM','14400','0')"

fi

Serial=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select SiteID from Site where Domain='$Domain'")
SerialNo=$(printf "%09d" $Serial)

RSerial=$(($Serial + 100000))
RSerialNo=$(printf "%09d" $RSerial)

echo "; Balckhost Zone File Version 1.0.0" >$ZONE/$Domain
echo "; Zone file for $Domain" >>$ZONE/$Domain
echo "\$TTL 14400" >>$ZONE/$Domain
echo "$Domain.               86400   IN      SOA     $NS1.    $Hostname. (" >>$ZONE/$Domain
echo "                $SerialNo  ; Serial" >>$ZONE/$Domain
echo "                3600       ; Refresh" >>$ZONE/$Domain
echo "                1800       ; Retry a" >>$ZONE/$Domain
echo "                1209600    ; Expire" >>$ZONE/$Domain
echo "                86400 )    ; Minimum TTL" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo "; Name Server Information" >>$ZONE/$Domain
NSRecord=""

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "SELECT Name || ',' || TTL || ',' || Value from Zone where Domain='$Domain' and Type='NS'" | sudo tee /usr/local/goadmio/tmp/$Domain.zone >/dev/null
File="/usr/local/goadmio/tmp/$Domain.zone"
while IFS= read String; do
    IFS=',' read -r -a Array <<<"$String"
    Name="${Array[0]}"
    TTL="${Array[1]}"
    Value="${Array[2]}"

    if [[ "$Name" = *"."* ]]; then
        NSRecord="$NSRecord\n$Name. $TTL IN NS $Value."
    else
        NSRecord="$NSRecord\n$Name $TTL IN NS $Value."
    fi

done <"$File"
echo -ne $NSRecord | column -t >>$ZONE/$Domain

echo ";" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo "; A Records:" >>$ZONE/$Domain
ARecord=""

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "SELECT Name || ',' || TTL || ',' || Value from Zone where Domain='$Domain' and Type='A'" | sudo tee /usr/local/goadmio/$Domain.zone >/dev/null
File="/usr/local/goadmio/$Domain.zone"
while IFS= read String; do
    IFS=',' read -r -a Array <<<"$String"
    Name="${Array[0]}"
    TTL="${Array[1]}"
    Value="${Array[2]}"

    if [[ "$Name" = *"."* ]]; then
        ARecord="$ARecord\n$Name. $TTL IN A $Value"
    else
        ARecord="$ARecord\n$Name $TTL IN A $Value"
    fi

done <"$File"
echo -ne $ARecord | column -t >>$ZONE/$Domain

echo ";" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo "; Mail Server Information" >>$ZONE/$Domain
MXRecord=""

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "SELECT Name || ',' || TTL || ',' || Priority || ',' || Value from Zone where Domain='$Domain' and Type='MX'" | sudo tee /usr/local/goadmio/$Domain.zone >/dev/null
File="/usr/local/goadmio/$Domain.zone"
while IFS= read String; do
    IFS=',' read -r -a Array <<<"$String"
    Name="${Array[0]}"
    TTL="${Array[1]}"
    Priority="${Array[2]}"
    Value="${Array[3]}"

    if [[ "$Name" = *"."* ]]; then
        MXRecord="$MXRecord\n$Name. $TTL IN MX $Priority $Value."
    else
        MXRecord="$MXRecord\n$Name $TTL IN MX $Priority $Value."
    fi

done <"$File"
echo -ne $MXRecord | column -t >>$ZONE/$Domain

echo ";" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo "; CNAME Records:" >>$ZONE/$Domain
CNAME=""

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "SELECT Name || ',' || TTL || ',' || Value from Zone where Domain='$Domain' and Type='CNAME'" | sudo tee /usr/local/goadmio/$Domain.zone >/dev/null
File="/usr/local/goadmio/$Domain.zone"
while IFS= read String; do
    IFS=',' read -r -a Array <<<"$String"
    Name="${Array[0]}"
    TTL="${Array[1]}"
    Value="${Array[2]}"

    if [[ "$Name" = *"."* ]]; then
        CNAME="$CNAME\n$Name. $TTL IN CNAME $Value."
    else
        CNAME="$CNAME\n$Name $TTL IN CNAME $Value."
    fi

done <"$File"
echo -ne $CNAME | column -t >>$ZONE/$Domain

echo ";" >>$ZONE/$Domain
echo ";" >>$ZONE/$Domain
echo "; TXT Records:" >>$ZONE/$Domain
TXT=""

sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/zone.db "SELECT Name || ',' || TTL || ',' || Value from Zone where Domain='$Domain' and Type='TXT'" | sudo tee /usr/local/goadmio/$Domain.zone >/dev/null
File="/usr/local/goadmio/$Domain.zone"
while IFS= read String; do
    IFS=',' read -r -a Array <<<"$String"
    Name="${Array[0]}"
    TTL="${Array[1]}"
    Value="${Array[2]}"

    if [[ "$Name" = *"."* ]]; then
        TXT="$Name. $TTL IN TXT \"$Value\""
    else
        TXT="$Name $TTL IN TXT \"$Value\""
    fi

    echo "$TXT" >>$ZONE/$Domain

done <"$File"

# Reverse
echo "\$TTL 1d" >$ZONE/reverse.$Domain
echo "@               IN      SOA     ns1.$Domain.    $Hostname. (" >>$ZONE/reverse.$Domain
echo "                $RSerialNo  ; Serial" >>$ZONE/reverse.$Domain
echo "                3600       ; Refresh" >>$ZONE/reverse.$Domain
echo "                1800       ; Retryr" >>$ZONE/reverse.$Domain
echo "                1209600    ; Expire" >>$ZONE/reverse.$Domain
echo "                86400 )    ; Minimum TTL" >>$ZONE/reverse.$Domain
echo ";" >>$ZONE/reverse.$Domain
echo ";" >>$ZONE/reverse.$Domain
echo ";Name Server Information" >>$ZONE/reverse.$Domain

IFS='.' read -r -a Array <<<"$NS1"
DNS1="${Array[0]}"

echo "@               IN      NS      $NS1." >>$ZONE/reverse.$Domain
echo "$DNS1             IN      A       $IP" >>$ZONE/reverse.$Domain
echo ";" >>$ZONE/reverse.$Domain
echo ";" >>$ZONE/reverse.$Domain
echo ";Reverse IP Information" >>$ZONE/reverse.$Domain
echo "$ReverseIP.in-addr.arpa.      IN      PTR       $NS1." >>$ZONE/reverse.$Domain
echo "$ReverseIP.in-addr.arpa.      IN      PTR       mail.$Domain." >>$ZONE/reverse.$Domain
echo "$ReverseIP.in-addr.arpa.      IN      PTR       www.$Domain." >>$ZONE/reverse.$Domain

if [[ ! $@ = *"--norestart"* ]]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo systemctl daemon-reload
        sudo systemctl restart named

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo iptables -A INPUT -p tcp --dport 53 -j ACCEPT
        sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT

        sudo systemctl daemon-reload
        sudo systemctl restart bind9

    fi

fi

# Check Errors
named-checkconf
named-checkconf $CONF
