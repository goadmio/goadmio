#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

UAE=$(sudo wget 'https://www.goadmio.com/junk/uae.txt' -q -O - | tr -d '\r')
while read URL; do

    # TRIM
    URL=$(echo $URL | xargs echo -n)

    echo "$URL"
    sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" $URL >c.c

    sudo curl -s $URL | grep -oP '(?<=href=")[^"]*' | while read -r Link; do

        if [[ "$Link" = *"/en/"* ]]; then
            echo "$Link"
            sudo curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" $Link >c.c

        fi

    done

done <<<"$UAE"
