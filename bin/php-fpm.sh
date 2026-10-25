#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain="$1"
Action="$2"

OS=$(</usr/local/goadmio/linux/os.db)
WS=$(</usr/local/goadmio/linux/ws.db)

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")
PHPVersion=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select PHPVersion from Site where Domain='$Domain'")
OpenBasedir=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select OpenBasedir from Site where Domain='$Domain'")
DisableFunctions=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select DisableFunctions from Site where Domain='$Domain'")
CacheActive=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select CacheActive from Site where Domain='$Domain'")

Resource=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select Resource from Config")

if [ "$DisableFunctions" = "" ]; then
    DisableFunctions="exec,mail,passthru,pcntl_exec,popen,proc_close,proc_get_status,proc_open,proc_terminate,shell_exec,system"
fi

if [ "$Resource" = "Starter" ]; then

    PMMaxChildren="10"
    PMStartServers="2"
    PMMinSpareServers="1"
    PMMaxSpareServers="5"
    PMMaxRequests="500"

elif [ "$Resource" = "Standard" ]; then

    PMMaxChildren="20"
    PMStartServers="3"
    PMMinSpareServers="2"
    PMMaxSpareServers="8"
    PMMaxRequests="500"

else

    PMMaxChildren="50"
    PMStartServers="10"
    PMMinSpareServers="5"
    PMMaxSpareServers="35"
    PMMaxRequests="500"

fi

# GET ANY PHP INI PATH (Used to get current timezone next)
if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    PHPINI="/etc/php.ini"

    cd /etc/opt/remi || true
    for Version in *; do

        if sudo test -f "/etc/opt/remi/$Version/php.ini" ; then

            PHPINI="/etc/opt/remi/$Version/php.ini"
            break
        fi

    done

elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

    cd /etc/php || true
    for Version in *; do

        if sudo test -f "/etc/php/$Version/fpm/php.ini" ; then

            PHPINI="/etc/php/$Version/fpm/php.ini"
            break

        fi

    done

fi

# GET Server Timezone
TimezoneCode=$(sudo grep "^date.timezone" "$PHPINI")

if [ "$TimezoneCode" = "" ]; then
    Timezone="Africa/Cairo"
else

    IFS='=' read -r -a Array <<<"$TimezoneCode"
    Timezone="${Array[1]}"

    # Remove "
    Timezone=$(echo "$Timezone" | tr -d '"')
    Timezone=$(echo "$Timezone" | sed -e 's/^[ \t]*//')

    ServerTimezone="$Timezone"
fi

