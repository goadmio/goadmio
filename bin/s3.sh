#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# dnf -y install s3fs-fuse

while getopts ":b:k:s:e:" opt; do
    case ${opt} in
    b) BucketName=$OPTARG ;;
    k) AccessKeyID=$OPTARG ;;
    s) SecretAccessKey=$OPTARG ;;
    e) EndPoint=$OPTARG ;;
    \?) echo "Usage: s3 [-b] Bucket Name [-k] Access Key ID [-s] Secret Access Key [-e] End Point" ;;
    esac
done

if [ "$BucketName" = "" ] && [ "$AccessKeyID" = "" ] && [ "$SecretAccessKey" = "" ] && [ "$EndPoint" = "" ]; then

    echo "Usage: s3 [-b] Bucket Name [-k] Access Key ID [-s] Secret Access Key [-e] End Point"

    exit 1

fi

if [ "$AccessKeyID" != "" ] && [ "$SecretAccessKey" != "" ]; then

    echo "$AccessKeyID:$SecretAccessKey" | sudo tee /etc/passwd-s3fs >/dev/null
    sudo chmod 600 /etc/passwd-s3fs

fi

if sudo test ! -d /s3 ; then
    sudo mkdir -p /s3

    s3fs $BucketName /s3 -o allow_other -o use_path_request_style -o umask=0000 -o uid=1000 -o gid=1000 -o enable_noobj_cache -o use_cache=/tmp/s3 -o passwd_file=/etc/passwd-s3fs -o url=https://$EndPoint
fi

if [ "$BucketName" != "" ] && [[ "$EndPoint" = *"."* ]]; then

    sudo sed -i "/s3 fuse.s3fs/d" /etc/fstab
    echo "$BucketName /s3 fuse.s3fs _netdev,allow_other,passwd_file=/etc/passwd-s3fs,use_path_request_style,umask=0000,uid=1000,gid=1000,enable_noobj_cache,use_cache=/tmp/s3,url=https://$EndPoint 0 0" | sudo tee -a /etc/fstab >/dev/null

fi
