#!/bin/bash

if sudo test -f /usr/local/goadmio/linux/os.db ; then
    OS=$(</usr/local/goadmio/linux/os.db)
fi

if sudo test -f /usr/local/goadmio/linux/ws.db ; then
    WS=$(</usr/local/goadmio/linux/ws.db)
fi

VERSION=$(</usr/local/goadmio/linux/version.db)
ProgressCode=$(</usr/local/goadmio/install/progress.html)
Elapsed=$(</usr/local/goadmio/db/elapsed.db)
Machine=$(</usr/local/goadmio/linux/machine.db)
Progress=$(echo "$ProgressCode" | cut -d '|' -f1)

ProgressBar() {
    ProgressMessage=$1

    if command -v dnf &>/dev/null; then
        Progress=$(sudo awk "BEGIN {print $Progress+0.64; exit}")
    else
        Progress=$(sudo awk "BEGIN {print $Progress+1.05; exit}")
    fi

    TimeStamp=$(date +'%s')
    ElapsedSeconds=$(($TimeStamp - $Elapsed))
    ElapsedH=$((ElapsedSeconds / 3600))
    ElapsedM=$(((ElapsedSeconds / 60) % 60))
    ElapsedS=$((ElapsedSeconds % 60))
    TimeElapsed=$(printf "%02d:%02d:%02d\n" $ElapsedH $ElapsedM $ElapsedS)

    echo "$Progress|$1|$TimeElapsed|$OS $VERSION|$Machine" | sudo tee /usr/local/goadmio/install/progress.html >/dev/null

    printf '%*s\n' "$(tput cols 2>/dev/null || echo 40)" | tr ' ' '-'

    echo "${ProgressMessage}..."

    if [[ "$@" = *"--progress"* ]]; then

        ProgressValue=$(sudo awk "BEGIN {print $ProgressValue+1.9; exit}")
        echo "$ProgressValue" | cut -d. -f1

    fi
}

LOG() {
    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        if [ "$WS" = "Apache" ]; then

            if sudo test -f /var/log/httpd/access.log ; then
                LOG="/var/log/httpd/access.log"
            else
                LOG="/var/log/httpd/access_log"
            fi

        else
            LOG="/var/log/nginx/access.log"
        fi

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        if [ "$WS" = "Apache" ]; then

            if sudo test -f /var/log/apache2/access.log ; then
                LOG="/var/log/apache2/access.log"
            else
                LOG="/var/log/apache2/access.log"
            fi

        else
            LOG="/var/log/nginx/access.log"
        fi

    fi

    echo "$LOG"
}

WHOIS() {
    local IP="$1"

    if sudo test -f "/var/log/go/ip/whois/$IP" ; then

        Whois=$(<"/var/log/go/ip/whois/$IP")
        echo "$Whois"
        return 0

    fi

    Whois=$(sudo /usr/bin/whois "$IP")

    if [[ "$Whois" = *"service not known"* ]] || [[ "$Whois" = *"Unable to connect"* ]]; then
        echo "$Whois"
    else
        echo "$Whois"
        echo "$Whois" | sudo tee "/var/log/go/ip/whois/$IP" >/dev/null
    fi
    return 0

}

