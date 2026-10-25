#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/cloudflare "$@"
fi

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log



IPv4=$(curl -s -4 checkip.amazonaws.com)
IPv6=$(curl -s -6 https://icanhazip.com)

if [[ "$@" = *"--"* ]]; then

	Arguments=1

	while [[ "$#" -gt 0 ]]; do
		case $1 in

			--domain) Domain="$2"; shift ;;
			--type) Type="$2"; shift ;;
			--name) Name="$2"; shift ;;
			--value) Value="$2"; shift ;;
			--priority) Priority="$2"; shift ;;
			--proxy) Proxy="$2"; shift ;;
			--cloudflareaccountid) CloudflareAccountID="$2"; shift ;;
			--cloudflareapitoken) CloudflareAPIToken="$2"; shift ;;
			--mode) Mode="$2"; shift ;;
			--action) Action="$2"; shift ;;
			*) echo "MAIL: Unknown parameter: $1"; exit 1 ;;
		esac
		shift
	done
	
else

	Arguments=0

	echo "Invalid Arguments."
	exit 1
	
fi

if [[ "$CloudflareAccountID" != "" || $CloudflareAPIToken != "" ]]; then

	if [ "$CloudflareAccountID" != "" ]; then
		sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET CloudflareAccountID='$CloudflareAccountID'"
	fi
	
	if [ "$CloudflareAPIToken" != "" ]; then
		sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "UPDATE Config SET CloudflareAPIToken='$CloudflareAPIToken'"
	fi

	exit 1

fi

if [ "$Domain" = "" ]; then

	echo "Please Enter Domain."
	exit 1
	
fi

if sudo test ! -d /home/$Domain  && [ ! "$Domain" = "all" ]; then

	echo "Domain \"$Domain\" does not exist"
	exit 1
	
fi

if [ "$Name" = "" ]; then
	Name="@"
fi

if [ "$Priority" = "" ]; then
	Priority="0"
fi

if [ "$Proxy" = "on" ] || [ "$Proxy" = "true" ] || [ "$Proxy" = "1" ]; then
	Proxy="true"
else
	Proxy="false"
fi

if [ "$Mode" = "" ]; then
	Mode="respect"
fi

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)
BrowserCacheTTL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select BrowserCacheTTL FROM Site where Domain='$Domain'")
AdditionalSPFRecords=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select AdditionalSPFRecords from Config where ConfigID=1")

SMTPHost=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "select SMTPHost from SMTP where Active=1 ORDER By Priority DESC LIMIT 1")
SMTPHostDots=$(sudo grep -o "\." <<<"$SMTPHost" | wc -l)

GetZoneID()
{
Domain=$1

Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
	-H "Authorization: Bearer $APIToken" \
	-H "Content-Type: application/json")

ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

echo "$ZoneID"
}

# Only 2 Parts TLDs & Ends With .??? or More
TLDs=(".in.net" ".com.museum")
ROOTDomain()
{
TLDDomain=$1
TLDDomain=$(echo "$TLDDomain" | xargs)
  
	Dots=$(sudo grep -o "\." <<<"$TLDDomain" | wc -l)
	if [[ "$Dots" -eq "1" ]]; then
		echo "1"
		return
	fi

	# All 2 Parts TLDs ends with ".??"
	TLDDomain=$(echo "$TLDDomain" | sed -E 's/\.(ac|am|av|co|dr|ed|gc|gg|go|gr|id|lg|me|ms|ne|or|pe|re|tm|tv|adm|adv|agr|arq|art|aso|asn|ato|bel|bio|bmd|biz|cim|cng|cnt|com|dni|ecn|edu|eng|eti|fnd|fot|fst|gen|gob|gov|imb|ind|inf|int|iwi|jor|lel|ltd|mat|med|mil|mod|msk|mus|net|nhs|nom|not|ntr|odo|org|plc|pol|prd|pro|psc|psi|qsl|rec|res|sch|slg|spb|srv|tmp|trd|tur|vet|web|zlg|blog|firm|flog|geek|govt|info)\.[a-zA-Z]{2}$//')
  
	for TLD in "${TLDs[@]}"; do
		TLDDomain=$(echo "$TLDDomain" | sed "s/$TLD//g")
	done
	
	Dots=$(sudo grep -o "\." <<<"$TLDDomain" | wc -l)

	if [ "$Dots" -ge "1" ]; then
		# Subdomain
		echo "0"
	else
		# Main Domain
		echo "1"
	fi
	
}

