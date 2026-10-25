#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

MySQLRootPassword=$(sudo grep -oP 'DBPass="\K[^"]+' /usr/local/goadmio/include/config/config.php)

if [[ $(free -m | grep Mem | awk '{ print $2 }') -lt "512" ]]; then

    echo "MariaDB requires at least 0.5 GB of RAM to install."
    exit 1

fi

LockFile="/usr/local/goadmio/lock/backup.lock"
if sudo test -f $LockFile ; then
    if [[ $(($(date +%s) - $(stat -c %Y $LockFile 2>/dev/null))) -le "3600" ]]; then
        InstanceFile=$(<$LockFile)
        echo "Instance ($InstanceFile) already running."
        exit 1
    fi
fi

Cores=$(lscpu -p | grep -v "^#" | cut -d, -f2 | sort -u | wc -l)
Threads=$(echo "$(sudo grep -c processor /proc/cpuinfo)")

if [ "$1" = "system" ]; then
    MY="/var/go/etc/my.cnf"
else
    MY="/etc/my.cnf"
fi

ServerIP=$(curl -s -4 checkip.amazonaws.com)

if sudo test -f /var/lib/sqlite/config.db ; then
    Resource=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select Resource from Config")
fi

# Avoid Using Swappiness in MySQL
sudo sysctl -w vm.swappiness=0 &>/dev/null

# Memory Ram
R=$(sudo grep MemTotal /proc/meminfo | awk '{print $2}')

# CPU Cores
C=$(nproc)
B=$(($C / 2))
T=$(($C * 2))
TableNo=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES")

# Calculate Key Buffer Size (Used)
K=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT SUM(INDEX_LENGTH) 'Index Size' FROM information_schema.TABLES where ENGINE='MyISAM';")

StorageType=$(sudo lsblk -d -o ROTA | tail -n +2 | head -n 1 | awk {'print $1'} | sed 's/0/SSD/' | sed 's/1/HDD/')

if [ "$K" = "" ] || [ "$K" = "NULL" ]; then

    K="50000000"

fi

MUC=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE variable_name='MAX_USED_CONNECTIONS';")
MUCTIME=$(sudo mariadb -uroot -p$MySQLRootPassword -N -e "SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE variable_name='MAX_USED_CONNECTIONS_TIME';")

if [ "$MUC" = "" ]; then

    MUC=151

fi

if [ "$TableNo" = "" ]; then

    TOC="2000"

else

    TOC=$(expr 2000 - $TableNo % 2000 + $TableNo)

    if [ "$TOC" -gt "8000" ]; then
        TOC=8000
    fi

fi

if [ "$MUC" -ge "1000" ]; then

    MaxConnections="2500"

elif [ "$MUC" -ge "500" ]; then

    MaxConnections="1000"

elif [ "$MUC" -ge "250" ]; then

    MaxConnections="500"

elif [ "$MUC" -ge "50" ]; then

    MaxConnections="250"

else

    MaxConnections="151"

fi

if [ "$K" -ge "7000000000" ]; then

    KBS="8G"

elif [ "$K" -ge "6000000000" ]; then

    KBS="7G"

elif [ "$K" -ge "5000000000" ]; then

    KBS="6G"

elif [ "$K" -ge "4000000000" ]; then

    KBS="5G"

elif [ "$K" -ge "3000000000" ]; then

    KBS="4G"

elif [ "$K" -ge "2000000000" ]; then

    KBS="3G"

elif [ "$K" -ge "1000000000" ]; then

    KBS="2G"

elif [ "$K" -ge "500000000" ]; then

    KBS="1G"

elif [ "$K" -ge "300000000" ]; then

    KBS="512M"

elif [ "$K" -ge "100000000" ]; then

    KBS="256M"

elif [ "$K" -ge "50000000" ]; then

    KBS="128M"

else

    KBS="64M"

fi

TimeZone=$(date +%:z)

echo "[mysqld]" | sudo tee "$MY" >/dev/null

if [ "$1" = "system" ]; then

    sudo mkdir -p /var/go/var/lib/mysql
    sudo mkdir -p /var/go/var/run

    sudo chown -R mysql:mysql /var/go/var/lib/mysql
    sudo chmod 750 /var/go/var/lib/mysql

    echo "user = root" | sudo tee -a "$MY" >/dev/null
    echo "port = 3307" | sudo tee -a "$MY" >/dev/null
    echo "datadir = /var/go/var/lib/mysql" | sudo tee -a "$MY" >/dev/null
    echo "socket = /var/go/var/lib/mysql/mysql.sock" | sudo tee -a "$MY" >/dev/null
    echo "pid-file = /var/go/var/run/mysql.pid" | sudo tee -a "$MY" >/dev/null

fi

