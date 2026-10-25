#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ $# -eq 0 ]; then

    sudo cat /var/log/maillog | grep -o 'Subject:.*' | sed 's/Subject: //' | sed 's/ from .*//' | cut -c1-75 | sort | uniq -ci | sort -nr | head -25

else

    sudo cat /var/log/maillog | grep -o 'Subject:.*' | sed 's/Subject: //'

fi
