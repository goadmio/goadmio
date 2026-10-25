#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Answer=$1

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

echo "Choose an option below or ask me a short, simple question and I'll find an answer for you."
echo ""
echo "If you’re unable to get the answer you need, I’ll help you get in touch with our customer support team support@goadmio.com."
echo ""
echo "How can I help you today?"

if [ "$WS" = "NGINX" ]; then
    echo " 1- I can't restart NGINX."
    echo " 2- I can't reinstall NGINX."
else
    echo " 1- I can't restart Apache."
    echo " 2- I can't reinstall Apache."
fi

echo " 3- I can't access the control panel."
echo " 4- I can't update control panel."

echo " 6- Roundcube webmail not sending emails."
echo " 7- Rainloop webmail not sending emails."
echo " 8- Horde webmail not sending emails."
echo " 9- I can't set time, date & time zone."
echo "10- I can't install an SSL certificate on my domain."
echo "11- I can't renew SSL certificate for my domain."
echo "12- I deleted \"/usr/local/goadmio\" folder by mistake."
echo "13- I deleted \"goadmio\" database by mistake."
echo "14- I can't fix files and folders permissions."
echo "15- I can't switch from Apache to Nginx."
echo "16- I can't switch from Nginx to Apache."
echo "17- I can't install XRDP."

if [ $# -eq 0 ]; then

    read -p "Answer: " -e Answer

else

    Answer=$(echo "$Answer" | tr '[:upper:]' '[:lower:]')

fi

if [ "$Answer" = "1" ] || [ "$Answer" = "nginx" ] || [ "$Answer" = "apache" ] || [ "$Answer" = "httpd" ]; then

    sudo /go/conf

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "2" ] || [ "$Answer" = "reinstallnginx" ] || [ "$Answer" = "reinstallapache" ] || [ "$Answer" = "reinstallhttpd" ]; then

    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    Status=$(sudo wget "http://$ServerIP:2020/status.txt" -q -O -)

    if [ "$Status" = "1" ]; then

        if [ "$WS" = "NGINX" ]; then
            echo "NGINX is already installed and running."
        else
            echo "Apache is already installed and running."
        fi

    else

        sudo /go/conf

    fi

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "3" ]; then

    ServerIP=$(curl -s -4 checkip.amazonaws.com)
    Status=$(sudo wget "http://$ServerIP:2020/status.txt" -q -O -)

    if [ "$Status" = "1" ]; then

        sudo /go/session

        echo "Accessing your account GoAdmio is done easily through your browser. All you need to do is type:"
        echo "http://$ServerIP:2020"

        echo ""
        echo "Please try now."

    else

        sudo /go/session
        sudo /go/installphp 8.2
        sudo /go/conf

        echo ""
        echo "Please try now."

    fi

fi

if [ "$Answer" = "4" ]; then

    echo "Please wait..."
    sudo curl -s -o latest -L https://download.goadmio.com && chmod +x latest && ./latest update
    sudo /go/update

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "5" ]; then

    # /go/horde

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "6" ]; then

    sudo /go/checkmail
    sudo /go/roundcube
    sudo /go/installmail

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "7" ]; then

    sudo /go/checkmail
    sudo /go/snappymail
    sudo /go/installmail

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "8" ]; then

    sudo /go/checkmail
    sudo /go/installmail

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "9" ]; then

    sudo /go/timezone

fi

if [ "$Answer" = "10" ]; then

    sudo /go/conf

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "11" ]; then

    sudo /go/checkssl

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "12" ]; then

    sudo /go/update

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "13" ]; then

    sudo /go/restore database

fi

if [ "$Answer" = "14" ]; then

    echo "Please wait..."
    sudo /go/fix

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "15" ]; then

    echo "Please wait..."
    sudo /go/nginx

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "16" ]; then

    echo "Please wait..."
    sudo /go/apache

    echo ""
    echo "Please try now."

fi

if [ "$Answer" = "17" ]; then

    echo "Please wait..."
    sudo /go/xrdp

    echo ""
    echo "Please try now."

fi
