#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log


if [[ "$@" = *"--"* ]]; then

	Arguments=1

	while [[ "$#" -gt 0 ]]; do
		case $1 in
			--subdomain) Subdomain="$2"; shift ;;
			--documentroot) DocumentRoot="$2"; shift ;;
			--redirecturl) RedirectUrl="$2"; shift ;;
			--action) Action="$2"; shift ;;
			*) echo "Subdomain: Unknown parameter: $1"; exit 1 ;;
		esac
		shift
	done
	
else

	Arguments=0
	
fi
 
if [ "$Action" = "delete" ]; then
	
	IFS='.' read -r -a Array <<< "$Subdomain"
	Directory="${Array[0]}"
	Domain=${Subdomain/$Directory.} 

	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "delete from Subdomain where Subdomain='$Subdomain'"

	sudo rm -rf /etc/httpd/vhost/$Subdomain.conf
	sudo rm -rf /etc/httpd/vhost/$Subdomain-le-ssl.conf
	sudo rm -rf /etc/nginx/vhost/$Subdomain-le-ssl.conf

	echo "Subdomain $Subdomain has been deleted."

	sudo /go/reload "| Executed by $(basename "$0")"
	
	exit 1

fi

IFS='.' read -r -a Array <<< "$Subdomain"
Directory="${Array[0]}"
Domain=${Subdomain/$Directory.}
Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
	
if [ ${#Subdomain} -ge 32 ]; then 
	echo "Invalid username $Subdomain"
	exit 1
fi

if sudo test ! -d /home/$Domain ; then 
	echo "Domain $Domain does not exist."
	exit 1
fi

if [ "$DocumentRoot" = "" ]; then
	DocumentRoot="$Directory"
fi
	
if [ "$Action" = "edit" ]; then

	echo "Modifying Subdomain $Subdomain..."
	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "UPDATE Subdomain SET DocumentRoot='$DocumentRoot',RedirectUrl='$RedirectUrl' WHERE Subdomain='$Subdomain'"
	
else

	if sudo test -d "/home/$Subdomain" ; then
		echo "ubdomain $Subdomain already exists."
		exit 1
	fi

	TimeStamp=$(date +'%s')
	echo "Subdomain \"$Subdomain\" Created Successfully."
	sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/subdomain.db "INSERT OR IGNORE INTO Subdomain (Subdomain,DocumentRoot,RedirectUrl,Domain,Username,TimeStamp) VALUES ('$Subdomain','$DocumentRoot','$RedirectUrl','$Domain','$Username','$TimeStamp')"
	
fi

sudo /go/apache-subdomain $Subdomain
sudo /go/nginx-subdomain $Subdomain

sudo screen -d -m bash -c "/go/ssl $Subdomain"

