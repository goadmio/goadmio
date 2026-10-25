#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/mail "$@"
fi

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log

if [[ "$@" = *"--"* ]]; then

	Arguments=1

	while [[ "$#" -gt 0 ]]; do
		case $1 in
			--email) Email="$2"; shift ;;
			--pass) Pass="$2"; shift ;;
			--forwardto) ForwardTo="$2"; shift ;;
			--reject) Reject="$2"; shift ;;
			--rejectmessage) RejectMessage="$2"; shift ;;
			--keepcopy) KeepCopy="$2"; shift ;;
			--domain) Domain="$2"; shift ;;
			--defaultaddress) DefaultAddress="$2"; shift ;;
			--suspend) Suspend="$2"; shift ;;
			--admin) Admin="$2"; shift ;;
			--description) Description="$2"; shift ;;
			--timestamp) TimeStamp="$2"; shift ;;
			--norestart) NoRestart="$2"; shift ;;
			--action) Action="$2"; shift ;;
			*) echo "MAIL: Unknown parameter: $1"; exit 1 ;;
		esac
		shift
	done
	
else

	Arguments=0
	
fi

Email=$(echo "$Email" | tr '[:upper:]' '[:lower:]')
TimeStamp=$(date +'%s')

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
IMAPAlert=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select IMAPAlert from Config")

if [ "$1" = "restart" ] || [[ "$@" = *"--restart"* ]]; then

	if sudo test -f /etc/postfix/custom_replies ; then
		sudo postmap /etc/postfix/custom_replies
	fi

	if sudo test -f /etc/postfix/vmail_domains ; then
		sudo postmap /etc/postfix/vmail_domains
	fi

	if sudo test -f /etc/postfix/vmail_mailbox ; then
		sudo postmap /etc/postfix/vmail_mailbox
	fi

	if sudo test -f /etc/postfix/vmail_aliases ; then
		sudo postmap /etc/postfix/vmail_aliases
	fi

	if sudo test -f /etc/postfix/vmail_relay ; then
		sudo postmap /etc/postfix/vmail_relay
	fi

	if sudo test -f /etc/postfix/vmail_sasl_passwd ; then
		sudo postmap /etc/postfix/vmail_sasl_passwd
	fi
	
	if sudo test -f /etc/postfix/vmail_ssl ; then
		sudo postmap -F lmdb:/etc/postfix/vmail_ssl
	fi

	sudo systemctl restart postfix
	sudo systemctl restart postfwd
	sudo systemctl restart dovecot
	sudo systemctl restart saslauthd
	sudo systemctl restart opendkim
	sudo systemctl restart opendmarc

	exit 1

fi

if [ "$Action" = "default" ]; then
	
	if [[ "$Email" = *"@"* ]]; then
	
		# Default Address
		sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET DefaultAddress=0 WHERE Domain='$Domain'"
		sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET DefaultAddress=1 WHERE Email='$Email'"

		echo "GoAdmio will forward all unrouted email for $Domain to $Email."

	else
		echo "GoAdmio will forward all unrouted email for $Domain to 'Recipient address rejected: User unknown.'"
	fi
	
elif [ "$Action" = "delete" ]; then
	
	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "DELETE FROM Mail where Email='$Email'"

	# Remove line start with $Email
	sudo sed -i "/^$Email:/d" /etc/dovecot/passwd

	IFS='@' read -r -a Array <<< "$Email"
	User="${Array[0]}"
	
	sudo /usr/bin/nohup "rm -rf /home/$Domain/mail/$User" > /var/log/go/background/$User.log 2>&1 &
	
	echo "$Email has been deleted."

elif [ "$Action" = "suspend" ]; then

	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Suspend=1 WHERE Email='$Email'"
	echo "$Email has been suspended."

elif [ "$Action" = "unsuspend" ]; then

	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Suspend=0 WHERE Email='$Email'"
	echo "$Email has been unsuspended."

elif [ "$Action" = "create" ]; then

	# Create Account in database from folder
	cd /home/$Domain/mail
	for User in *
	do

		if sudo test -d "/home/$Domain/mail/$User" ; then
			
			Email="$User@$Domain"
			Pass=$(sudo openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16 | head -c 8)

			if sudo test -f "/home/$Domain/mail/$User.conf" ; then
				# Get old account info
				source /home/$Domain/mail/$User.conf
			fi

			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "INSERT OR IGNORE INTO Mail (Email,Pass,ForwardTo,Reject,RejectMessage,KeepCopy,Domain,Username,DefaultAddress,Suspend,Admin,Description,TimeStamp) VALUES ('$Email','$Pass','$ForwardTo','$Reject','$RejectMessage','$KeepCopy','$Domain','$Username','$DefaultAddress','$Suspend','$Admin','$Description','$TimeStamp')"
			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Pass='$Pass' WHERE Email='$Email'"
					
		fi
		
	done
	
