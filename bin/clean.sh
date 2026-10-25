#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/clean "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

if [[ "$@" = *"--force"* ]]; then

    sudo find /home/*/ -maxdepth 1 -type f -name "*.tar.gz" -delete
    sudo find /home/*/ -maxdepth 1 -type d -name "*-backup-*" -exec rm -rf {} +

else

    sudo find /home/*/ -maxdepth 1 -type f -name "*.tar.gz" -mtime +14 -delete
    sudo find /home/*/ -maxdepth 1 -type d -name "*-backup-*" -mtime +14 -exec rm -rf {} +

fi

sudo find /var/lib/sqlite/backup -mtime +14 -print0 | xargs -0 rm -rf
sudo find /home -type f -name "*.save.?" -delete

sudo find /var/lib/*/session -type f -mtime +3 -print0 | xargs -0 rm -f
sudo rm -rf /home/*/mail/*/.Trash/*
sudo rm -rf /home/*/.trash/*

sudo rm -rf /var/go/var/lib/mysql

sudo /go/reload "| Executed by $(basename "$0")"

sudo rm -rf /usr/local/goadmio/tmp/*
sudo rm -rf /var/lib/sqlite/httplog.db
sudo rm -rf /var/lib/sqlite/ddos.db
sudo /go/database
sudo chown -R go:go /var/lib/sqlite

cd /home
for Domain in *; do

    if sudo test -d /home/$Domain/www  && sudo test -d /home/$Domain/mail ; then

        MailTTL=$(sudo sqlite3 -batch /var/lib/sqlite/site.db "SELECT IFNULL(MailTTL, 0) FROM Site WHERE Domain='$Domain';")
        MailTTL=${MailTTL:-0}

        if [ "$MailTTL" -ge "1" ]; then

            sudo find /home/$Domain/mail -type f -mtime +$MailTTL -print0 | xargs -0 rm -f

        fi

    fi

done