Main()
{
	Domain=$1
	Action=$2

	CountMX=$(dig +noall +answer -t mx $Domain | wc -l)
	MXLookup=$(dig +noall +answer -t mx $Domain)
	if [ "$CountMX" -ge "2" ] || [[ "$MXLookup" = *"google"* ]] || [[ "$MXLookup" = *"zoho"* ]] || [[ "$MXLookup" = *"outlook"* ]]; then
		Edit="0"
	else
		Edit="1"
	fi

	ZoneID=$(GetZoneID "$Domain")

	if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then

		for DeleteNo in {1..2}; do

			# Delete A Record (@)
			Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Domain&per_page=1&order=type&direction=desc&match=all" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json")
				 
			ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

			sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json"

			# Delete AAAA Record (@)
			Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=AAAA&name=$Domain&per_page=1&order=type&direction=desc&match=all" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json")
				 
			ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

			sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json"

			# Delete A Record (www)
			Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=www.$Domain&per_page=1&order=type&direction=desc&match=all" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json")
				 
			ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

			sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json"

		done						 

		# Delete www CNAME Record
		Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=www.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json")
			 
		ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

		sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json"
			 
		# Delete webmail CNAME Record
		Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=webmail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json")

		ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

		sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json"

		# Delete go CNAME Record
		Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=go.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json")

		ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

		sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json"

		# Add A Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"A\",\"name\":\"@\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}"

		# Add AAAA Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"AAAA\",\"name\":\"@\",\"content\":\"$IPv6\",\"ttl\":3600,\"proxied\":$Proxy}"

		# Add www CNAME Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"CNAME\",\"name\":\"www\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":$Proxy}"

		# Add m CNAME Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"CNAME\",\"name\":\"m\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":$Proxy}"

		# Add * CNAME Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"CNAME\",\"name\":\"*\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":$Proxy}"

		# Add go CNAME Record
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"CNAME\",\"name\":\"go\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":false}"

		# Add ftp CNAME Record (Proxy OFF)
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"CNAME\",\"name\":\"ftp\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":false}"

		if [ "$Action" = "google" ]; then
		
			DeleteMX "$Domain"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				 -H "Authorization: Bearer $APIToken" \
				 -H "Content-Type: application/json" \
				 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"ASPMX.L.GOOGLE.COM\",\"ttl\":3600,\"priority\":1,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				 -H "Authorization: Bearer $APIToken" \
				 -H "Content-Type: application/json" \
				 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"ALT1.ASPMX.L.GOOGLE.COM\",\"ttl\":3600,\"priority\":5,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				 -H "Authorization: Bearer $APIToken" \
				 -H "Content-Type: application/json" \
				 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"ALT2.ASPMX.L.GOOGLE.COM\",\"ttl\":3600,\"priority\":5,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				 -H "Authorization: Bearer $APIToken" \
				 -H "Content-Type: application/json" \
				 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"ALT3.ASPMX.L.GOOGLE.COM\",\"ttl\":3600,\"priority\":10,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				 -H "Authorization: Bearer $APIToken" \
				 -H "Content-Type: application/json" \
				 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"ALT4.ASPMX.L.GOOGLE.COM\",\"ttl\":3600,\"priority\":10,\"proxied\":false}"

		elif [ "$Action" = "zoho" ]; then
		
			DeleteMX "$Domain"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"mx.zoho.com\",\"ttl\":3600,\"priority\":10,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"mx2.zoho.com\",\"ttl\":3600,\"priority\":20,\"proxied\":false}"

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"mx3.zoho.com\",\"ttl\":3600,\"priority\":50,\"proxied\":false}"

		elif [[ ! $@ = *"--skip mail"* ]]; then

			if [ "$Edit" = "1" ]; then

				if [ "$SMTPHostDots" -ge "1" ]; then

					ExternalIP=$(ping -c 1 $SMTPHost | gawk -F'[()]' '/PING/{print $2}')

					sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"v=spf1 +a +mx +ip4:$IPv4 +ip4:$ExternalIP $AdditionalSPFRecords ~all\",\"ttl\":3600,\"proxied\":false}"

				else

					sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"v=spf1 +a +mx +ip4:$IPv4 $AdditionalSPFRecords ~all\",\"ttl\":3600,\"proxied\":false}"
				
				fi
				
				Code=$(sudo cat /etc/opendkim/$Domain/dkim.txt | sed -n '2p')
				IFS='"' read -r -a Array <<< "$Code"
				DKIM="v=DKIM1; k=rsa; ${Array[1]}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"TXT\",\"name\":\"dkim._domainkey.$Domain\",\"content\":\"$DKIM\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"TXT\",\"name\":\"_dmarc.$Domain\",\"content\":\"v=DMARC1; p=quarantine; rua=mailto:info@$Domain; ruf=mailto:info@$Domain; adkim=r; aspf=r; fo=1; sp=quarantine;\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"CNAME\",\"name\":\"smtp\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"CNAME\",\"name\":\"imap\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"CNAME\",\"name\":\"webmail\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"imap.$Domain\",\"ttl\":3600,\"priority\":0,\"proxied\":false}"
			fi
		fi

		# SSL Flexible | Full | strict
		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/ssl" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value":"strict"}'

		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/minify" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value":{"css":"on","html":"on","js":"on"}}'

		# Always USE HTTPS
		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/always_use_https" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value":"on"}'

		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/cache_level" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value":"basic"}'

		# Browser Cache
		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/browser_cache_ttl" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"value\":$BrowserCacheTTL}"

		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/always_online" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value":"on"}'

		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/flags/products/cache/changes" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"feature":"crawlhints_enabled","value":true}'
		
		# Bot fight mode & Block AI bots
		sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/bot_management" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"fight_mode\":true,\"ai_bots_protection\":\"block\"}"

		# Security Level: medium | high | under_attack
		sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/security_level" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data '{"value": "medium"}'
		
		# Allow Server IP (AlLOW CURL & GET FILE CONTENT)
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/firewall/access_rules/rules" \
			 -H "Authorization: Bearer $APIToken" \
			 -H "Content-Type: application/json" \
			--data "{\"mode\": \"whitelist\",\"configuration\": {\"target\": \"ip\",\"value\": \"$IPv4\"},\"notes\": \"Allow Server IP\"}"

		
	else
	
		# Subdomain
		Subdomain="$Domain"
		Domain=$(echo "$Subdomain" | sed 's/^[^.]*.//')
		
		Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json")

		ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

		for DeleteNo in {1..2}; do
			
			# Delete A Record (Subdomain)
			Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Subdomain&per_page=1&order=type&direction=desc&match=all" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json")
				 
			ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

			sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json"

		done

		# Add A Record (Subdomain)
		sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
		-H "Authorization: Bearer $APIToken" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"A\",\"name\":\"$Subdomain\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}"

	fi

}


DeleteMX()
{
	Domain=$1

	ZoneID=$(GetZoneID "$Domain")

	for DeleteNo in {1..5}; do

		Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=MX&name=$Domain&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")
			 
		ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

		if [ ! "$ID" = "" ]; then
		
			sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json"
			
		fi

	done

}

AccountID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAccountID from Config")
APIToken=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select CloudflareAPIToken from Config")

if [[ "$AccountID" == "" || "$APIToken" = "" ]]; then

	echo "Please Setup Cloudflare API."
	echo "cloudflare --cloudflareaccountid <Account ID> --cloudflareapitoken <API Token>"
	exit 1
fi

DynadotIP=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select DynadotIP from Config")
DynadotAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select DynadotAPIKey from Config")

SpaceshipAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SpaceshipAPIKey from Config")
SpaceshipAPISecret=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select SpaceshipAPISecret from Config")

ResellerclubIP=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubIP from Config")
ResellerclubUserID=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubUserID from Config")
ResellerclubAPIKey=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select ResellerclubAPIKey from Config")

