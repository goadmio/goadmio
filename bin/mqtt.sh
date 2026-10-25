#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo firewall-cmd --zone=public --add-port=1883/tcp --permanent
sudo firewall-cmd --reload

sudo dnf -y install mosquitto
sudo systemctl enable mosquitto
sudo systemctl restart mosquitto

if sudo test ! -f /etc/mosquitto/mosquitto.bak ; then
    sudo mv /etc/mosquitto/mosquitto.conf /etc/mosquitto/mosquitto.bak
fi

echo "listener 1883 0.0.0.0" | sudo tee /etc/mosquitto/mosquitto.conf >/dev/null
echo "allow_anonymous true" | sudo tee -a /etc/mosquitto/mosquitto.conf >/dev/null

# mosquitto_pub -h localhost -t "test/topic" -m "Hello MQTT"
# mosquitto_sub -h localhost -t "test/topic"
