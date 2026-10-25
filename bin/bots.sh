#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

WS=$(</usr/local/goadmio/linux/ws.db)
OS=$(</usr/local/goadmio/linux/os.db)

TimeStamp=$(date +%s)

OUTPUT="BOT -20000 Blocked"
OUTPUT="$OUTPUT\n--- -10000 -------"

Bots=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "select Name from Bot;" | tr '\n' '|' | sed -e 's/^|//' -e 's/|$//')

IFS='|' read -ra BotsArray <<<"$Bots"
for Bot in "${BotsArray[@]}"; do

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "INSERT OR IGNORE INTO Bot (Name,Description,Block,TimeStamp) VALUES ('$Bot','$Description','0','$TimeStamp')"

    Block=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "select Block from Bot where Name='$Bot';")

    N=$(sudo grep -o "$Bot" $LOG | wc -l)

    if [ "$N" -gt "0" ]; then
        OUTPUT="$OUTPUT\n$Bot $N $Block"
    fi

done

sudo cat "$LOG" | awk -F'|' '{ print $13 }' | grep -ioE '([a-zA-Z0-9_.-]*(bot|spider|agent|client|crawl|http|index|search|scraper|fetcher|scan|crawler)[a-zA-Z0-9_.-]*)' | sort -u | sudo tee /usr/local/goadmio/tmp/bot.db > /dev/null >/dev/null
File="/usr/local/goadmio/tmp/bot.db"
while IFS= read Bot; do

    if [[ ! "$Bot" = "https" ]] && [[ ! "$Bot" = "bots" ]] && [[ ! "$Bot" = "robot" ]] && [[ ! "$Bot" = "robots" ]] && [[ ! "$Bot" = "Client" ]] && [[ ! "$Bot" = *"."* ]]; then

        # Converts both "$Bots" and "$Bot" to lowercase before comparison
        if [[ ! "${Bots,,}" = *"${Bot,,}"* ]]; then

            # Detect Bad Bot
            if ! echo "$Bot" | grep -qiE "(google|yandex|adsbot|bing)"; then

                if echo "$Bot" | grep -qiE "(bot|crawl|spider|scan|activity)"; then

                    if [[ "$Bot" =~ ^[a-zA-Z0-9\-]+$ ]] && [[ ${#Bot} -ge 8 ]]; then

                        # Bad Bot
                        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "INSERT OR IGNORE INTO Bot (Name,Description,Block,TimeStamp) VALUES ('$Bot','$Description','1','$TimeStamp')"

                    fi

                fi

            fi

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "INSERT OR IGNORE INTO Bot (Name,Description,Block,TimeStamp) VALUES ('$Bot','$Description','0','$TimeStamp')"

            Block=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/bot.db "select Block from Bot where Name='$Bot';")

            N=$(sudo grep -o "$Bot" $LOG | wc -l)

            if [ "$N" -gt "0" ]; then
                OUTPUT="$OUTPUT\n$Bot $N $Block"
            fi

        fi

    fi

done <"$File"

OUTPUT=$(echo -ne $OUTPUT | column -t | sort -n -k 2)
OUTPUT="${OUTPUT/-20000/Visits}"
OUTPUT="${OUTPUT/-10000/------}"
echo "$OUTPUT"
