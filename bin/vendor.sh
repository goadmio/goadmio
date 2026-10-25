#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

echo "Installing VENDORS..."

sudo mkdir -p /usr/local/goadmio/includes
sudo mkdir -p /usr/local/goadmio/.composer
sudo chmod 777 -R /usr/local/goadmio/includes
sudo chmod 777 -R /usr/local/goadmio/.composer

cd /usr/local/goadmio/includes

if [ $# -eq 0 ]; then

    sudo rm -rf /usr/local/goadmio/includes/*

    sudo -u go composer require -n laravel/framework
    sudo -u go composer require -n firebase/php-jwt
    sudo -u go composer require -n guzzlehttp/guzzle
    sudo -u go composer require -n google/apiclient
    sudo -u go composer require -n phpmailer/phpmailer
    sudo -u go composer require -n sonata-project/google-authenticator
    sudo -u go composer require -n giggsey/libphonenumber-for-php
    sudo -u go composer require -n bluerhinos/phpmqtt
    sudo -u go composer require -n twilio/sdk
    sudo -u go composer require -n googleads/google-ads-php
    sudo -u go composer require -n aws/aws-sdk-php

else

    sudo -u go composer require -n $@

fi

sudo chmod 555 -R /usr/local/goadmio/includes