if [ "$Action" = "delete" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo rm -rf "/etc/php-fpm.d/$Domain.conf"
        sudo rm -rf /etc/opt/remi/*/php-fpm.d/"$Domain.conf"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo rm -rf /etc/php/*/fpm/pool.d/"$Domain.conf"

    fi

elif [ "$Action" = "go" ]; then

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        VersionPath="/etc/opt/remi"
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
        VersionPath="/etc/php"
    elif [ "$OS" = "OpenSUSE" ]; then
        VersionPath="/etc/php"
    fi

    # Installed version
    cd "$VersionPath" || exit
    for Version in *; do

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
            DirPath="/etc/opt/remi/$Version/php-fpm.d"
            GoPool="/etc/opt/remi/$Version/php-fpm.d/go.conf"
        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
            DirPath="/etc/php/$Version/fpm/pool.d"
            GoPool="/etc/php/$Version/fpm/pool.d/go.conf"
        fi

        if sudo test -d "$DirPath" ; then

            # Keep Numbers Only
            SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

            # go Pool (Full Access/Default Version) Used with Control Panel
            {
                echo "[go]"
                echo "listen = /run/sock/$SockFolder/go.sock"
                echo "listen.allowed_clients = 127.0.0.1"

                if [ "$WS" = "NGINX" ]; then

                    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                        echo "listen.owner = nginx"
                        echo "listen.group = nginx"

                    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                        echo "listen.owner = www-data"
                        echo "listen.group = www-data"

                    fi

                else

                    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                        echo "listen.owner = apache"
                        echo "listen.group = apache"

                    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                        echo "listen.owner = www-data"
                        echo "listen.group = www-data"

                    fi

                fi

                echo "listen.mode = 0660"
                echo "user = go"
                echo "group = go"
                echo "pm = ondemand"
                echo "pm.max_children = 1000"
                echo "pm.process_idle_timeout = 10s"
                echo "pm.max_requests = 0"
                echo "request_slowlog_timeout = 30s"
                echo "slowlog = /var/log/go/slow.log"
                echo "php_flag[display_errors] = on"
                echo "php_admin_value[error_log] = /var/log/go/error.log"
                echo "php_admin_flag[log_errors] = on"
                echo "php_value[session.save_handler] = files"
                echo "php_value[session.save_path]    = /var/lib/php/session"
                echo "php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache"
                echo "php_value[date.timezone] = $Timezone"
            } | sudo tee "$GoPool" >/dev/null

        fi

    done

else

    Timezone=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Timezone from Site where Domain='$Domain'")

    if [ "$Timezone" = "" ]; then
        Timezone="$ServerTimezone"
    fi

    if [ "$Timezone" = "" ]; then
        Timezone="Africa/Cairo"
    fi

    if sudo test ! -d "/home/$Domain" ; then
        echo "PHP-FPM: Domain $Domain not exists."
        exit 1
    fi

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        if sudo test ! -f "/etc/httpd/vhost/$Domain.conf" ; then
            echo "PHP-FPM: Configuration File /etc/httpd/vhost/$Domain.conf not found."
            exit 1
        fi

        VersionPath="/etc/opt/remi"

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        if sudo test ! -f "/etc/apache2/vhost/$Domain.conf" ; then
            echo "PHP-FPM: Configuration File /etc/apache2/vhost/$Domain.conf not found."
            exit 1
        fi

        VersionPath="/etc/php"

    elif [ "$OS" = "OpenSUSE" ]; then

        if sudo test ! -f "/etc/apache2/vhost/$Domain.conf" ; then
            echo "PHP-FPM: Configuration File /etc/apache2/vhost/$Domain.conf not found."
            exit 1
        fi

        VersionPath="/etc/php"

    fi

    # Main Config
    cd "$VersionPath" || exit
    for Version in *; do

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
            Config="/etc/opt/remi/$Version/php-fpm.conf"
        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
            Config="/etc/php/$Version/php-fpm.conf"
        elif [ "$OS" = "OpenSUSE" ]; then
            Config="/etc/$Version/fpm/php-fpm.conf"
        fi

        if sudo test -f "$Config" ; then

            sudo sed -i "s/;emergency_restart_threshold = 0/emergency_restart_threshold = 3/g" "$Config"
            sudo sed -i "s/;emergency_restart_interval = 0/emergency_restart_interval = 1m/g" "$Config"
            sudo sed -i "s/;process_control_timeout = 0/process_control_timeout = 5s/g" "$Config"

        fi

    done

    # Installed version
    cd "$VersionPath" || exit
    for Version in *; do

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
            DirPath="/etc/opt/remi/$Version/php-fpm.d"
            PoolPath="/etc/opt/remi/$Version/php-fpm.d/$Domain.conf"
        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
            DirPath="/etc/php/$Version/fpm/pool.d"
            PoolPath="/etc/php/$Version/fpm/pool.d/$Domain.conf"
        fi

        if sudo test -d "$DirPath" ; then

            if [ "$PHPVersion" = "$Version" ]; then

                # Keep Numbers Only
                SockFolder=$(echo "$Version" | sed 's/[^0-9]*//g')

                {
                    echo "[$Domain]"
                    echo "listen = /run/sock/$SockFolder/$Domain.sock"
                    echo "listen.allowed_clients = 127.0.0.1"

                    if [ "$WS" = "NGINX" ]; then

                        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                            echo "listen.owner = nginx"
                            echo "listen.group = nginx"

                        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                            echo "listen.owner = www-data"
                            echo "listen.group = www-data"

                        fi

                    else

                        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

                            echo "listen.owner = apache"
                            echo "listen.group = apache"

                        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

                            echo "listen.owner = www-data"
                            echo "listen.group = www-data"

                        fi

                    fi

                    echo "listen.mode = 0660"
                    echo "user = $Username"
                    echo "group = $Username"
                    echo "pm = dynamic"
                    echo "pm.max_children = $PMMaxChildren"
                    echo "pm.start_servers = $PMStartServers"
                    echo "pm.min_spare_servers = $PMMinSpareServers"
                    echo "pm.max_spare_servers = $PMMaxSpareServers"
                    echo "pm.max_requests = $PMMaxRequests"
                    echo "request_slowlog_timeout = 30s"
                    echo "slowlog = /home/$Domain/log/slow.log"
                    echo "php_flag[display_errors] = on"
                    echo "php_admin_value[error_log] = /home/$Domain/log/error.log"
                    echo "php_admin_value[disable_functions] = $DisableFunctions"
                    echo "php_admin_value[mail.add_x_header] = on"
                    echo "php_admin_value[mail.log] = /home/$Domain/log/mail.log"
                    echo "php_admin_flag[log_errors] = on"
                    echo "php_value[session.save_handler] = files"
                    echo "php_value[session.save_path]    = /var/lib/$Version/session"
                    echo "php_value[soap.wsdl_cache_dir]  = /var/lib/$Version/wsdlcache"
                    echo "php_value[date.timezone] = $Timezone"

                    if [[ "$OpenBasedir" = *"/"* ]]; then

                        echo "php_admin_value[open_basedir] = /home/$Domain:/backup/$Domain:/var/cache/$Domain:/usr/local/goadmio/includes:$OpenBasedir:/tmp"

                    else

                        echo "php_admin_value[open_basedir] = /home/$Domain:/backup/$Domain:/var/cache/$Domain:/usr/local/goadmio/includes:/tmp"

                    fi

                    if [ "$CacheActive" = "1" ]; then

                        echo "php_admin_value[auto_prepend_file] = /home/$Domain/etc/cache.php"

                    fi
                } | sudo tee "$PoolPath" >/dev/null

            else

                sudo rm -rf "$PoolPath"

            fi

        fi

    done

fi