#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

for arg in "$@"; do

    Requests=$(sudo wget http://$arg:2020/file.php?Action=Requests -q -t 1 -T 10 --no-check-certificate -O -)

    if [[ "$Requests" =~ ^[0-9]+$ ]]; then
        echo "$arg $Requests" | sudo tee -a /etc/compare >/dev/null
    fi

done

if sudo test ! -f /etc/compare ; then
    exit 1
fi

sudo awk '
    {sum += $2; names[NR]=$1; nums[NR]=$2}
    END {
        for (i=1; i<=NR; i++) {
            printf "%s %.1f%%\n", names[i], (nums[i]/sum)*100
        }
    }
' /etc/compare

if sudo test -f /etc/compare ; then
    sudo rm -rf /etc/compare
fi
