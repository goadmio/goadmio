#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Directory=$2
User=$3
Pass=$4
Action=$5

Pass=$(echo "${Pass//\[DollarSign\]/$}")
Pass=$(echo "${Pass//\[AndSign\]/&}")
Pass=$(echo "${Pass//\[EqualSign\]/=}")
Pass=$(echo "${Pass//\[HashSign\]/#}")

OS=$(</usr/local/goadmio/linux/os.db)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ "$Action" = "EnableUpload" ]; then
    sudo sed -i "/^write_enable/d" /etc/vsftpd/permission/$User
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPUpload=1 where User='$User'"
    echo "$User: FTP upload is currently enabled."
    exit 1
fi

if [ "$Action" = "DisableUpload" ]; then
    echo "write_enable=NO" | sudo tee -a /etc/vsftpd/permission/$User >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPUpload=0 where User='$User'"
    echo "$User: FTP upload is currently disabled."
    exit 1
fi

if [ "$Action" = "EnableDownload" ]; then
    sudo sed -i "/^download_enable/d" /etc/vsftpd/permission/$User
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPDownload=1 where User='$User'"
    echo "$User: FTP download is currently enabled."
    exit 1
fi

if [ "$Action" = "DisableDownload" ]; then
    echo "download_enable=NO" | sudo tee -a /etc/vsftpd/permission/$User >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPDownload=0 where User='$User'"

    echo "$User: FTP download is currently disabled."
    exit 1
fi

if [ "$Action" = "EnableDelete" ]; then
    sudo sed -i "/^cmds_denied/d" /etc/vsftpd/permission/$User
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPDelete=1 where User='$User'"
    echo "$User: FTP delete is currently enabled."
    exit 1
fi

if [ "$Action" = "DisableDelete" ]; then
    echo "cmds_denied=DELE,RMD" | sudo tee -a /etc/vsftpd/permission/$Username >/dev/null
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "UPDATE Ftp SET FTPDelete=0 where User='$User'"

    echo "$User: FTP delete is currently disabled."
fi

if [ "$Action" = "delete" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "delete from Ftp where Username='$Username' and User='$User'"

    sudo userdel $User
    sudo rm -rf /etc/vsftpd/permission/$User
    echo "FTP Account $User has been deleted."

elif [ "$Action" = "edit" ]; then

    Exists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "select User from Ftp where Username='$Username' and User='$User'")

    if [ "$Exists" = "$User" ]; then

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

            echo "$Pass" | passwd "$User" --stdin

        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

            Pass=$(sudo openssl passwd $Pass)
            usermod -p $Pass $User

        fi

        echo "Password has been changed."

    else

        echo "Username $User not exists."

    fi

else

    UserID=$(id -u $User)

    if [ "$UserID" -ge "0" ]; then

        echo "$User already exists."
        exit 1

    fi

    if [[ "$Directory" = /home/$Domain/* ]]; then

        sudo mkdir -p $Directory

    else

        echo "Invalid directory path."
        exit 1

    fi

    if sudo test -d "$Directory" ; then

        Exists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "select Username from Ftp where User='$User'")

        if [ "$Exists" = "$User" ]; then
            echo "Username $User already exists."
            exit 1
        fi

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/ftp.db "INSERT INTO Ftp (Domain,Username,Directory,User,Pass) VALUES ('$Domain','$Username','$Directory','$User','$Pass')"

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

            adduser $User -d $Directory
            echo "$Pass" | passwd "$User" --stdin
            sudo chown -R $Username:$Username /home/$Domain
            usermod -d "$Directory" $User

        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

            adduser --disabled-password --force-badname --gecos "" $User &>/dev/null
            usermod -d $Directory -m $User

            EnctypePass=$(sudo openssl passwd $Pass)
            usermod -p $EnctypePass $User

        fi

        sudo chmod 775 "$Directory"

        echo ""
        echo "Account $User Created."
        echo ""
        echo "-----------FTP Account Info----------"
        echo "Host: $Domain"
        echo "Username: $User"
        echo "Password: $Pass"

        sudo systemctl restart vsftpd

    else

        echo "$Directory not exists."

    fi

fi
