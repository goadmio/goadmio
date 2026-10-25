#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# Usage: crawler
# Usage: crawler all hostname

T=$(date +'%s')

if [ "$2" = "" ]; then
    Hostname=$(</etc/hostname)
else
    Hostname=$2
fi

if [ "$Hostname" = "mail.mls.eg" ] || [ "$Hostname" = "host.mls.eg" ]; then

    MainDomain="www.mls.eg"

    Domains=$(
        sudo wget https://crm.mls.eg/include/vhost/site.php &
        T=$T -q -O -
    )
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "host.mlseg.com" ]; then

    MainDomain="www.mlseg.com"

    Domains="bb.mls.eg"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp.propertyads.org" ] || [ "$Hostname" = "smtp.propertyads.com.eg" ] || [ "$Hostname" = "smtp.propertyads.eg" ]; then

    MainDomain="www.propertyads.org"

    Domains=$(sudo wget https://propertyads.org/include/vhost/site.php -q -O -)
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp.mls.eg" ]; then

    MainDomain="www.mls.eg"

    Domains="egypt.mls.eg,masegypt.com.eg"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp.crmrealty.net" ]; then

    MainDomain="www.gbp.ae"

    Domains="www.mlsae.com"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp-uae.mls.red" ]; then

    MainDomain="uae.mls.red"

    Domains="uae.mls.red"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp-saudi.mls.red" ]; then

    MainDomain="saudi.mls.red"
    Domains="saudi.mls.red"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

if [ "$Hostname" = "smtp-egypt.mls.red" ]; then

    MainDomain="egypt.mls.red"
    Domains="egypt.mls.red"
    DomainsArray=$(echo $Domains | tr "," "\n")

fi

echo "Hostname: $Hostname"

W=$(date +%a)

Limit=50

for Domain in $DomainsArray; do

    if [[ $# -eq 0 ]] || [ "$1" = "all" ]; then

        sudo /go/fightmode $Domain off

        ToID=$(curl -s "https://$Domain/plugin/mls.php?MaxID=1" | grep -oE '[0-9]+' | head -1)

        if [ "$ToID" = "" ]; then
            echo "Invalid MaxID"
            exit 1
        fi

        if [ "$W" = "Fri" ]; then

            FromID=1

        else

            if [ "$1" = "all" ]; then

                FromID=1

            elif [ "$ToID" -gt "10000" ]; then

                FromID=$(($ToID - 10000))

            else

                FromID=1

            fi

        fi

        echo "Crawling $Domain $FromID - $ToID"

        for ((N = $ToID; N >= $FromID; N -= $Limit)); do

            echo "https://$MainDomain/admin/iframe/mls.php?Limit=$Limit&FromID=$N&XMLFileUrl=https://$Domain&UpdateExists=1&T=$T"

            sudo curl -s "https://$MainDomain/admin/iframe/mls.php?Limit=$Limit&FromID=$N&XMLFileUrl=https://$Domain&UpdateExists=1&T=$T" >temp.txt

        done

    else

        # Only New Ads

        echo "Crawling $Domain (New Ads)"

        echo "https://$MainDomain/admin/iframe/mls.php?Limit=$Limit&FromID=&XMLFileUrl=https://$Domain&UpdateExists=1&T=$T"

        sudo curl -s "https://$MainDomain/admin/iframe/mls.php?Limit=$Limit&FromID=&XMLFileUrl=https://$Domain&UpdateExists=1&T=$T" >temp.txt

    fi

done