if [[ "$Action" = "" || "$Action" = "google" || "$Action" = "zoho" ]] && [ "$Type" = "" ]; then

	if [ "$Domain" = "all" ]; then

		# To Prevent too many redirects
		if [ "$Proxy" = "true" ]; then
			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0"
		else
			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1"
		fi

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do

			if [[ "$Domain" = *"."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					N=$(($N + 1))

					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
						echo "[$N/$C] Configuring DNS for $Domain..."
						Main "$Domain" "$Action"
					fi

				fi
				
			fi
			
		done
		
	else
		
		# To Prevent too many redirects
		if [ "$Proxy" = "true" ]; then
			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=0 where Domain='$Domain'"
		else
			sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET SSLRedirect=1 where Domain='$Domain'"
		fi

		APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
		if [ "$APIIgnore" = "1" ]; then
			echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
		else
			echo "Configuring DNS for $Domain..."
			Main "$Domain" "$Action"
		fi

	fi
	
	exit 1
	
fi

if [ "$Action" = "addsite" ]; then
		
	if [ "$Domain" = "new" ]; then
				
		SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where ZoneID='' and Domain not like 'm.%';")
		for Domain in $SQL
		do

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"account\": {\"id\": \"$AccountID\"}, \"name\":\"$Domain\",\"jump_start\":true}"

		done
		
	elif [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do
	
			if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"account\": {\"id\": \"$AccountID\"}, \"name\":\"$Domain\",\"jump_start\":true}"

			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"account\": {\"id\": \"$AccountID\"}, \"name\":\"$Domain\",\"jump_start\":true}"

		fi
			
	fi
		
fi
  
if [ "$Action" = "removesite" ] || [ "$Action" = "deletesite" ]; then

	if [ "$Domain" = "all" ] || [ "$Domain" = "" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do

			if [[ "$Domain" = *"."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					N=$(($N + 1))
					
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
					
						echo "[$N/$C] Deleting $Domain..."
						ZoneID=$(GetZoneID "$Domain")

						sudo curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"
							 
					fi

				fi
				
			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			ZoneID=$(GetZoneID "$Domain")
	
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
				
				sudo curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"
					 
			fi

		fi
			
	fi
	
	exit 1
	
fi

if [ "$Type" = "a" ] || [ "$Type" = "A" ]; then

	if [ "$Value" = "" ]; then
		IPv4=$(curl -s -4 checkip.amazonaws.com)
	else
		if [[ "$Value" = *"."* ]]; then
			IPv4="$Value"
		else
			IPv4=$(curl -s -4 checkip.amazonaws.com)
		fi
	fi

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					N=$(($N + 1))
				
					ZoneID=$(GetZoneID "$Domain")
					
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
					
						if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then
						
							echo -ne "[$N/$C] Adding A Record $IPv4 ($Domain) | "

							Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data "{\"type\":\"A\",\"name\":\"@\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}")
								 
							if 	[[ "$Status" = *"already exists"* ]]; then
							
								echo -ne "Record already exists."

							elif [[ "$Status" = *"success"* ]]; then
							
								echo -ne "Success."
								
							else
							
								echo -ne "Failed."

							fi
							
						else

							echo -ne "[$N/$C] Adding A Record $IPv4 ($Domain) | "

							# Subdomain
							Subdomain="$Domain"
							Domain=$(echo "$Subdomain" | sed 's/^[^.]*.//')
							
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain&account.id=$AccountID&per_page=20&order=status&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")

							ZoneID=$(echo "$Code" | grep -oP '\{\"result\"\:\[\{\"id\":"\K[^"]+')

							# Add A Record (Subdomain)
							Status=$(curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data "{\"type\":\"A\",\"name\":\"$Subdomain\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}")

							if 	[[ "$Status" = *"already exists"* ]]; then
							
								echo -ne "Record already exists."

							elif [[ "$Status" = *"success"* ]]; then
							
								echo -ne "Success."
								
							else
							
								echo -ne "Failed."

							fi
							
						fi
				
					fi
			
					echo ""
					
				fi
				
			fi								
				
		done
		
	else
		
		APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
		if [ "$APIIgnore" = "1" ]; then
			echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
		else
		
			if [ "$Action" = "delete" ]; then
			
				if [[ $(ROOTDomain "$Domain") = "1" ]]; then
			
					ZoneID=$(GetZoneID "$Domain")
			
					echo "Deleting A Record $Record | sudo tee $Domain..."

					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&page=1&per_page=1&order=type&direction=desc&match=all" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json")
						 
					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						 -H "Authorization: Bearer $APIToken" \
						 -H "Content-Type: application/json"
						 
				else
				
					# Subdomain
					Subdomain="$Domain"
					Domain=$(echo "$Subdomain" | sed 's/^[^.]*.//')
					
					ZoneID=$(GetZoneID "$Domain")
					
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Subdomain" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")

					if command -v jq &> /dev/null; then
						ID=$(echo "$Code" | jq -r '.result[0].id // empty')
					else
						# Fallback to grep (less reliable)
						ID=$(echo "$Code" | grep -oP '"id":"\K[^"]+' | head -1)
					fi

					DeleteResult=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")
					
				fi
					 
			else
				
				if [[ $(ROOTDomain "$Domain") = "1" ]]; then
				
					ZoneID=$(GetZoneID "$Domain")

					Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"A\",\"name\":\"@\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}")
					
				else

					# Subdomain
					Subdomain="$Domain"
					Domain=$(echo "$Subdomain" | sed 's/^[^.]*.//')

					ZoneID=$(GetZoneID "$Domain")

					# Add A Record (Subdomain)
					Status=$(curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"A\",\"name\":\"$Subdomain\",\"content\":\"$IPv4\",\"ttl\":3600,\"proxied\":$Proxy}")
				
				fi
				
			fi
			
		fi
			
	fi
		
fi


if [ "$Action" = "DeleteARecord" ] || [ "$Action" = "deletearecord" ] || [ "$Action" = "deletea" ]; then

	if [ "$Value" = "" ]; then
	
		IPv4=$(curl -s -4 checkip.amazonaws.com)

	else
	
		IPv4="$Value"

	fi

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					N=$(($N + 1))
					
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
					
						echo -ne "[$N/$C] Deleting A Record $IPv4 ($Domain) | "

						ZoneID=$(GetZoneID "$Domain")

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						Status=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json")
							 
						if 	[[ "$Status" = *"success"* ]]; then
						
							echo -ne "Success."
							
						else
						
							echo -ne "Failed."

						fi
						
					fi
						
					echo ""

				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				echo "Deleting A Record $Record | sudo tee $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"
					 
			fi

		fi
			
	fi
		
fi

if [ "$Type" = "spf" ]; then

	if [ "$Value" = "" ]; then

		if [ "$SMTPHostDots" -ge "1" ]; then

			ExternalIP=$(ping -c 1 $SMTPHost | gawk -F'[()]' '/PING/{print $2}')
			SPF="v=spf1 +a +mx +ip4:$IPv4 +ip4:$ExternalIP $AdditionalSPFRecords ~all"

		else

			SPF="v=spf1 +a +mx +ip4:$IPv4 $AdditionalSPFRecords ~all"
		
		fi

	else
	
		SPF="$Value"
	
	fi

	if [ "$Domain" = "all" ] || [ "$Domain" = "" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

					if sudo test -d "/var/cpanel/users" ; then
						Domain=$(sudo grep ^DNS= /var/cpanel/users/$Domain | cut -d= -f2)
					fi

					N=$(($N + 1))
					
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
					
						ZoneID=$(GetZoneID "$Domain")

						# Delete SPF
						for i in {1..2}; do
							
							Code=$(curl --silent --output /dev/null -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&search=spf1&proxied=false&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")

							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							if [ ! "$ID" = "" ]; then
							
								sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json"
								
							fi
							
						done

						# Add SPF
						Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"$SPF\",\"ttl\":3600,\"proxied\":false}")

						Message=$(echo "$Response" | jq -r '.errors[0].message')

						if echo "$Response" | jq -e '.success == true' > /dev/null; then
							echo "Adding SPF Record for $Domain | Success"
						else
							echo "Adding SPF Record for $Domain | $Message"
						fi
						
					fi

				fi
				
			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				ZoneID=$(GetZoneID "$Domain")

				# Delete SPF
				for i in {1..2}; do
					
					Code=$(curl --silent --output /dev/null -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&search=spf1&proxied=false&page=1&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")

					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					if [ ! "$ID" = "" ]; then
					
						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json"
						
					fi
					
				done

				# Add SPF
				Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"$SPF\",\"ttl\":3600,\"proxied\":false}")

				Message=$(echo "$Response" | jq -r '.errors[0].message')

				if echo "$Response" | jq -e '.success == true' > /dev/null; then
					echo "Adding SPF Record for $Domain | Success"
				else
					echo "Adding SPF Record for $Domain | $Message"
				fi

			fi

		fi
			
	fi
	
	exit 1
	
fi


if [ "$Type" = "dmarc" ]; then

	if [ "$Value" = "" ]; then

		DMARC="v=DMARC1; p=quarantine; rua=mailto:info@$Domain; ruf=mailto:info@$Domain; adkim=r; aspf=r; fo=1; sp=quarantine;"
		
	else
	
		DMARC="$Value"
	
	fi

	if [ "$Domain" = "all" ] || [ "$Domain" = "" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

					if sudo test -d "/var/cpanel/users" ; then
						Domain=$(sudo grep ^DNS= /var/cpanel/users/$Domain | cut -d= -f2)
					fi

					N=$(($N + 1))
					
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else

						ZoneID=$(GetZoneID "$Domain")

						# Delete DMARC
						for i in {1..2}; do
						
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=_dmarc.$Domain" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")

							if command -v jq &> /dev/null; then
								ID=$(echo "$Code" | jq -r '.result[0].id // empty')
							else
								# Fallback to grep (less reliable)
								ID=$(echo "$Code" | grep -oP '"id":"\K[^"]+' | head -1)
							fi

							DeleteResult=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
							
							if echo "$DeleteResult" | grep -q '"success":true'; then
								DeletedDmarc=1
							else
								DeletedDmarc=0
							fi
							
							
						done

						# Add DMARC
						Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"TXT\",\"name\":\"_dmarc.$Domain\",\"content\":\"$DMARC\",\"ttl\":3600,\"proxied\":false}")
						
						Message=$(echo "$Response" | jq -r '.errors[0].message')

						if echo "$Response" | jq -e '.success == true' > /dev/null; then
							echo "[$N/$C] Adding DMARC Record for $Domain | Success"
						else
							echo "[$N/$C] Adding DMARC Record for $Domain | $Message"
						fi
						
					fi

				fi
				
			fi
			
		done
		
	else
		
		APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
		if [ "$APIIgnore" = "1" ]; then
			echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
		else
		
			ZoneID=$(GetZoneID "$Domain")

			# Delete DMARC
			for i in {1..2}; do
				
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=_dmarc.$Domain" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json")

				if command -v jq &> /dev/null; then
					ID=$(echo "$Code" | jq -r '.result[0].id // empty')
				else
					# Fallback to grep (less reliable)
					ID=$(echo "$Code" | grep -oP '"id":"\K[^"]+' | head -1)
				fi

				DeleteResult=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json")
				
				if echo "$DeleteResult" | grep -q '"success":true'; then
					DeletedDmarc=1
				else
					DeletedDmarc=0
				fi
		
			done
			
			# Add DMARC
			Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
			-H "Authorization: Bearer $APIToken" \
			-H "Content-Type: application/json" \
			--data "{\"type\":\"TXT\",\"name\":\"_dmarc.$Domain\",\"content\":\"$DMARC\",\"ttl\":3600,\"proxied\":false}")
			
			Message=$(echo "$Response" | jq -r '.errors[0].message')

			if echo "$Response" | jq -e '.success == true' > /dev/null; then
				echo "Adding DMARC Record for $Domain | Success"
			else
				echo "Adding DMARC Record for $Domain | $Message"
			fi

		fi

	
			
	fi
	
	exit 1
	
