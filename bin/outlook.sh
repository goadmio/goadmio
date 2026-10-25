#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Email=$1
Domain=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

Hostname=$(</etc/hostname)
HostnameDots=$(sudo grep -o "\." <<<"$Hostname" | wc -l)

if [ "$HostnameDots" -lt "2" ]; then

    echo "OUTLOOK:Invalid Server Hostname, A hostname should consist of a name and a domain name. All valid hostnames should have 2 dots in them."
    exit 1

fi

if sudo test ! -f /etc/imap ; then
    echo "$Hostname" | sudo tee /etc/imap >/dev/null
fi

IMAPHostname=$(</etc/imap)

IFS='.' read -r -a Array <<<"$Hostname"

if [ "${Array[3]}" == "" ]; then

    HDomain="${Array[1]}.${Array[2]}"

else

    HDomain="${Array[1]}.${Array[2]}.${Array[3]}"

fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)
DomainIP=$(dig $HDomain +short)

if [ "$DomainIP" = "$ServerIP" ]; then

    SenderEmail="goadmio@$HDomain"

else

    SenderEmail="goadmio@$Hostname"

fi

FTPMessage=$(echo -e "GoAdmio FTP is the safest and easiest way to securely upload and download files. Enjoy SFTP transfers with the highest levels of encryption, ease of use, customization, and low administrative overhead.\n\nDownload Now:\nhttps://www.goadmio.com/download/Go-FTP.exe")

if sudo test -d "/etc/letsencrypt/live/smtp.$Domain" ; then
    IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: imap.$Domain\nPORT: 993\nEncryption: SSL\n\nOutgoing Mail Server (SMTP):\nHostname: smtp.$Domain\nPORT: 465\nEncryption: SSL\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
elif sudo test -d "/etc/letsencrypt/live/$Hostname" ; then
    IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: $IMAPHostname\nPORT: 993\nEncryption: SSL\n\nOutgoing Mail Server (SMTP):\nHostname: $Hostname\nPORT: 465\nEncryption: SSL\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
else
    IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: imap.$Domain\nPORT: 143\nEncryption: None\n\nOutgoing Mail Server (SMTP):\nHostname: smtp.$Domain\nPORT: 25\nEncryption: None\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
fi

if [ "$Email" = "all" ]; then

    N=0

    if [ "$Domain" = "" ]; then

        C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select count(MailID) from Mail")
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail" | sudo tee /usr/local/goadmio/mail.db >/dev/null

    else

        C=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select count(MailID) from Mail where Domain='$Domain'")
        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/mail.db "select Email from Mail where Domain='$Domain'" | sudo tee /usr/local/goadmio/mail.db >/dev/null

    fi

    File="/usr/local/goadmio/mail.db"
    while IFS= read Email; do

        N=$(($N + 1))

        IFS='@' read -r -a Array <<<"$Email"

        Domain="${Array[1]}"

        if sudo test -d "/etc/letsencrypt/live/smtp.$Domain" ; then
            IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: imap.$Domain\nPORT: 993\nEncryption: SSL\n\nOutgoing Mail Server (SMTP):\nHostname: smtp.$Domain\nPORT: 465\nEncryption: SSL\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
        elif sudo test -d "/etc/letsencrypt/live/$Hostname" ; then
            IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: $IMAPHostname\nPORT: 993\nEncryption: SSL\n\nOutgoing Mail Server (SMTP):\nHostname: $Hostname\nPORT: 465\nEncryption: SSL\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
        else
            IMAPMessage=$(echo -e "Incoming Mail Server (IMAP):\nAccount Type: IMAP\nHostname: imap.$Domain\nPORT: 143\nEncryption: None\n\nOutgoing Mail Server (SMTP):\nHostname: smtp.$Domain\nPORT: 25\nEncryption: None\n\n\nIf you have questions or need help, don't hesitate to get in touch!\nWebsite: www.goadmio.com")
        fi

        echo "$FTPMessage" | mailx -s "Download GoAdmio FTP" -r "GoAdmio<$SenderEmail>" $Email
        echo "$IMAPMessage" | mailx -s "IMAP Configuration ($Email)" -r "GoAdmio<$SenderEmail>" $Email

    done <"$File"

    sudo rm -rf /usr/local/goadmio/mail.db

else

    echo "$FTPMessage" | mailx -s "Download GoAdmio FTP" -r "GoAdmio<$SenderEmail>" $Email
    echo "$IMAPMessage" | mailx -s "IMAP Configuration ($Email)" -r "GoAdmio<$SenderEmail>" $Email

fi
