#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

sudo dnf -y install php-cgi
sudo dnf install epel-release
sudo dnf update -y && sudo reboot
sudo dnf -y install java-1.8.0-openjdk

cd /root
sudo wget https://script.goadmio.com/php-java-bridge_7.2.1_documentation.zip
sudo unzip php-java-bridge_7.2.1_documentation.zip

java -jar JavaBridge.war

sudo /go/tomcat

sudo cp /root/JavaBridge.war /usr/share/tomcat/webapps/
sudo cp /root/JavaBridge.jar /usr/java/packages/lib/ext/

sudo cp /root/JavaBridge.jar /usr/lib/jvm/jre/JavaBridge.jar

sudo cp -r /usr/share/tomcat/webapps/JavaBridge/ /home/goadmio.com/www
