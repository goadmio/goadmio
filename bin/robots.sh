#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/robots "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)

cd /home
for Domain in *; do

    if sudo test -d /home/$Domain/www ; then

        echo "Creating a robots.txt File for $Domain..."

        echo "User-agent: *" | sudo tee /home/$Domain/www/robots.txt >/dev/null
        echo "Disallow: /admin/" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
        echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
        echo "Sitemap: https://www.$Domain/sitemap.xml" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

        if [ "$Hostname" = "ns1.mls.eg" ] || [ "$Hostname" = "ns2.mls.eg" ] || [ "$Hostname" = "ns3.mls.eg" ] || [ "$1" = "block" ]; then

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: Amazonbot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: PetalBot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: DataForSeoBot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: serpstatbot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: dotbot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

            echo "" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "User-agent: SemrushBot" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null
            echo "Disallow: /" | sudo tee -a /home/$Domain/www/robots.txt >/dev/null

        fi

    fi

done