fi

if [ "$Action" = "DeleteTXTRecord" ] || [ "$Action" = "deletetxtrecord" ]; then

	Content="$Value"

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
			
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
						
				
						echo "Deleting TXT Record $Content | sudo tee $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&content=$Content&proxied=false&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"
											 
					fi

				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
			
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				echo "Deleting TXT Record v=spf1 +a +mx +ip4:$IPv4 $AdditionalSPFRecords ~all | sudo tee $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&content=$Content&proxied=false&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"

			fi

		fi
			
	fi
		
fi

if [ "$Action" = "cache" ] || [ "$Action" = "Cache" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then

				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
					if [ "$APIIgnore" = "1" ]; then
						echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
					else
					
					
						echo "Edge Cache for $Domain..."
						ZoneID=$(GetZoneID "$Domain")

						# Add
						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data '{"name": "Cache everything (Respect Origin)","kind": "zone","phase": "http_request_cache_settings","rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything for 1 Month","action_parameters":{"cache": true,"edge_ttl": {"mode":"respect_origin"}}}]}'

						# Get RuleID
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json")

						ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | tail -1)

						# Mode: respect_origin | override_origin
						if [[ $@ = *"--override"* ]]; then
					
							sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data '{"rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything for 1 Month","action_parameters": {"cache": true,"edge_ttl": {"mode":"override_origin","default":2678400}}}]}'
							
						else

							sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data '{"rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything (Respect Origin)","action_parameters": {"cache": true,"edge_ttl": {"mode":"respect_origin"}}}]}'

						fi
						
						# Browser Cache
						sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/browser_cache_ttl" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"value\":$BrowserCacheTTL}"
						
					fi

				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				echo "Edge cache for $Domain..."

				ZoneID=$(GetZoneID "$Domain")
				
				# Add
				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data '{"name": "Cache everything (Respect Origin)","kind": "zone","phase": "http_request_cache_settings","rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything for 1 Month","action_parameters":{"cache": true,"edge_ttl": {"mode":"respect_origin"}}}]}'

				# Get RuleID
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json")

				ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | tail -1)

				# Mode: respect_origin | override_origin
				if [[ $@ = *"--override"* ]]; then
					
					sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data '{"rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything for 1 Month","action_parameters": {"cache": true,"edge_ttl": {"mode": "override_origin","default": 2678400}}}]}'
					
				else
					
					sudo curl --silent --output /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data '{"rules": [{"action": "set_cache_settings","expression": "true","description": "Cache everything (Respect Origin)","action_parameters": {"cache": true,"edge_ttl": {"mode": "respect_origin"}}}]}'

				fi
				
				# Browser Cache
				sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/browser_cache_ttl" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"value\":$BrowserCacheTTL}"
				
				
			fi

		fi
			
	fi
		
