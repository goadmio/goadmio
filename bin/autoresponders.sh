#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

cd /tmp
sudo wget http://www.nefaria.com/scriptz/autoresponse-1.6.2.tar.gz
sudo tar xvfz autoresponse-1.6.2.tar.gz
cd autoresponse

useradd -d /var/spool/autoresponse -s $(which nologin) autoresponse
sudo mkdir -p /var/spool/autoresponse/log /var/spool/autoresponse/responses
sudo cp ./autoresponse /usr/local/sbin/
sudo chown -R autoresponse:autoresponse /var/spool/autoresponse
sudo chmod -R 0770 /var/spool/autoresponse

if grep -q "    -o content_filter=autoresponder:dummy" /etc/postfix/master.cf; then
    echo ""
else

    sudo sed -i 's/smtp      inet  n       -       n       -       -       smtpd/smtp      inet  n       -       n       -       -       smtpd\n    -o content_filter=autoresponder:dummy/g' /etc/postfix/master.cf

    echo 'autoresponder unix - n n - - pipe' >>/etc/postfix/master.cf
    echo '    flags=Fq user=autoresponse argv=/usr/local/sbin/autoresponse -s ${sender} -r ${recipient} -S ${sasl_username} -C ${client_address}' >>/etc/postfix/master.cf

    postconf -e 'autoresponder_destination_recipient_limit = 1'

fi
