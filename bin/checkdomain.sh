#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

String=$1
String=$(echo "${String%%.*}")

whois "$String.com" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.com"
    exit 1
fi

whois "$String.net" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.net"
    exit 1
fi

whois "$String.org" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.org"
    exit 1
fi

whois "$String.info" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.info"
    exit 1
fi

whois "$String.biz" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.biz"
    exit 1
fi

whois "$String.co" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.co"
    exit 1
fi

whois "$String.me" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
if [ $? -eq 0 ]; then
    echo "$String.me"
    exit 1
fi
