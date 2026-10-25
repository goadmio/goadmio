#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

sudo yum -y install tomcat
sudo systemctl enable tomcat
sudo systemctl restart tomcat
sudo yum -y install tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc
