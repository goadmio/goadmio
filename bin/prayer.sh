#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

for City in Cairo Minya; do

    echo "$City"

    Time=$(curl -s -L -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" "https://api.aladhan.com/v1/timingsByCity?city=$City&country=EG&method=5")

    Fajr=$(echo $Time | jq -r '.data.timings.Fajr')
    Sunrise=$(echo $Time | jq -r '.data.timings.Sunrise')
    Dhuhr=$(echo $Time | jq -r '.data.timings.Dhuhr')
    Asr=$(echo $Time | jq -r '.data.timings.Asr')
    Maghrib=$(echo $Time | jq -r '.data.timings.Maghrib')
    Isha=$(echo $Time | jq -r '.data.timings.Isha')

    echo "Fajr: $Fajr"
    echo "Sunrise: $Sunrise"
    echo "Dhuhr: $Dhuhr"
    echo "Asr: $Asr"
    echo "Maghrib: $Maghrib"
    echo "Isha: $Isha"

    echo "/go/sendwhatsapp \"Fajr: $Fajr ($City)\" \"Prayer Times\"" | at $Fajr 2>/dev/null
    echo "/go/sendwhatsapp \"Dhuhr: $Dhuhr ($City)\" \"Prayer Times\"" | at $Dhuhr 2>/dev/null
    echo "/go/sendwhatsapp \"Asr: $Asr ($City)\" \"Prayer Times\"" | at $Asr 2>/dev/null
    echo "/go/sendwhatsapp \"Maghrib: $Maghrib ($City)\" \"Prayer Times\"" | at $Maghrib 2>/dev/null
    echo "/go/sendwhatsapp \"Isha: $Isha ($City)\" \"Prayer Times\"" | at $Isha 2>/dev/null

    # at 4pm -f script.sh

done
