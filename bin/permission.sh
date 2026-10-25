#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

AccountExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain' and Trash=0")

if [[ ! "$AccountExists" = "$Domain" ]]; then
    echo "Account $Domain not exists"
    exit 1
fi

if [ "$Action" = "EnableFTP" ]; then
    sudo sed -i "/^$Domain/d" /etc/vsftpd/user_list
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPStatus=1 where Domain='$Domain'"
    echo "$Domain: FTP is currently enabled."
fi

if [ "$Action" = "DisableFTP" ]; then
    echo "$Domain" | sudo tee -a /etc/vsftpd/user_list >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPStatus=0 where Domain='$Domain'"
    echo "$Domain: FTP is currently disabled."
fi

if [ "$Action" = "EnableUpload" ]; then
    sudo sed -i "/^write_enable/d" /etc/vsftpd/permission/$Domain
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPUpload=1 where Domain='$Domain'"
    echo "$Domain: FTP upload is currently enabled."
fi

if [ "$Action" = "DisableUpload" ]; then
    echo "write_enable=NO" | sudo tee -a /etc/vsftpd/permission/$Domain >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPUpload=0 where Domain='$Domain'"
    echo "$Domain: FTP upload is currently disabled."
fi

if [ "$Action" = "EnableDownload" ]; then
    sudo sed -i "/^download_enable/d" /etc/vsftpd/permission/$Domain
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPDownload=1 where Domain='$Domain'"
    echo "$Domain: FTP download is currently enabled."
fi

if [ "$Action" = "DisableDownload" ]; then
    echo "download_enable=NO" | sudo tee -a /etc/vsftpd/permission/$Domain >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPDownload=0 where Domain='$Domain'"

    echo "$Domain: FTP download is currently disabled."
fi

if [ "$Action" = "EnableDelete" ]; then
    sudo sed -i "/^cmds_denied/d" /etc/vsftpd/permission/$Domain
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPDelete=1 where Domain='$Domain'"
    echo "$Domain: FTP delete is currently enabled."
fi

if [ "$Action" = "DisableDelete" ]; then
    echo "cmds_denied=DELE,RMD" | sudo tee -a /etc/vsftpd/permission/$Domain >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET FTPDelete=0 where Domain='$Domain'"

    echo "$Domain: FTP delete is currently disabled."
fi

sudo systemctl restart vsftpd
