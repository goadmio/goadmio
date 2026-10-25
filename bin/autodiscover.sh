#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/autodiscover "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

PostfixVersion=$(sudo postconf -d | grep "^mail_version" | sed 's/[^0-9\.]//g')

cd /home
for Domain in *; do

    SMTPHostname=$(</etc/hostname)

    if sudo test -f /etc/imap ; then
        IMAPHostname=$(</etc/imap)
    else
        IMAPHostname=$(</etc/hostname)
    fi

    if sudo test -f "/etc/letsencrypt/live/smtp.$Domain/fullchain.pem" ; then

        if [[ "$PostfixVersion" = "3"* ]]; then

            SMTPHostname="smtp.$Domain"

        fi

    fi

    if sudo test -f "/etc/letsencrypt/live/imap.$Domain/fullchain.pem" ; then
        IMAPHostname="imap.$Domain"
    fi

    if sudo test -d "/home/$Domain/www" ; then

        sudo mkdir -p /home/$Domain/www/autodiscover

        echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" | sudo tee /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "<Autodiscover xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/responseschema/2006\">" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "	<Response xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a\">" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "		<Account>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			<AccountType>email</AccountType>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			<Action>settings</Action>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			<Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Type>IMAP</Type>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Server>$IMAPHostname</Server>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Port>993</Port>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<DomainRequired>on</DomainRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SPA>off</SPA>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SSL>on</SSL>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<AuthRequired>on</AuthRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			</Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			<Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Type>POP3</Type>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Server>$SMTPHostname</Server>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Port>995</Port>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<DomainRequired>on</DomainRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SPA>off</SPA>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SSL>on</SSL>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<AuthRequired>on</AuthRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			</Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			<Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Type>SMTP</Type>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Server>$SMTPHostname</Server>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<Port>465</Port>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<DomainRequired>on</DomainRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SPA>off</SPA>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SSL>on</SSL>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<AuthRequired>on</AuthRequired>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<UsePOPAuth>on</UsePOPAuth>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "				<SMTPLast>off</SMTPLast>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "			</Protocol>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "		</Account>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "	</Response>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null
        echo "</Autodiscover>" | sudo tee -a /home/$Domain/www/autodiscover/autodiscover.xml >/dev/null

    fi

done
