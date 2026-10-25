#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/9/mssql-server-2022.repo
sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/9/prod.repo
sudo dnf -y install mssql-server
sudo dnf -y install mssql-tools
sudo dnf -y install unixODBC-devel
sudo systemctl enable mssql-server
sudo systemctl restart mssql-server
/opt/mssql/bin/mssql-conf setup
# 1

echo 'export PATH=$PATH:/opt/mssql/bin:/opt/mssql-tools/bin' | sudo tee /etc/profile.d/mssql.sh >/dev/null
source /etc/profile.d/mssql.sh
sqlcmd -S localhost -U sa -P 'tiger'

# CREATE DATABASE MyAppDB;
# GO
# use MyAppDB;
# GO
# CREATE LOGIN app_user WITH PASSWORD = 'tiger';
# GO
# CREATE USER app_user FOR LOGIN app_user;
# GO
# EXEC sp_addrolemember 'db_owner', 'app_user';
# GO
# SELECT name FROM sys.databases;
# GO
# exit

Allow SQL Server to Listen for External Connections
/opt/mssql/bin/mssql-conf set network.ipaddress 0.0.0.0
/opt/mssql/bin/mssql-conf set network.tcpport 1433
sudo systemctl restart mssql-server

sudo firewall-cmd --permanent --add-port=1433/tcp
sudo firewall-cmd --reload

# Test Conrection from another server
sqlcmd -S 185.205.209.208,1433 -U app_user -P 'tiger'
sqlcmd -S erp.goadmio.com,1433 -U erp -P 'tiger'

# https://www.nocix.net/cart/?id=392

https://www.microsoft.com/en-eg/d/sql-server-2025-standard-edition/dg7gmgf0vnjs

sqlcmd -S 185.205.209.208,1433 -U app_user -P 'tiger' -Q "SELECT SERVERPROPERTY('Edition') AS Edition, SERVERPROPERTY('LicenseType') AS LicenseType, SERVERPROPERTY('ProductVersion') AS ProductVersion;"
sqlcmd -S 185.205.209.208,1433 -U app_user -P 'tiger' -Q "SELECT SERVERPROPERTY('Edition') AS Edition;"
