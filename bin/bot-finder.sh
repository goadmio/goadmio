#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function
LOG=$(LOG)

TimeStamp=$(date +%s)

sudo cat $LOG | awk -F'|' '{ print $13 }' | sort -u >/usr/local/goadmio/tmp/bot-finder.db

# Broswers and Good Bots

Broswers="Opera|Mozilla|Mozlila|Safari|Chrome|BlackBerry|Nokia|Sony|SAMSUNG|curl|wget|google|WhatsApp|Linux|Dalvik|facebook|Android|FBAN|Hello|ChatGPT|Links|Adobe|ALittle|Download|Gulper|HTC_Dream|Microsoft|More|MSIE|Uzbl|Meta|Midori|MOT|nook|openai|Perplexity|POLARIS|Recorded|Vodafone|W3C|python"

IFS='|' read -ra BroswersArray <<<"$Broswers"
for Broswer in "${BroswersArray[@]}"; do

    sudo sed -i "/$Broswer/Id" /usr/local/goadmio/tmp/bot-finder.db

done

Bots=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "SELECT Bots FROM Config")

IFS='|' read -ra BotsArray <<<"$Bots"
for Bot in "${BotsArray[@]}"; do

    sudo sed -i "/$Bot/Id" /usr/local/goadmio/tmp/bot-finder.db

done

sudo cat $LOG | awk -F'|' '{ print $13 }' | grep -ioE '([a-zA-Z0-9_.-]*(bot|spider|agent|client|crawl|http|index|search|scraper|fetcher|scan|crawler)[a-zA-Z0-9_.-]*)' | sort -u >/usr/local/goadmio/tmp/bot.db
File="/usr/local/goadmio/tmp/bot.db"
while IFS= read Bot; do

    sudo sed -i "/$Bot/Id" /usr/local/goadmio/tmp/bot-finder.db

done <"$File"

sudo sed -i 's/"//g' /usr/local/goadmio/tmp/bot-finder.db
sudo cat /usr/local/goadmio/tmp/bot-finder.db
