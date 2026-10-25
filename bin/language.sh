#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/language "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

cd /home/download.goadmio.com/www/home/go/language
for File in *; do

    if sudo test -f "/home/download.goadmio.com/www/home/go/language/feedback/$File" ; then

        OPEN="/home/download.goadmio.com/www/home/go/language/feedback/$File"
        while IFS= read Lang; do

            if [[ "$Lang" = *"="* ]]; then

                IFS='=' read -r -a LangArray <<<"$Lang"
                Variable="${LangArray[0]}"

                FindWhat=${Variable/\$/\\$}
                FindWhat=${FindWhat/\[/\\[}
                FindWhat=${FindWhat/\]/\\]}

                echo "Replacing $Variable -> $Lang"
                sudo sed -i "s/$FindWhat.*\";/$Lang/g" /home/download.goadmio.com/www/home/go/language/$File

            fi

        done <"$OPEN"

    fi

done