fi


if [ "$Action" = "nocache" ] || [ "$Action" = "NoCache" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			if [[ ! $Domain = "m."* ]]; then
		
				APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
				if [ "$APIIgnore" = "1" ]; then
					echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
				else
				
					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						echo "Remove Edge Cache for $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						# Get RuleID
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json")

						ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | tail -1)

						sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json"


					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				echo "Remove Edge Cache for $Domain..."

				ZoneID=$(GetZoneID "$Domain")
				
				# Get RuleID
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json")

				ID=$(echo "$Code" | grep -oP '\"id\": "\K[^"]+' | tail -1)

				sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/rulesets/$ID" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json"
				
			fi

		fi
			
	fi
		
fi

if [ "$Type" = "DeleteRull" ] || [ "$Type" = "deleterull" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						echo "Deleting Page Rulls | sudo tee $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/pagerules?status=active&order=status&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 

						ID=$(echo "$Code" | grep -oP '\"result\"\:\[\{\"id\":"\K[^"]+')
				
						sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/pagerules/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"			 

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				echo "Deleting Page Rulls | sudo tee $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/pagerules?status=active&order=status&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
					 
				ID=$(echo "$Code" | grep -oP '\"result\"\:\[\{\"id\":"\K[^"]+')
				 
				sudo curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/pagerules/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"
					 
			fi

		fi
			
	fi
		
fi



if [ "$Type" = "DeleteMailRecord" ] || [ "$Type" = "deletemailrecord" ] || [ "$Type" = "DeleteMailRecords" ] || [ "$Type" = "deletemailrecords" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
					
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						echo "Deleting CNAME Record mail.$Domain & webmail.$Domain..."

						ZoneID=$(GetZoneID "$Domain")

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=webmail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")


						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"
							 

						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=MX&name=$Domain&content=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
		
				echo "Deleting CNAME Record mail.$Domain & webmail.$Domain..."

				ZoneID=$(GetZoneID "$Domain")

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=webmail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"
					 

				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=MX&name=$Domain&content=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"

			fi

		fi
			
	fi
		
fi

if [ "$Type" = "ResellerClubMail" ] || [ "$Type" = "resellerclubmail" ]; then

	# Count Websites 
	C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
	N=0

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))

						echo "[$N/$C] Reseller Club Mail | sudo tee $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						# Delete CNAME "webmail.$Domain"
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=webmail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json"

						# Delete MX "mail.$Domain"
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=MX&name=$Domain&content=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json"

						sudo curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx1.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"
						
						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx2.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"

						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx3.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"

						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"CNAME\",\"name\":\"pop\",\"content\":\"us2.pop.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"


						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"CNAME\",\"name\":\"imap\",\"content\":\"us2.imap.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"


						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"CNAME\",\"name\":\"smtp\",\"content\":\"us2.smtp.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"


						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"CNAME\",\"name\":\"webmail\",\"content\":\"us3.webmail.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"v=spf1 redirect=_spf.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

						sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"TXT\",\"name\":\"_dmarc.$Domain\",\"content\":\"v=DMARC1; p=quarantine; rua=mailto:info@$Domain; ruf=mailto:info@$Domain; adkim=r; aspf=r; fo=1; sp=quarantine;\",\"ttl\":3600,\"proxied\":false}"

					fi
				
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
					
				echo "Reseller Club Mail | sudo tee $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				# Delete CNAME "webmail.$Domain"
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=webmail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"

				# Delete MX "mail.$Domain"
				#Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=MX&name=$Domain&content=mail.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
				#			-H "Authorization: Bearer $APIToken" \
				#			-H "Content-Type: application/json")
				#	 
				#ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				#curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
				#	 -H "Authorization: Bearer $APIToken" \
				#	 -H "Content-Type: application/json"


				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx1.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"


				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx2.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"us2.mx3.mailhostbox.com\",\"ttl\":3600,\"priority\":100,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"CNAME\",\"name\":\"pop\",\"content\":\"us2.pop.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"CNAME\",\"name\":\"imap\",\"content\":\"us2.imap.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"CNAME\",\"name\":\"smtp\",\"content\":\"us2.smtp.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent --output /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"CNAME\",\"name\":\"webmail\",\"content\":\"us3.webmail.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"

				sudo curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"v=spf1 redirect=_spf.mailhostbox.com\",\"ttl\":3600,\"proxied\":false}"


				sudo curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json" \
					 --data "{\"type\":\"TXT\",\"name\":\"_dmarc.$Domain\",\"content\":\"v=DMARC1; p=quarantine; rua=mailto:info@$Domain; ruf=mailto:info@$Domain; adkim=r; aspf=r; fo=1; sp=quarantine;\",\"ttl\":3600,\"proxied\":false}"

			fi

		fi
			
	fi
		
fi


if [ "$Type" = "DeleteCNAME" ] || [ "$Type" = "deletecname" ] || [ "$Type" = "deletec" ] || [ "$Type" = "deletecnamerecord" ]; then

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))
					
						echo -ne "[$N/$C] Deleting CNAME Record $Value ($Domain) | "

						ZoneID=$(GetZoneID "$Domain")

						# Delete CNAME "$Value.$Domain"
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=$Value.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
							 
						ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

						sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							 -H "Authorization: Bearer $APIToken" \
							 -H "Content-Type: application/json"


					fi
					
				fi
				
			fi
				
		done
		
	else
	
		APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
		if [ "$APIIgnore" = "1" ]; then
			echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
		else
		
			
			if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
			
				ZoneID=$(GetZoneID "$Domain")
				
				echo -ne "[$N/$C] Deleting CNAME Record $Value ($Domain) | "
				
				ZoneID=$(GetZoneID "$Domain")

				# Delete CNAME "$Value.$Domain"
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=$Value.$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json"
					 
			
			fi
			
		fi
		
	fi
		
fi
		
