#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)

ProgressBar "Installing VSFTPD"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    sudo dnf -y remove ftp &>/dev/null
    sudo dnf -y remove vsftpd &>/dev/null

    sudo dnf -y install ftp
    sudo dnf -y install vsftpd

    VSFTPD="/etc/vsftpd/vsftpd.conf"

elif [ "$OS" = "Debian" ]; then

    sudo apt -y purge ftp &>/dev/null
    sudo apt -y purge vsftpd &>/dev/null

    sudo apt -y install ftp
    sudo apt -y install vsftpd

    VSFTPD="/etc/vsftpd.conf"

elif [ "$OS" = "Ubuntu" ]; then

    DEBIAN_FRONTEND='noninteractive' apt -y purge ftp &>/dev/null
    DEBIAN_FRONTEND='noninteractive' apt -y purge vsftpd &>/dev/null

    DEBIAN_FRONTEND='noninteractive' apt -y install ftp
    DEBIAN_FRONTEND='noninteractive' apt -y install vsftpd

    VSFTPD="/etc/vsftpd.conf"

else
    echo "Unknown operating system."
    exit
fi

# Remove line contains
sudo sed -i "/chroot_local_user/d" $VSFTPD
sudo sed -i "/write_enable/d" $VSFTPD
sudo sed -i "/local_umask/d" $VSFTPD

echo "chroot_local_user=YES" >>$VSFTPD
echo "allow_writeable_chroot=YES" >>$VSFTPD
echo "write_enable=YES" >>$VSFTPD
echo "local_umask=022" >>$VSFTPD
echo "user_config_dir=/etc/vsftpd/permission" >>$VSFTPD
echo "xferlog_std_format=YES" >>$VSFTPD
echo "xferlog_file=/var/log/xferlog" >>$VSFTPD

# Passive FTP
echo "pasv_enable=YES" >>$VSFTPD
echo "pasv_min_port=30000" >>$VSFTPD
echo "pasv_max_port=31000" >>$VSFTPD

# Max connections per client IP (0=Unlimited)
echo "max_per_ip=0" >>$VSFTPD

# Show Hidden Files
echo "force_dot_files=YES" >>$VSFTPD

echo "" >>$VSFTPD

echo "# Log" >>$VSFTPD
echo "xferlog_enable=YES" >>$VSFTPD
echo "xferlog_std_format=YES" >>$VSFTPD
echo "log_ftp_protocol=YES" >>$VSFTPD
echo "xferlog_file=/var/log/vsftpd.log" >>$VSFTPD

sudo touch /var/log/vsftpd.log
sudo chown root:root /var/log/vsftpd.log
sudo chmod 600 /var/log/vsftpd.log

# You can change FTP Permission Per User On This Folder (file name must same username)
sudo mkdir -p /etc/vsftpd/permission

sudo systemctl enable vsftpd
sudo systemctl restart vsftpd
