#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if sudo test -d "/home/$Domain" ; then

    sudo mkdir -p /home/$Domain/log/include

    sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/site.db "
	SELECT IFNULL(Username,'') || '|' || IFNULL(DocumentRoot,'') || '|' || IFNULL(FullName,'') || '|' || IFNULL(Mobile,'') || '|' || IFNULL(Email,'') || '|' || IFNULL(PackageID,'') || '|' || IFNULL(DiskSpace,'') || '|' || IFNULL(Bandwidth,'') || '|' || IFNULL(Inode,'') || '|' || IFNULL(FTPNo,'') || '|' || IFNULL(EmailNo,'') || '|' || IFNULL(DatabaseNo,'') || '|' || IFNULL(SubDomainNo,'') || '|' || IFNULL(AliasNo,'') || '|' || IFNULL(AddonNo,'') || '|' || IFNULL(Shell,'') || '|' || IFNULL(JailedShell,'') || '|' || IFNULL(Timezone,'') || '|' || IFNULL(Permission,'') || '|' || IFNULL(Description,'') || '|' || IFNULL(PHPVersion,'') || '|' || IFNULL(SMTPHost,'') || '|' || IFNULL(SMTPUser,'') || '|' || IFNULL(SMTPPass,'') || '|' || IFNULL(SMTPPort,'') || '|' || IFNULL(SSLCertificate,'') || '|' || IFNULL(SSLRedirect,'') || '|' || IFNULL(Bot,'') || '|' || IFNULL(Proxy,'') || '|' || IFNULL(FTPStatus,'') || '|' || IFNULL(FTPUpload,'') || '|' || IFNULL(FTPDownload,'') || '|' || IFNULL(FTPDelete,'') || '|' || IFNULL(Backup,'') || '|' || IFNULL(BackupStamp,'') || '|' || IFNULL(ExpiresOn,'') || '|' || IFNULL(DomainExpiresOn,'') || '|' || IFNULL(MailTTL,'') || '|' || IFNULL(BrowserCacheTTL,'') || '|' || IFNULL(APIIgnore,'0') || '|' || IFNULL(UserID,'0') || '|' || IFNULL(Owner,'') || '|' || IFNULL(TimeStamp,'')
	FROM Site
	WHERE Domain='$Domain'
	" | while IFS='|' read -r Username DocumentRoot FullName Mobile Email PackageID DiskSpace Bandwidth Inode FTPNo EmailNo DatabaseNo SubDomainNo AliasNo AddonNo Shell JailedShell Timezone Permission Description PHPVersion SMTPHost SMTPUser SMTPPass SMTPPort SSLCertificate SSLRedirect Bot Proxy FTPStatus FTPUpload FTPDownload FTPDelete Backup BackupStamp ExpiresOn DomainExpiresOn MailTTL BrowserCacheTTL APIIgnore UserID Owner TimeStamp; do

        echo "Domain=\"$Domain\"" | sudo tee /home/$Domain/log/include/site.conf >/dev/null
        echo "Username=\"$Username\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "DocumentRoot=\"$DocumentRoot\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FullName=\"$FullName\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Mobile=\"$Mobile\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Email=\"$Email\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "PackageID=\"$PackageID\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "DiskSpace=\"$DiskSpace\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Bandwidth=\"$Bandwidth\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Inode=\"$Inode\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FTPNo=\"$FTPNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "EmailNo=\"$EmailNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "DatabaseNo=\"$DatabaseNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SubDomainNo=\"$SubDomainNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "AliasNo=\"$AliasNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "AddonNo=\"$AddonNo\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Shell=\"$Shell\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "JailedShell=\"$JailedShell\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Timezone=\"$Timezone\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Permission=\"$Permission\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Description=\"$Description\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "PHPVersion=\"$PHPVersion\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SMTPHost=\"$SMTPHost\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SMTPUser=\"$SMTPUser\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SMTPPass=\"$SMTPPass\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SMTPPort=\"$SMTPPort\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SSLCertificate=\"$SSLCertificate\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "SSLRedirect=\"$SSLRedirect\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Bot=\"$Bot\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Proxy=\"$Proxy\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FTPStatus=\"$FTPStatus\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FTPUpload=\"$FTPUpload\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FTPDownload=\"$FTPDownload\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "FTPDelete=\"$FTPDelete\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Backup=\"$Backup\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "BackupStamp=\"$BackupStamp\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "ExpiresOn=\"$ExpiresOn\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "DomainExpiresOn=\"$DomainExpiresOn\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "MailTTL=\"$MailTTL\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "BrowserCacheTTL=\"$BrowserCacheTTL\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "APIIgnore=\"$APIIgnore\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "UserID=\"$UserID\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "Owner=\"$Owner\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null
        echo "TimeStamp=\"$TimeStamp\"" | sudo tee -a /home/$Domain/log/include/site.conf >/dev/null

    done

fi