if [ "$Action" = "nameservers" ] || [ "$Action" = "nameserver" ] || [ "$Action" = "dns" ] || [ "$Action" = "DNS" ]; then

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
				
					if [[ $(ROOTDomain "$Domain") = "1" ]]; then
				
						N=$(($N + 1))

						echo -ne "[$N/$C] Nameservers ($Domain)..."
						echo ""

						ZoneID=$(GetZoneID "$Domain")
											
						Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID" \
									-H "Authorization: Bearer $APIToken" \
									-H "Content-Type: application/json")
				
						Code=$(echo "$Code" | sed 's/","/,/g')
				
						Nameservers=$(echo "$Code" | grep -oP '\"name_servers\":\["\K[^"]+')

						IFS=',' read -r -a Array <<< "$Nameservers"

						echo "${Array[0]}"
						echo "${Array[1]}"
						
						if [ "$SpaceshipAPIKey" != "" ]; then

							Result=$(curl -X PUT "https://spaceship.dev/api/v1/domains/$Domain/nameservers" \
							-H "X-Api-Key: $SpaceshipAPIKey" \
							-H "X-Api-Secret: $SpaceshipAPISecret" \
							-H "Content-Type: application/json" \
							-d "{\"provider\": \"custom\",\"hosts\": [\"${Array[0]}\",\"${Array[1]}\"]}")
							
							if [[ "$Result" = *"Unknown"* ]]; then
								echo "Spaceship: ____"
							else
								echo "Spaceship: $Result"
							fi

						fi

						if [ "$DynadotAPIKey" != "" ]; then
						
							Result=$(curl -s "http://$DynadotIP:2020/dynadot/ns.php?Domain=$Domain&DynadotAPIKey=$DynadotAPIKey&NS1=${Array[0]}&NS2=${Array[1]}")
							echo "$Result"

						fi
				
						if [ "$ResellerclubAPIKey" != "" ]; then
						
							Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/ns.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey&NS1=${Array[0]}&NS2=${Array[1]}")
							if [[ "$Result" = *"Unknown"* ]]; then
								echo "ResellerClup: IP $ResellerclubIP Not Added to Whitelist"
							else
								echo "$Result"
							fi

						fi
						
						printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
						
					fi

				fi
				
			
				
			fi
				
		done
		
	else

		APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
		if [ "$APIIgnore" = "1" ]; then
			echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
		else
		
			
			if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
			
				if [[ $(ROOTDomain "$Domain") = "1" ]]; then
						
					ZoneID=$(GetZoneID "$Domain")
												
					echo -ne "Nameservers ($Domain)..."
					echo ""

					ZoneID=$(GetZoneID "$Domain")
										
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json")
					
					Code=$(echo "$Code" | sed 's/","/,/g')
					
					Nameservers=$(echo "$Code" | grep -oP '\"name_servers\":\["\K[^"]+')

					IFS=',' read -r -a Array <<< "$Nameservers"

					echo "${Array[0]}"
					echo "${Array[1]}"

					if [ "$SpaceshipAPIKey" != "" ]; then

						Result=$(curl -X PUT "https://spaceship.dev/api/v1/domains/$Domain/nameservers" \
						-H "X-Api-Key: $SpaceshipAPIKey" \
						-H "X-Api-Secret: $SpaceshipAPISecret" \
						-H "Content-Type: application/json" \
						-d "{\"provider\": \"custom\",\"hosts\": [\"${Array[0]}\",\"${Array[1]}\"]}")
						
						if [[ "$Result" = *"Unknown"* ]]; then
							echo "Spaceship: ____"
						else
							echo "Spaceship: $Result"
						fi

					fi


					if [ "$DynadotAPIKey" != "" ]; then
					
						Result=$(curl -s "http://$DynadotIP:2020/dynadot/ns.php?Domain=$Domain&DynadotAPIKey=$DynadotAPIKey&NS1=${Array[0]}&NS2=${Array[1]}")
						echo "$Result"

					fi

					if [ "$ResellerclubAPIKey" != "" ]; then
					
						Result=$(curl -s "http://$ResellerclubIP:2020/resellerclub/ns.php?Domain=$Domain&ResellerclubUserID=$ResellerclubUserID&ResellerclubAPIKey=$ResellerclubAPIKey&NS1=${Array[0]}&NS2=${Array[1]}")
						if [[ "$Result" = *"Unknown"* ]]; then
							echo "ResellerClup: IP $ResellerclubIP Not Added to Whitelist"
						else
							echo "$Result"
						fi

					fi
					

					printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'
					
				fi

			fi
			
		fi
			
	fi
		
fi

