#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Hostname=$(</etc/hostname)
ServerIP=$(curl -s -4 checkip.amazonaws.com)

Dots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)
if [ "$Dots" -lt "2" ]; then

    echo "Invalid Hostname ($Hostname), A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."

    sudo /go/sendmail "SMTP Server is not working (Server IP: $ServerIP)" "Invalid Hostname ($Hostname), A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them." "SMTP"
    sudo /go/sendwhatsapp "*SMTP Server is not working (Server IP: $ServerIP)*\n\nInvalid Hostname ($Hostname), A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them." "SMTP"

    exit 1

fi

if [ "$ServerIP" = "" ]; then

    exit 1

else

    IP=$(dig $Hostname +short | tail -n1)
    if [ "$IP" != "$ServerIP" ]; then

        echo "Please Point $Hostname to A Record: $ServerIP"
        sudo /go/sendmail "SMTP Server is not working ($Hostname)" "Please Point $Hostname to A Record: $ServerIP" "SMTP"
        sudo /go/sendwhatsapp "*SMTP Server is not working ($Hostname)*\n\nPlease Point $Hostname to A Record: $ServerIP" "SMTP"

        exit 1

    fi

fi

SMTPNo=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/smtp.db "select count(*) from SMTP")

if [ "$SMTPNo" -ge 1 ]; then
    exit 1
fi

SMTPUser=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail WHERE SentToday>=1 ORDER BY SentToday DESC LIMIT 1")
SMTPPass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Pass from Mail WHERE Email='$SMTPUser'")

if [[ "$SMTPUser" = *"@"* ]]; then

    Code=$(printf "From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\nThis is the email body content.\r\n" \
        "$SMTPUser" "gbp.uae@gmail.com" "Test" |
        sudo /usr/bin/curl -v --max-time 5 --connect-timeout 5 \
            --url "smtp://$ServerIP:587" \
            --user "$SMTPUser:$SMTPPass" \
            --mail-from "$SMTPUser" \
            --mail-rcpt "gbp.uae@gmail.com" \
            -T - 2>&1)

    if [[ "$Code" = *"250"* ]] || [[ "$Code" = *"252"* ]] || [[ "$Code" = *"235"* ]]; then

        Send=1
        exit 1

    else

        sudo /go/postconf
        sudo /go/vmail

    fi

    echo "SMTP failed. Our system is trying to fix it automatically."

    Code=$(printf "From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\nThis is the email body content.\r\n" \
        "$SMTPUser" "gbp.uae@gmail.com" "Test" |
        sudo /usr/bin/curl -v --max-time 5 --connect-timeout 5 \
            --url "smtp://$ServerIP:587" \
            --user "$SMTPUser:$SMTPPass" \
            --mail-from "$SMTPUser" \
            --mail-rcpt "gbp.uae@gmail.com" \
            -T - 2>&1)

    if [[ "$Code" = *"250"* ]] || [[ "$Code" = *"252"* ]] || [[ "$Code" = *"235"* ]]; then

        echo "SMTP error was automatically corrected."
        Send=1
        exit 1

    else

        sudo /go/installmail

    fi

    Code=$(printf "From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\nThis is the email body content.\r\n" \
        "$SMTPUser" "gbp.uae@gmail.com" "Test" |
        sudo /usr/bin/curl -v --max-time 5 --connect-timeout 5 \
            --url "smtp://$ServerIP:587" \
            --user "$SMTPUser:$SMTPPass" \
            --mail-from "$SMTPUser" \
            --mail-rcpt "gbp.uae@gmail.com" \
            -T - 2>&1)

    if [[ "$Code" = *"250"* ]] || [[ "$Code" = *"252"* ]] || [[ "$Code" = *"235"* ]]; then

        Send=1
        exit 1

    else

        echo "CHECKSMTP: SMTP Server $Hostname is not working."

        sudo /go/sendmail "SMTP Failed" "SMTP Server is not working" "SMTP"
        sudo /go/sendwhatsapp "*SMTP Server is not working*" "SMTP"

    fi

fi

sudo /go/vmail
