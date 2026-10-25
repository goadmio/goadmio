#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [ -z "$STY" ]; then exec screen -dm -S FFMPEG /bin/bash "$0"; fi

sudo yum -y update
sudo yum remove ImageMagick
sudo yum -y install tcl-devel libpng-devel libjpeg-devel ghostscript-devel bzip2-devel freetype-devel libtiff-devel
sudo mkdir /root/imagemagick
cd /root/imagemagick
sudo wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
sudo tar xzvf ImageMagick.tar.gz
cd ImageMagick-*
./configure --prefix=/usr/ --with-bzlib=yes --with-fontconfig=yes --with-freetype=yes --with-gslib=yes --with-gvc=yes --with-jpeg=yes --with-jp2=yes --with-png=yes --with-tiff=yes
sudo make
sudo make install

sudo yum install epel-release -y && yum update -y

rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

sudo yum install ffmpeg ffmpeg-devel -y
