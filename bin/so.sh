#!/bin/bash

echo "$(date +'[%b %d %H:%M:%S]#') $(basename "$0") $@" >>"/var/log/go/$(basename "$0").log"

OS=$(</usr/local/goadmio/linux/os.db)

cd /usr/local/goadmio/so/decoder
for PHPVersion in *; do

    if [[ "$PHPVersion" = *"."* ]]; then

        if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

            Version="${PHPVersion//./}"

            if sudo test -d "/opt/remi/php${Version}/root/usr/lib64/php/modules" ; then
                sudo rm -rf /opt/remi/php${Version}/root/usr/lib64/php/modules/decoder.so
                sudo cp /usr/local/goadmio/so/decoder/${PHPVersion}/decoder.so /opt/remi/php${Version}/root/usr/lib64/php/modules/
            fi

            if sudo test -d "/etc/opt/remi/php${Version}/php.d" ; then
                echo "; Enable GoAdmio Decoder" | sudo tee /etc/opt/remi/php${Version}/php.d/decoder.ini >/dev/null
                echo "extension=decoder.so" | sudo tee -a /etc/opt/remi/php${Version}/php.d/decoder.ini >/dev/null
            fi

        elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

            if sudo test -f "/usr/bin/php${PHPVersion}" ; then

                ExtensionDir=$(php${PHPVersion} -r 'echo ini_get("extension_dir");')

                if sudo test -d "$ExtensionDir" ; then
                    sudo rm -rf $ExtensionDir/decoder.so
                    sudo cp /usr/local/goadmio/so/decoder/${PHPVersion}/decoder.so $ExtensionDir/
                fi

                if sudo test -d "/etc/php/${PHPVersion}/fpm/conf.d" ; then
                    echo "; Enable GoAdmio Decoder" | sudo tee /etc/php/${PHPVersion}/fpm/conf.d/decoder.ini >/dev/null
                    echo "extension=decoder.so" | sudo tee -a /etc/php/${PHPVersion}/fpm/conf.d/decoder.ini >/dev/null
                fi

            fi

        fi

    fi

done

# Install for CLI
PHPVersion=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')
Version="${PHPVersion//./}"

if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

    if sudo test -f /usr/local/goadmio/so/decoder/${PHPVersion}/decoder.so ; then

        if sudo test -d "/etc/php.d" ; then
            echo "extension=decoder.so" | sudo tee "/etc/php.d/decoder.ini"
        fi

        ExtensionDir=$(php-config --extension-dir)
        sudo rm -rf $ExtensionDir/decoder.so
        sudo cp /usr/local/goadmio/so/decoder/${PHPVersion}/decoder.so $ExtensionDir/

    fi

fi