if [ "$R" -ge "256000000" ]; then

    echo "# RAM: 256 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_buffer_pool_size = 32G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_buffer_pool_size = 64G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_buffer_pool_size = 128G" | sudo tee -a "$MY" >/dev/null
    fi

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_log_file_size = 4G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_log_file_size = 8G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_log_file_size = 16G" | sudo tee -a "$MY" >/dev/null
    fi

    echo "innodb_log_buffer_size = 256M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "128000000" ]; then

    echo "# RAM: 128 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_buffer_pool_size = 16G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_buffer_pool_size = 32G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_buffer_pool_size = 64G" | sudo tee -a "$MY" >/dev/null
    fi

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_log_file_size = 2G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_log_file_size = 4G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_log_file_size = 8G" | sudo tee -a "$MY" >/dev/null
    fi

    echo "innodb_log_buffer_size = 256M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 4G" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "64000000" ]; then

    echo "# RAM: 64 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema = ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_buffer_pool_size = 8G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_buffer_pool_size = 16G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_buffer_pool_size = 32G" | sudo tee -a "$MY" >/dev/null
    fi

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_log_file_size = 1G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_log_file_size = 2G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_log_file_size = 4G" | sudo tee -a "$MY" >/dev/null
    fi

    echo "innodb_log_buffer_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "32000000" ]; then

    echo "# RAM: 32 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_buffer_pool_size = 4G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_buffer_pool_size = 8G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_buffer_pool_size = 16G" | sudo tee -a "$MY" >/dev/null
    fi

    echo "innodb_log_file_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "16000000" ]; then

    echo "# RAM: 16 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null

    if [ "$Resource" = "Starter" ]; then
        echo "innodb_buffer_pool_size = 1G" | sudo tee -a "$MY" >/dev/null
    elif [ "$Resource" = "Standard" ]; then
        echo "innodb_buffer_pool_size = 2G" | sudo tee -a "$MY" >/dev/null
    else
        echo "innodb_buffer_pool_size = 4G" | sudo tee -a "$MY" >/dev/null
    fi

    echo "innodb_log_file_size = 1G" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 1G" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 1G" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 1G" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "8000000" ]; then

    echo "# RAM: 8 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_size = 2G" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_file_size = 512M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 512M" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 512M" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 512M" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "4000000" ]; then

    echo "# RAM: 4 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_size = 1G" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 64M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 256M" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 256M" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 256M" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "2000000" ]; then

    echo "# RAM: 2 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_file_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 32M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 64M" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 64M" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 64M" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

elif [ "$R" -ge "1000000" ]; then

    echo "# RAM: 1 GB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_size = 128M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_file_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 32M" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 32M" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 32M" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "" | sudo tee -a "$MY" >/dev/null

else

    echo "# RAM: 512 MB ($Cores Cores / $Threads Threads)" | sudo tee -a "$MY" >/dev/null
    echo "default-time-zone = '$TimeZone'" | sudo tee -a "$MY" >/dev/null
    echo "ft_min_word_len = 3" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Files" | sudo tee -a "$MY" >/dev/null
    echo "skip-external-locking" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# InnoDB Settings" | sudo tee -a "$MY" >/dev/null
    echo "performance_schema=ON" | sudo tee -a "$MY" >/dev/null
    echo "skip-name-resolve = OFF" | sudo tee -a "$MY" >/dev/null
    echo "skip-innodb-doublewrite" | sudo tee -a "$MY" >/dev/null
    echo "disable-log-bin" | sudo tee -a "$MY" >/dev/null
    echo "innodb_file_per_table = 1" | sudo tee -a "$MY" >/dev/null
    echo "sync_binlog = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_read_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_write_io_threads = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_instances = $C" | sudo tee -a "$MY" >/dev/null
    echo "innodb_open_files = 65535" | sudo tee -a "$MY" >/dev/null
    echo "table_open_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "table_definition_cache = $TOC" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_size = 64M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_file_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_log_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_log_at_trx_commit = 2" | sudo tee -a "$MY" >/dev/null
    echo "innodb_thread_concurrency = 0" | sudo tee -a "$MY" >/dev/null
    echo "innodb_purge_threads = $B" | sudo tee -a "$MY" >/dev/null
    echo "innodb_flush_method = O_DIRECT" | sudo tee -a "$MY" >/dev/null
    echo "innodb_adaptive_hash_index = OFF" | sudo tee -a "$MY" >/dev/null
    echo "innodb_change_buffering = all" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_load_at_startup = 1" | sudo tee -a "$MY" >/dev/null
    echo "innodb_buffer_pool_dump_at_shutdown = 1" | sudo tee -a "$MY" >/dev/null

    if [ "$StorageType" = "SSD" ]; then
        echo "innodb_flush_neighbors = 0" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity = 2000" | sudo tee -a "$MY" >/dev/null
        echo "innodb_io_capacity_max = 4000" | sudo tee -a "$MY" >/dev/null
    fi
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# MyISAM Settings" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_type = 0" | sudo tee -a "$MY" >/dev/null
    echo "query_cache_size = 0" | sudo tee -a "$MY" >/dev/null
    echo "read_buffer_size = 8M" | sudo tee -a "$MY" >/dev/null
    echo "key_buffer_size = $KBS" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

    echo "# Table and TMP Settings" | sudo tee -a "$MY" >/dev/null
    echo "tmp_table_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "max_heap_table_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "bulk_insert_buffer_size = 16M" | sudo tee -a "$MY" >/dev/null
    echo "" | sudo tee -a "$MY" >/dev/null