elif [ "$Action" = "edit" ]; then

	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "UPDATE Mail SET Pass='$Pass' where Email='$Email'"
	sudo sed -i "/^$Email:/d" /etc/dovecot/passwd

	Pass=$(doveadm pw -s sha1 -p $Pass | cut -d '}' -f2)
	echo "$Email:$Pass" | sudo tee -a /etc/dovecot/passwd
	
	echo "$Email Password has been modified successfully."
	
	sudo /go/mail restart
	
	exit 1

else

	Regex="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,9}$"

	if [[ ! $Email =~ $Regex ]] ; then
	
		echo "Invalid Email Address $Email."
		
		exit 1
	fi

	# Add
	IFS='@' read -r -a Array <<< "$Email"
	User="${Array[0]}"
	Domain="${Array[1]}"

	DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain'")
	if [[ ! "$DomainExists" = "$Domain" ]]; then
		echo "Account $Domain not exists"
		exit 1
	fi
	
	if [ "$Action" = "add" ]; then	

		sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "INSERT INTO Mail (Email,Pass,ForwardTo,Reject,RejectMessage,KeepCopy,Domain,Username,DefaultAddress,Suspend,Admin,Description,TimeStamp) VALUES ('$Email','$Pass','$ForwardTo','$Reject','$RejectMessage','$KeepCopy','$Domain','$Username','$DefaultAddress','$Suspend','$Admin','$Description','$TimeStamp')"
		
		sudo mkdir -p /home/$Domain/mail/$User
		sudo chmod 700 /home/$Domain/mail/$User
		sudo chown vmail:vmail /home/$Domain/mail/$User

	fi
	
	# if email rejected (remove that)
	sudo sed -i "/^$Email /d" /etc/postfix/custom_replies
	
	if grep -q "^$Email:" /etc/dovecot/passwd
	then
		echo "$Email Password has been modified successfully."
	fi
	
	if [ "$Action" = "add" ]; then	
		
		Hostname=$(</etc/hostname)
		if sudo test -f /etc/imap ; then
			IMAPHostname=$(</etc/imap)
		else
			IMAPHostname=$(</etc/hostname)
		fi
		
		if sudo test -d "/etc/letsencrypt/live/$Domain" ; then
			
			echo "{\"success\":true,\"title\":\"creating_email_account\",\"result\":{\"incoming_mail_server_imap\":\"\",\"account_type\":\"IMAP\",\"imap_username\":\"$Email\",\"imap_hostname\":\"imap.$Domain\",\"imap_port\":\"993\",\"imap_encryption\":\"SSL\",\"null\":\"\",\"outgoing_mail_server_smtp\":\"\",\"smtp_username\":\"$Email\",\"smtp_hostname\":\"smtp.$Domain\",\"smtp_port\":\"465\",\"smtp_encryption\":\"SSL\"}}"

		elif sudo test -d "/etc/letsencrypt/live/$Hostname" ; then
			
			echo "{\"success\":true,\"title\":\"creating_email_account\",\"result\":{\"incoming_mail_server_imap\":\"\",\"account_type\":\"IMAP\",\"imap_username\":\"$Email\",\"imap_hostname\":\"$IMAPHostname\",\"imap_port\":\"993\",\"imap_encryption\":\"SSL\",\"null\":\"\",\"outgoing_mail_server_smtp\":\"\",\"smtp_username\":\"$Email\",\"smtp_hostname\":\"$Hostname\",\"smtp_port\":\"465\",\"smtp_encryption\":\"SSL\"}}"

		else

			echo "{\"success\":true,\"title\":\"creating_email_account\",\"result\":{\"incoming_mail_server_imap\":\"\",\"account_type\":\"IMAP\",\"imap_username\":\"$Email\",\"imap_hostname\":\"imap.$Domain\",\"imap_port\":\"143\",\"imap_encryption\":\"None\",\"null\":\"\",\"outgoing_mail_server_smtp\":\"\",\"smtp_username\":\"$Email\",\"smtp_hostname\":\"smtp.$Domain\",\"smtp_port\":\"25\",\"smtp_encryption\":\"None\"}}"

		fi

		if [ "$IMAPAlert" = "1" ]; then
			sudo screen -d -m bash -c "/go/outlook $Email $Domain"
		fi
						
	fi

fi

if [ "$NoRestart" != "1" ]; then
	sudo screen -d -m bash -c "/go/vmail"
fi
