#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ "$1" = "enable" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Junk='1' where ConfigID=1"

    sudo /go/doveconf
    sudo screen -d -m bash -c "/go/mail restart"
    exit 1

fi

if [ "$1" = "disable" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET Junk='0' where ConfigID=1"

    sudo /go/doveconf
    sudo screen -d -m bash -c "/go/mail restart"
    exit 1

fi

sudo mkdir -p /usr/local/goadmio/junk

echo "require \"fileinto\";" | sudo tee /usr/local/goadmio/junk/.sieve >/dev/null
echo "require \"body\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "require \"imap4flags\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "require \"variables\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "require \"envelope\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

echo "if header :contains \"Received-SPF\" \"Fail\" {" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

echo "if header :contains \"Received-SPF\" \"None\" {" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

echo "if header :contains \"Authentication-Results\" \"dkim=fail\" {" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

Subject=$(sudo wget https://www.goadmio.com/junk/subject.txt -q -O - | tr -d '\r')
echo "if header :contains \"subject\" [\"disk quota\"," | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
while read Content; do

    # TRIM
    Content=$(echo $Content | xargs echo -n)
    echo "\"$Content\"," | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

done <<<"$Subject"
echo "\"storage is almost full\"]" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "{" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

Body=$(sudo wget https://www.goadmio.com/junk/body.txt -q -O - | tr -d '\r')
echo "if body :contains [\"advanced ai service\"," | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
while read Content; do

    # TRIM
    Content=$(echo $Content | xargs echo -n)
    echo "\"$Content\"," | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

done <<<"$Body"
echo "\"we are a leading software\"]" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "{" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.sieve >/dev/null

# IP
echo "require \"fileinto\";" | sudo tee /usr/local/goadmio/junk/.ip >/dev/null
echo "require \"body\";" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "require \"imap4flags\";" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "require \"variables\";" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "require \"envelope\";" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "if header :contains \"Received-SPF\" [\"=0.0.0.0;\"," | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null

echo "Configuring IP Filter..."

sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/junk.db "
	SELECT IFNULL(Domain,'') || '|' || IFNULL(IP,'')
	FROM Junk
	WHERE JunkID>=1
" | while IFS='|' read -r Domain IP; do

    if [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "\"=$IP;\"," | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
    fi

done

echo "\"=1.1.1.1;\"]" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "{" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "    fileinto \"Junk\";" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "    stop;" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "}" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null
echo "" | sudo tee -a /usr/local/goadmio/junk/.ip >/dev/null

if sudo test -d "/home/download.goadmio.com/www/junk" ; then

    sudo rm -rf /home/download.goadmio.com/www/junk/.ip
    sudo rm -rf /home/download.goadmio.com/www/junk/.sieve

    sudo cp /usr/local/goadmio/junk/.ip /home/download.goadmio.com/www/junk/
    sudo cp /usr/local/goadmio/junk/.sieve /home/download.goadmio.com/www/junk/

fi

sievec /usr/local/goadmio/junk/.sieve
sievec /usr/local/goadmio/junk/.ip
