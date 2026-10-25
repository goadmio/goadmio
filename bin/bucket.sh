#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

ServerIP=$(curl -s -4 checkip.amazonaws.com)

if sudo test -f /usr/local/goadmio/minio/minio.conf ; then

    Username=$(sudo grep -oP 'MINIO_ROOT_USER="\K[^"]+' /usr/local/goadmio/minio/minio.conf)
    Password=$(sudo grep -oP 'MINIO_ROOT_PASSWORD="\K[^"]+' /usr/local/goadmio/minio/minio.conf)
    Domain=$(sudo grep -oP 'MINIO_DOMAIN="\K[^"]+' /usr/local/goadmio/minio/minio.conf)

else

    echo "Please Setup MinIO:"
    echo "https://www.goadmio.com/command.php?Command=minio"
    exit 1

fi

if grep -q ":3333" /usr/local/goadmio/minio/minio.conf; then

    mc alias set myminio http://$ServerIP:3333 $Username $Password

else
    mc alias set myminio https://$Domain $Username $Password
fi

if [ $# -eq 1 ]; then
    # Create new Bucket
    mc mb myminio/$1

    exit 1
fi

if [ "$2" = "public" ]; then
    # Set Bucket Policy to Public
    mc anonymous set public myminio/$1

    exit 1
fi

if [ "$2" = "private" ]; then
    # Set Bucket Policy to Private
    mc anonymous set none myminio/$1

    exit 1
fi

if [ $# -eq 2 ]; then

    if [ ${#1} -gt 10 ] && [ ${#2} -gt 20 ]; then

        mc admin user svcacct add --access-key "$1" --secret-key "$2" myminio $Username

        exit 1

    fi
fi
