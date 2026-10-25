#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

cd /usr/local/goadmio
git config --global --add safe.directory /usr/local/goadmio
git config --global user.name "goadmio"
git config --global user.email "info@goadmio.com"
git init
git add .
git status

git commit -m "Initial commit"

git branch -M main
git remote add origin https://github.com/goadmio/goadmio.git
git push -u origin main

# 1- Log in to GitHub, click avatar → Settings → Developer settings → Personal access tokens → Tokens (classic).
# 2- Click Generate new token (classic).
# 3- Check the repo permission (complete read/write access to repositories).
# 4- Push Again and Use Token as Password