if [ "$Action" = "DeleteAllARecord" ] || [ "$Action" = "deleteallarecord" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

						ZoneID=$(GetZoneID "$Domain")
						
						for DeleteNo in {1..5}; do

							# Delete A Record (ALL)
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
								 
							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json"

						done						 

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				ZoneID=$(GetZoneID "$Domain")
				
				for DeleteNo in {1..5}; do

					# Delete A Record (ALL)
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")
						 
					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json"

				done						 
				
			fi

		fi
			
	fi
		
fi

if [ "$type" = "mx" ] && [ "$Action" = "delete" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

					DeleteMX "$Domain"
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				DeleteMX "$Domain"
					
			fi

		fi
			
	fi
		
fi

if [ "$Action" = "DeleteAllTXTRecord" ] || [ "$Action" = "deletealltxtrecord" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
		

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

						ZoneID=$(GetZoneID "$Domain")
						
						for DeleteNo in {1..5}; do

							# SPF
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&search=spf1&per_page=1&order=type&direction=desc&match=all" \
										-H "Authorization: Bearer $APIToken" \
										-H "Content-Type: application/json")
								 
							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
								 -H "Authorization: Bearer $APIToken" \
								 -H "Content-Type: application/json"
												 

							# DKIM
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=dkim._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
										-H "Authorization: Bearer $APIToken" \
										-H "Content-Type: application/json")
								 
							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
								 -H "Authorization: Bearer $APIToken" \
								 -H "Content-Type: application/json"


							# DMARC
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=_dmarc.$Domain&per_page=1&order=type&direction=desc&match=all" \
										-H "Authorization: Bearer $APIToken" \
										-H "Content-Type: application/json")
								 
							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
								 -H "Authorization: Bearer $APIToken" \
								 -H "Content-Type: application/json"

						done

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				ZoneID=$(GetZoneID "$Domain")

				for DeleteNo in {1..5}; do

					# SPF
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=$Domain&search=spf1&per_page=1&order=type&direction=desc&match=all" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json")
						 
					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						 -H "Authorization: Bearer $APIToken" \
						 -H "Content-Type: application/json"
										 

					# DKIM
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=dkim._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json")
						 
					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						 -H "Authorization: Bearer $APIToken" \
						 -H "Content-Type: application/json"


					# DMARC
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=_dmarc.$Domain&per_page=1&order=type&direction=desc&match=all" \
								-H "Authorization: Bearer $APIToken" \
								-H "Content-Type: application/json")
						 
					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
						 -H "Authorization: Bearer $APIToken" \
						 -H "Content-Type: application/json"
				done
				
			fi

		fi
			
	fi
		
fi

if [ "$Action" = "full" ] || [ "$Action" = "strict" ] || [ "$Action" = "flexible" ] || [ "$Action" = "off" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						echo "SSL [$Type] for $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						# SSL Flexible | Full | Strict
						sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/ssl" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"value\":\"$Type\"}"

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
			
				echo "SSL [$Type] for $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				# SSL Flexible | Full | Strict
				sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/ssl" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"value\":\"$Type\"}"
				
			fi

		fi
			
	fi
		
fi


if [ "$Action" = "browser" ] || [ "$Action" = "browsercache" ] || [ "$Action" = "browsercachettl" ]; then

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

						sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET BrowserCacheTTL='$Value' where Domain='$Domain'"

						echo "Browser Cache TTL [$Value] for $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						# Browser Cache
						sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/browser_cache_ttl" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"value\":$Value}"

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET BrowserCacheTTL='$Value' where Domain='$Domain'"

				echo "Browser Cache TTL [$Value] for $Domain..."

				ZoneID=$(GetZoneID "$Domain")

				# Browser Cache
				sudo curl --silent --output /dev/null -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZoneID/settings/browser_cache_ttl" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"value\":$Value}"
				
			fi

		fi
			
	fi
		
fi

if [ "$Type" = "DeleteMainARecord" ] || [ "$Type" = "deletemainarecord" ] || [ "$Type" = "deletemaina" ]; then

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))
						
						APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
						if [ "$APIIgnore" = "1" ]; then
							echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
						else

							echo -ne "[$N/$C] Deleting Main A Record ($Domain) | "
							ZoneID=$(GetZoneID "$Domain")

							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
										-H "Authorization: Bearer $APIToken" \
										-H "Content-Type: application/json")
								 
							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

							Status=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
								 -H "Authorization: Bearer $APIToken" \
								 -H "Content-Type: application/json")
								 
							if 	[[ "$Status" = *"success"* ]]; then
							
								echo -ne "Success."
								
							else
							
								echo -ne "Failed."

							fi
							
							echo ""
							
						fi

					fi
					
				fi
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				ZoneID=$(GetZoneID "$Domain")
				Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=A&name=$Domain&page=1&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")
					 
				ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

				Status=$(curl --silent -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					 -H "Authorization: Bearer $APIToken" \
					 -H "Content-Type: application/json")
					 
			fi

		fi
			
	fi
		
fi


if [ "$Type" = "www" ] || [ "$Type" = "webmail" ] || [ "$Type" = "go" ] || [ "$Type" = "ftp" ] || [ "$Type" = "m" ]; then

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))
					
						ZoneID=$(GetZoneID "$Domain")

						if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then
						
							echo -ne "[$N/$C] Adding $Type CNAME Record ($Domain) | "

							Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data "{\"type\":\"CNAME\",\"name\":\"$Type\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":$Proxy}")
								 
							if 	[[ "$Status" = *"already exists"* ]]; then
							
								echo -ne "Record already exists."

							elif [[ "$Status" = *"success"* ]]; then
							
								echo -ne "Success."
								
							else
							
								echo -ne "Failed."

							fi
							
						else
						
							echo -ne "[$N/$C] Skipping Subdomain ($Domain)"
							
						fi
						
						echo ""
						
					fi
					
				fi								
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
		
				ZoneID=$(GetZoneID "$Domain")
				
				if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then
				
					echo -ne "Adding $Type CNAME Record ($Domain) | "

					Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"CNAME\",\"name\":\"$Type\",\"content\":\"$Domain\",\"ttl\":3600,\"proxied\":$Proxy}")
						 
					if 	[[ "$Status" = *"already exists"* ]]; then
					
						echo -ne "Record already exists."

					elif [[ "$Status" = *"success"* ]]; then
					
						echo -ne "Success."
						
					else
					
						echo -ne "Failed."

					fi
					
				else
					echo -ne "[$N/$C] Skipping Subdomain ($Domain)"			
				fi
				
			fi
				
			echo ""

		fi
			
	fi
		
fi

if [ "$Type" = "dkim" ]; then

	C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select count(*) from Site where Domain not like 'm.%';")

	if [ "$Domain" = "all" ]; then

		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if sudo test -d "/var/cpanel/users" ; then
					Domain=$(sudo grep ^DNS= /var/cpanel/users/$Domain | cut -d= -f2)
				fi

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))
					
						ZoneID=$(GetZoneID "$Domain")

						if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then
						
							echo -ne "[$N/$C] Adding DKIM TXT Record ($Domain) | "

							# DELETE DKIM
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=dkim._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")

							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')
							
							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json"
							
							# DELETE DKIM (Default)
							Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=default._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json")

							ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')
							
							sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json"

							if sudo test -d "/var/cpanel/users" ; then
							
								# GET DKIM (cPanel)
								Code=$(sudo cat /var/cpanel/domain_keys/public/$Domain | sed '1d;$d' | tr -d '\n')
								DKIM="v=DKIM1; k=rsa; p=$Code"
								
								Host="default._domainkey.$Domain"
								
							else
							
								# GET DKIM
								Code=$(sudo cat /etc/opendkim/$Domain/dkim.txt | sed -n '2p')
								IFS='"' read -r -a Array <<< "$Code"
								DKIM="v=DKIM1; k=rsa; ${Array[1]}"
								
								Host="dkim._domainkey.$Domain"
							
							fi

							Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
							-H "Authorization: Bearer $APIToken" \
							-H "Content-Type: application/json" \
							--data "{\"type\":\"TXT\",\"name\":\"$Host\",\"content\":\"$DKIM\",\"ttl\":3600,\"proxied\":false}")
							
							if [[ "$Status" = *"\"success\":true"* ]]; then
							
								echo -ne "Success."
								
							else
							
								echo -ne "Failed."

							fi
							
						else
						
							echo -ne "[$N/$C] Skipping Subdomain ($Domain)"
							
						fi
						
						echo ""
						
					fi
					
				fi								
				
			fi
				
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
				
				ZoneID=$(GetZoneID "$Domain")
				if [[ $(ROOTDomain "$Domain") = "1" ]] || [ "$ZoneID" != "" ]; then

					echo -ne "Adding DKIM TXT Record ($Domain) | "

					# DELETE DKIM
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=dkim._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")

					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json"
				
					# DELETE DKIM (Default)
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=TXT&name=default._domainkey.$Domain&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")

					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')
					
					sudo curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json"
				
					if sudo test -d "/var/cpanel/users" ; then
					
						# GET DKIM (cPanel)
						Code=$(sudo cat /var/cpanel/domain_keys/public/$Domain | sed '1d;$d' | tr -d '\n')
						DKIM="v=DKIM1; k=rsa; p=$Code"
						
						Host="default._domainkey.$Domain"
						
					else
					
						# GET DKIM
						Code=$(sudo cat /etc/opendkim/$Domain/dkim.txt | sed -n '2p')
						IFS='"' read -r -a Array <<< "$Code"
						DKIM="v=DKIM1; k=rsa; ${Array[1]}"
						
						Host="dkim._domainkey.$Domain"
					
					fi

					Status=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"TXT\",\"name\":\"$Host\",\"content\":\"$DKIM\",\"ttl\":3600,\"proxied\":false}")

					if [[ "$Status" = *"\"success\":true"* ]]; then
					
						echo -ne "Success."
						
					else
					
						echo -ne "Failed."

					fi
					
				else
				
					echo -ne "Skipping Subdomain ($Domain)"
					
				fi
				
			fi
			
			echo ""

		fi
			
	fi
		
