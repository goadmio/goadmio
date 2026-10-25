#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

Domain=$1
Password=$2

# npm install -g mudslide
# /root/.local/share/mudslide
# Current User Details
# npx mudslide me
# npx mudslide me -c /whatsapp/201006931666

exit 1

npx mudslide login

# npx mudslide login -c /whatsapp/201006931666

# npx mudslide logout

# Current user details
# npx mudslide me

# convert -size 860x860 xc:white -font "FreeMono.ttf" -pointsize 8 -fill black -annotate +15-15 "@u.txt" u.png

exit 1

npx mudslide send 201006931666 'Test'
npx mudslide send 201006931666 'Test' -c /whatsapp/201006931666
npx mudslide send 201284996284 'Test'
npx mudslide send-image 201006931666 logo.png
npx mudslide send-image --caption 'Your text here www.mls.eg' 201006931666 image.png
npx mudslide send-file me test.json
npx mudslide send-file --type audio 123456789-987654321@g.us music.mp3
npx mudslide send-location me 48.858222 2.2945

# List Groups
npx mudslide groups
npx mudslide send 123456789-987654321@g.us 'hello world'

# /root/.local/share/mudslide