COMPANY() {
    local Whois="$1"
    local IP="$2"

    if sudo test -f "/var/log/go/ip/company/$IP" ; then

        Company=$(<"/var/log/go/ip/company/$IP")
        echo "$Company"
        return 0

    fi

    Descr=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="descr"{print $2;exit}' | xargs echo -n)

    Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="organization"{print $2;exit}' | xargs echo -n)

    if [ "$Organization" = "" ]; then
        Organization=$(echo "$Whois" | tac | awk -F: 'tolower($1)=="org-name"{print $2;exit}' | xargs echo -n)
    fi

    if [ "$Organization" = "" ]; then
        Organization=$(echo "$Whois" | awk '/role:/ {print $2; exit}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    fi

    if [ "$Descr" != "" ] && [ "$Organization" != "" ]; then
        Company="$Descr ($Organization)"
    elif [ "$Descr" != "" ]; then
        Company="$Descr"
    elif [ "$Organization" != "" ]; then
        Company="$Organization"
    else
        Company=""
    fi

    if [ "$Company" = "" ]; then
        echo "-"
    else
        echo "$Company"
        echo "$Company" | sudo tee "/var/log/go/ip/company/$IP" >/dev/null
    fi

    return 0

}

COUNTRY() {
    local IP="$1"

    # Remove /24
    IP="${IP%/24}"

    if [[ ! "$LOG" = *"/"* ]]; then
        echo "NO LOG"
        return 0
    fi

    if sudo test -f "/var/log/go/ip/country/$IP" ; then

        CountryCode=$(<"/var/log/go/ip/country/$IP")
        echo "$CountryCode"
        return 0

    fi

    # LOCAL Source (CF)
    CountryCode=$(sudo awk -v IP="$IP" '$4 == IP && $5 ~ /^[A-Z]{2}$/ {print $5; exit}' "$LOG")
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source 1: ipapi.co
    CountryCode=$(curl -s --max-time 2 --connect-timeout 2 "https://ipapi.co/${IP}/country_code/" 2>/dev/null | tr -d '[:space:]')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source 2: ipinfo.io
    CountryCode=$(curl -s --max-time 2 --connect-timeout 2 "https://ipinfo.io/${IP}/country" 2>/dev/null | tr -d '[:space:]')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source 3
    CountryCode=$(curl -s --max-time 2 --connect-timeout 2 "https://api.db-ip.com/v2/free/$IP" | jq -r '.countryCode')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source 4: ip-api.com
    CountryCode=$(curl -s --max-time 2 --connect-timeout 2 "http://ip-api.com/line/${IP}?fields=countryCode" 2>/dev/null | tr -d '[:space:]')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source 5
    CountryCode=$(curl -s --max-time 2 --connect-timeout 2 "https://ipwho.is/$IP" | jq -r '.country_code')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        echo "$CountryCode" | sudo tee "/var/log/go/ip/country/$IP" >/dev/null
        return 0
    fi

    # Source (Whois)
    Whois=$(WHOIS "$IP")
    CountryCode=$(echo "$Whois" | awk 'tolower($1) == "country:" { print $2;exit }')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        return 0
    fi

    # Source (geoiplookup)
    CountryCode=$(geoiplookup "$IP" | head -1 | awk {' print $4 '} | sed 's/[^A-Za-z]//g')
    if [[ ${#CountryCode} -eq 2 && "$CountryCode" =~ ^[A-Z]{2}$ ]]; then
        echo "$CountryCode"
        return 0
    fi

    # If all sources fail
    echo "-"
    return 0
}

CITY() {
    local IP="$1"

    if sudo test -f "/var/log/go/ip/city/$IP" ; then

        City=$(<"/var/log/go/ip/city/$IP")
        echo "$City"
        return 0

    fi

    # Source 1
    City=$(curl -s --max-time 2 --connect-timeout 2 "https://ipapi.co/$IP/city/")
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    # Source 2
    City=$(curl -s --max-time 2 --connect-timeout 2 "https://ipinfo.io/$IP/json" | grep '"city"' | awk -F'"' '{print $4}' | xargs echo -n)
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    # Source 3
    City=$(curl -s --max-time 2 --connect-timeout 2 "https://api.db-ip.com/v2/free/$IP" | jq -r '.city')
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    # Source 4: ip-api.com
    City=$(curl -s --max-time 2 --connect-timeout 2 "http://ip-api.com/line/${IP}?fields=city" 2>/dev/null | tr -d '[:space:]')
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    # Source 5
    City=$(curl -s --max-time 2 --connect-timeout 2 "https://ipwho.is/$IP" | jq -r '.city')
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    Whois=$(WHOIS "$IP")
    City=$(echo "$Whois" | grep -i "city:" | head -n1 | awk -F: '{print $2}' | sed 's/^[ \t]*//')
    if [[ ${#City} -ge 3 ]] && [[ ${#City} -le 25 ]] && [ "$City" != "null" ]; then
        echo "$City"
        echo "$City" | sudo tee "/var/log/go/ip/city/$IP" >/dev/null
        return 0
    fi

    # If all sources fail
    echo "-"
    return 0
}

ALTER() {
    local CreateStatement="$1"

    # Extract table name from CREATE statement
    local TableName=$(echo "$CreateStatement" | grep -oP 'CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?\K[a-zA-Z_][a-zA-Z0-9_]*' | head -1)

    # If the above fails, try alternative extraction
    if [ -z "$TableName" ]; then
        TableName=$(echo "$CreateStatement" | sed -E 's/CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?([a-zA-Z_][a-zA-Z0-9_]*).*/\2/' | awk '{print $1}')
    fi

    # Fallback to extracting anything between TABLE and (
    if [ -z "$TableName" ]; then
        TableName=$(echo "$CreateStatement" | sed -n 's/.*TABLE \([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p' | head -1)
    fi

    # Check if table name was found
    if [ -z "$TableName" ]; then
        echo "Error: Could not extract table name from CREATE statement"
        return 1
    fi

    # Convert table name to lowercase for database file
    local DBFile=$(echo "$TableName" | tr '[:upper:]' '[:lower:]')
    local DBPath="/var/lib/sqlite/${DBFile}.db"

    # Extract field definitions between the first '(' and last ')'
    local Fields=$(echo "$CreateStatement" | grep -oP '\(.*\)' | sed 's/^[()]//;s/[()]$//')

    # Parse each field (comma-separated, but handle embedded commas in definitions)
    IFS=',' read -ra FieldArray <<<"$Fields"

    local FieldCount=0

    for field in "${FieldArray[@]}"; do
        # Trim whitespace
        field=$(echo "$field" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty Fields
        [ -z "$field" ] && continue

        FieldCount=$((FieldCount + 1))

        # Skip the first field only
        if [ "$FieldCount" -eq 1 ]; then
            continue
        fi

        # Extract field name (first word)
        FieldName=$(echo "$field" | awk '{print $1}')

        # Extract the rest of the field definition
        FieldDefinition=$(echo "$field" | sed 's/^[^[:space:]]*[[:space:]]*//')

        # Generate and execute ALTER TABLE statement
        # echo "sqlite3 \"$DBPath\" \"ALTER TABLE $TableName ADD $FieldName $FieldDefinition\""
        # sqlite3 "$DBPath" "ALTER TABLE $TableName ADD $FieldName $FieldDefinition" 2>/dev/null || echo "Warning: Could not add field $FieldName (may already exist)"

        sudo sqlite3 "$DBPath" "ALTER TABLE $TableName ADD $FieldName $FieldDefinition" >/dev/null 2>&1

    done
}