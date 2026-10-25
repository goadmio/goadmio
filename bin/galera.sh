#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ServerIP=$(curl -s -4 checkip.amazonaws.com)

if [[ $# -eq 0 ]] || [ "$1" = "start" ]; then

    if grep -q "gcomm://$ServerIP" /etc/my.cnf; then

        if [[ $@ = *"--force"* ]]; then

            sudo sed -i "s/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g" /var/lib/mysql/grastate.dat

        fi

        echo "Starting the Cluster..."

        galera_new_cluster

    else

        echo "Invalid Node."

    fi

fi

if [ "$1" = "size" ]; then

    sudo mariadb -e "SHOW STATUS LIKE 'wsrep_cluster_size%';"

fi