fi

echo "" | sudo tee -a "$MY" >/dev/null
echo "# Historic Max Used Connections ($MUC) - $MUCTIME" | sudo tee -a "$MY" >/dev/null
echo "max_connections = $MaxConnections" | sudo tee -a "$MY" >/dev/null
echo "" | sudo tee -a "$MY" >/dev/null
echo "sql_mode = \"\"" | sudo tee -a "$MY" >/dev/null
echo "#innodb_strict_mode = 0" | sudo tee -a "$MY" >/dev/null

if [[ $@ = *"--log"* ]]; then

    echo "# Log Slow Queries" | sudo tee -a "$MY" >/dev/null
    echo "log_queries_not_using_indexes = 1" | sudo tee -a "$MY" >/dev/null
    echo "slow_query_log = 1" | sudo tee -a "$MY" >/dev/null
    echo "slow-query_log_file = /var/log/mysql-slow.log" | sudo tee -a "$MY" >/dev/null
    echo "long_query_time = 1" | sudo tee -a "$MY" >/dev/null
    echo "# Log All Queries" | sudo tee -a "$MY" >/dev/null
    echo "log_output = 'FILE'" | sudo tee -a "$MY" >/dev/null
    echo "general_log_file = /var/log/mysql.log" | sudo tee -a "$MY" >/dev/null
    echo "general_log = 1" | sudo tee -a "$MY" >/dev/null

else

    if sudo test -f /var/log/mysql-slow.log ; then

        # Backup mysql-slow.log to Log
        sudo mv /var/log/mysql-slow.log /var/log/go/mysql/mysql-slow-$(date +"%b-%d-%H:%M").log

    fi

    if sudo test -f /var/log/mysql.log ; then

        # Backup mysql.log to Log
        sudo mv /var/log/mysql.log /var/log/go/mysql/mysql-$(date +"%b-%d-%H:%M").log

    fi

    echo "##Log Slow Queries" | sudo tee -a "$MY" >/dev/null
    echo "#log_queries_not_using_indexes = 1" | sudo tee -a "$MY" >/dev/null
    echo "#slow_query_log = 1" | sudo tee -a "$MY" >/dev/null
    echo "#slow-query_log_file = /var/log/mysql-slow.log" | sudo tee -a "$MY" >/dev/null
    echo "#long_query_time = 1" | sudo tee -a "$MY" >/dev/null
    echo "##Log All Queries" | sudo tee -a "$MY" >/dev/null
    echo "#log_output = 'FILE'" | sudo tee -a "$MY" >/dev/null
    echo "#general_log_file = /var/log/mysql.log" | sudo tee -a "$MY" >/dev/null
    echo "#general_log = 1" | sudo tee -a "$MY" >/dev/null

fi

echo "" | sudo tee -a "$MY" >/dev/null
echo "[galera]" | sudo tee -a "$MY" >/dev/null
echo "# !include /etc/galera.cnf" | sudo tee -a "$MY" >/dev/null

if sudo test ! -f /etc/galera.cnf ; then

    echo "wsrep_on=ON" | sudo tee /etc/galera.cnf >/dev/null
    echo "wsrep_cluster_name=\"MariaDB Galera Cluster\"" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "wsrep_cluster_address=\"gcomm://\"" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "binlog_format=row" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "default_storage_engine=InnoDB" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "innodb_autoinc_lock_mode=2" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "bind-address=0.0.0.0" | sudo tee -a /etc/galera.cnf >/dev/null
    echo "wsrep_node_address=\"$ServerIP\"" | sudo tee -a /etc/galera.cnf >/dev/null

fi

# /var/lib/mysql/grastate.dat
# galera_new_cluster
# mariadb -e "SHOW STATUS LIKE 'wsrep_cluster_size%';"

echo "" | sudo tee /var/log/mysql-slow.log >/dev/null
sudo chmod 777 /var/log/mysql-slow.log

echo "" | sudo tee /var/log/mysql.log >/dev/null
sudo chmod 777 /var/log/mysql.log

if [ "$1" != "system" ]; then
    sudo systemctl restart mariadb
fi