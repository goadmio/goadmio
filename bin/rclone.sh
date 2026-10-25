#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo rm -f /var/lib/sqlite/rclone.db
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "CREATE TABLE IF NOT EXISTS Rclone (RcloneID INTEGER PRIMARY KEY,Destination TEXT DEFAULT '' UNIQUE,Name TEXT DEFAULT '')"

Destination="idrive"
Name="IDrive (Cloud Backup)"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="ftp"
Name="FTP"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="sftp"
Name="SSH/SFTP"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="s3"
Name="S3"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="ulozto"
Name="Uloz.to"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="webdav"
Name="WebDAV"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="mega"
Name="Mega"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="drime"
Name="Drime"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="pikpak"
Name="PikPak"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="fichier"
Name="1Fichier"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="gofile"
Name="Gofile"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="internxt"
Name="Internxt Drive"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="linkbox"
Name="Linkbox"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="mailru"
Name="Mail.ru Cloud"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="azureblob"
Name="Microsoft Azure Blob Storage"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="azurefiles"
Name="Microsoft Azure Files"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="opendrive"
Name="OpenDrive"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"

Destination="protondrive"
Name="Proton Drive"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/rclone.db "INSERT OR IGNORE INTO Rclone (Destination,Name) VALUES ('$Destination','$Name')"
