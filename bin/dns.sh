#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/dns "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

if [ "$Domain" = "quick" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

            N=$(($N + 1))

            echo "[$N/$C] $Domain..."

            sudo /go/cloudflare --domain $Domain --action DeleteMainARecord
            sudo /go/cloudflare --domain $Domain adda --proxy off

        fi

    done

elif [ "$Domain" = "all" ]; then

    # Count Websites
    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" -print | wc -l)
    N=0

    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

            N=$(($N + 1))

            echo "[$N/$C] $Domain..."

            CountMX=$(dig +noall +answer -t mx $Domain | wc -l)
            MXLookup=$(dig +noall +answer -t mx $Domain)
            if [ "$CountMX" -ge "2" ] || [[ "$MXLookup" = *"google"* ]] || [[ "$MXLookup" = *"zoho"* ]] || [[ "$MXLookup" = *"outlook"* ]]; then
                Edit="0"
            else
                Edit="1"
            fi

            sudo /go/cloudflare --domain $Domain --action addsite

            if [ "$Edit" = "1" ]; then
                sudo /go/cloudflare --domain $Domain --action DeleteAllTXTRecord
                sudo /go/cloudflare --domain $Domain --action DeleteAllMXRecord
            fi

            if [[ $@ = *"--cache"* ]]; then

                sudo /go/cloudflare --domain $Domain --proxy on

                if [[ $@ = *"--override"* ]]; then
                    sudo /go/cloudflare --domain $Domain --action cache --mode override
                else
                    sudo /go/cloudflare --domain $Domain --action cache --mode respect
                fi

            elif [[ $@ = *"--nocache"* ]]; then

                sudo /go/cloudflare --domain $Domain --proxy on
                sudo /go/cloudflare --domain $Domain --action nocache

            else
                sudo /go/cloudflare --domain $Domain --proxy off
            fi

            sudo /go/cloudflare --domain $Domain --action nameservers

            if sudo test ! -d /etc/letsencrypt/live/$Domain ; then
                sudo /go/ssl $Domain --skipbackupssl
            fi

        fi

    done

else

    if sudo test -d "/home/$Domain/www"  || sudo test -d "/scripts" ; then

        CountMX=$(dig +noall +answer -t mx $Domain | wc -l)
        MXLookup=$(dig +noall +answer -t mx $Domain)
        if [ "$CountMX" -ge "2" ] || [[ "$MXLookup" = *"google"* ]] || [[ "$MXLookup" = *"zoho"* ]] || [[ "$MXLookup" = *"outlook"* ]]; then
            Edit="0"
        else
            Edit="1"
        fi

        sudo /go/cloudflare --domain $Domain --action addsite

        if [ "$Edit" = "1" ]; then
            sudo /go/cloudflare --domain $Domain --action DeleteAllTXTRecord
            sudo /go/cloudflare --domain $Domain --action DeleteAllMXRecord
        fi

        if [[ $@ = *"--cache"* ]]; then

            sudo /go/cloudflare --domain $Domain --proxy on

            if [[ $@ = *"--override"* ]]; then
                sudo /go/cloudflare --domain $Domain --action cache --mode override
            else
                sudo /go/cloudflare --domain $Domain --action cache --mode respect
            fi

        elif [[ $@ = *"--nocache"* ]]; then

            sudo /go/cloudflare --domain $Domain --proxy on
            sudo /go/cloudflare --domain $Domain --action nocache

        else
            sudo /go/cloudflare --domain $Domain --proxy off
        fi

        sudo /go/cloudflare --domain $Domain --action nameservers

        if sudo test ! -d /etc/letsencrypt/live/$Domain ; then
            sudo /go/ssl $Domain --skipbackupssl
        fi

    else

        echo "$Domain not exists."

    fi

fi

# Forward URL
# curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZoneID/pagerules" \
# -H "Authorization: Bearer $APIToken" \
# -H "Content-Type: application/json" \
#  --data '{"targets":[{"target": "url","constraint": {"operator": "matches","value": "mlsrealty.ae/*"}}],"actions": [{"id":"forwarding_url","value": {"url": "https://mls.eg","status_code": 301}}],"priority":1,"status":"active"}'