fi

if [ "$Type" = "txt" ]; then

	if [ "$Domain" = "all" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))

						ZoneID=$(GetZoneID "$Domain")

						# Add TXT Record
						Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"TXT\",\"name\":\"$Name\",\"content\":\"$Value\",\"ttl\":3600,\"proxied\":false}")
						
						Message=$(echo "$Response" | jq -r '.errors[0].message')

						if echo "$Response" | jq -e '.success == true' > /dev/null; then
							echo "[$N/$C] Adding TXT Record for $Domain | Success"
						else
							echo "[$N/$C] Adding TXT Record for $Domain | $Message"
						fi

					fi
					
				fi
				
			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				ZoneID=$(GetZoneID "$Domain")

				# Add TXT Record
				Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"TXT\",\"name\":\"$Name\",\"content\":\"$Value\",\"ttl\":3600,\"proxied\":false}")
				
				Message=$(echo "$Response" | jq -r '.errors[0].message')

				if echo "$Response" | jq -e '.success == true' > /dev/null; then
					echo "Adding TXT Record for $Domain | Success"
				else
					echo "Adding TXT Record for $Domain | $Message"
				fi
				
			fi

		fi
			
	fi
	
	exit 1
	
fi

if [ "$Type" = "cname" ]; then
	
	if [ "$Domain" = "all" ] || [ "$Domain" = "" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))

						ZoneID=$(GetZoneID "$Domain")

						# Add CNAME TXT Record
						Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"CNAME\",\"name\":\"$Name\",\"content\":\"$Value\",\"ttl\":3600,\"proxied\":$Proxy}")
						
						Message=$(echo "$Response" | jq -r '.errors[0].message')

						if echo "$Response" | jq -e '.success == true' > /dev/null; then
							echo "[$N/$C] Adding CNAME Record for $Domain | Success"
						else
							echo "[$N/$C] Adding CNAME Record for $Domain | $Message"
						fi

					fi
					
				fi
				
			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				ZoneID=$(GetZoneID "$Domain")
				
				if [ "$Action" = "delete" ]; then
				
					# Delete CNAME Record
					Code=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=CNAME&name=$Name&page=1&per_page=1&order=type&direction=desc&match=all" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")

					ID=$(echo "$Code" | grep -oP '\"id\":"\K[^"]+')

					Response=$(curl --silent --output /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$ID" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json")
					
					Message=$(echo "$Response" | jq -r '.errors[0].message')

					if echo "$Response" | jq -e '.success == true' > /dev/null; then
						echo "Deleting CNAME Record for $Domain | Success"
					else
						echo "Deleting CNAME Record for $Domain | $Message"
					fi
					
				
				else

					# Add CNAME TXT Record
					Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
					-H "Authorization: Bearer $APIToken" \
					-H "Content-Type: application/json" \
					--data "{\"type\":\"CNAME\",\"name\":\"$Name\",\"content\":\"$Value\",\"ttl\":3600,\"proxied\":$Proxy}")
					
					Message=$(echo "$Response" | jq -r '.errors[0].message')

					if echo "$Response" | jq -e '.success == true' > /dev/null; then
						echo "Adding CNAME Record for $Domain | Success"
					else
						echo "Adding CNAME Record for $Domain | $Message"
					fi
					
				fi
				
			fi

		fi
			
	fi
	
	exit 1
	
fi

if [ "$Type" = "mx" ]; then

	if [ "$Value" = "" ]; then
		Value="imap.$Domain"
	fi
	
	if [ "$Domain" = "all" ] || [ "$Domain" = "" ]; then

		# Count Websites 
		C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)
		N=0
		
		cd /home
		for Domain in *
		do
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			

				if [[ ! $Domain = "m."* ]]; then

					if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
					
						N=$(($N + 1))
					
						echo "[$N/$C] Adding MX Record for $Domain..."

						ZoneID=$(GetZoneID "$Domain")

						# Add MX Record
						Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
						-H "Authorization: Bearer $APIToken" \
						-H "Content-Type: application/json" \
						--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"$Value\",\"ttl\":3600,\"priority\":$Priority,\"proxied\":false}")
						
						Message=$(echo "$Response" | jq -r '.errors[0].message')

						if echo "$Response" | jq -e '.success == true' > /dev/null; then
							echo "[$N/$C] Adding MX Record for $Domain | Success"
						else
							echo "[$N/$C] Adding MX Record for $Domain | $Message"
						fi

					fi
					
				fi
				
			fi
			
		done
		
	else
		
		if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then
		
			APIIgnore=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select APIIgnore from Site where Domain='$Domain'")
			if [ "$APIIgnore" = "1" ]; then
				echo "[$N/$C] Skipping DNS Configuration for $Domain | API Ignore Domains"
			else
			
				ZoneID=$(GetZoneID "$Domain")

				# Add MX Record
				Response=$(curl --silent -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" \
				-H "Authorization: Bearer $APIToken" \
				-H "Content-Type: application/json" \
				--data "{\"type\":\"MX\",\"name\":\"$Domain\",\"content\":\"$Value\",\"ttl\":3600,\"priority\":$Priority,\"proxied\":false}")
				
				Message=$(echo "$Response" | jq -r '.errors[0].message')

				if echo "$Response" | jq -e '.success == true' > /dev/null; then
					echo "Adding MX Record for $Domain | Success"
				else
					echo "Adding MX Record for $Domain | $Message"
				fi
				
			fi

		fi
			
	fi
	
	exit 1
	
fi
