#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

rm -rf /goadmio
mkdir -p /goadmio/home

cf /usr/local/goadmio /goadmio
rm -rf /goadmio/bin/*
cp /root/*.sh /goadmio/bin
find /goadmio -maxdepth 1 -type f -delete
rm -rf /goadmio/bin/encoder.sh
rm -rf /goadmio/bin/decoder.sh

cp /usr/local/goadmio/bin/README.md /goadmio/
cp /usr/local/goadmio/bin/LICENSE.md /goadmio/

cd /goadmio
rm -rf cache
rm -rf includes
rm -rf db
rm -rf tmp
rm -rf backup  
rm -rf latest
rm -rf lock
rm -rf shell
rm -rf sqlite
rm -rf include  
rm -rf linux
rm -rf script
rm -rf template
rm -rf install
rm -rf vps


git config --global --add safe.directory /goadmio
git config --global user.name "goadmio"
git config --global user.email "info@goadmio.com"
git init
git add .
git status

git commit -m "Initial commit"

git branch -M main
git remote add origin https://github.com/goadmio/goadmio.git
# git push -u origin main
git push -f origin main

# 1- Log in to GitHub, click avatar → Settings → Developer settings → Personal access tokens → Tokens (classic).
# 2- Click Generate new token (classic).
# 3- Check the repo permission (complete read/write access to repositories).
# 4- Push Again and Use Token as Password