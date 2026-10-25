#!/bin/bash
echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

source /go/function

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

ProgressBar "Installing SSH2"

if command -v apt >/dev/null 2>&1; then
    OS_FAMILY="debian"
elif command -v dnf >/dev/null 2>&1; then
    OS_FAMILY="rhel"
elif command -v yum >/dev/null 2>&1; then
    OS_FAMILY="rhel"
else
    echo "Unsupported package manager. This script supports apt, dnf, and yum." >&2
    exit 1
fi

# Get OS release info for logging
if sudo test -f /etc/os-release ; then
    . /etc/os-release
    echo "OS: ${PRETTY_NAME:-$ID}"
fi

# --- Detect PHP version ---
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')
Version="${PHP_VERSION//./}"
echo "PHP Version: ${PHP_VERSION}"

if [[ ! "$@" = *"--force"* ]]; then

    SSH2_VERSION=$(php -r "echo phpversion('ssh2');")

    if sudo test -f /opt/remi/php${Version}/root/usr/lib64/php/modules/ssh2.so ; then

        if [[ ! "SSH2_VERSION" = *"."* ]]; then
            SSH2_VERSION=$(php${Version} -r "echo phpversion('ssh2');")
        fi

        echo "SSH2 Version: $SSH2_VERSION"
        exit 1

    fi

    if [ "$OS_FAMILY" = "debian" ]; then

        ExtensionDir=$(php${PHP_VERSION} -r 'echo ini_get("extension_dir");')

        if sudo test -f $ExtensionDir/ssh2.so ; then
            echo "SSH2 Version: $SSH2_VERSION"
            exit 1
        fi

    fi

    if php -m | grep -q ssh2; then
        echo "SSH2 is installed"
        exit 1
    fi

fi

echo "Installing SSH2..."

if [ "$OS_FAMILY" = "debian" ]; then
    sudo apt -y install libssh2-1-dev
    sudo apt -y install pkg-config
elif [ "$OS_FAMILY" = "rhel" ]; then
    sudo dnf -y install libssh2-devel
    sudo dnf -y install pkgconfig
fi

# --- Locate phpize and php-config ---
PHPIZE="phpize${PHP_VERSION}"
command -v "$PHPIZE" &>/dev/null || PHPIZE="phpize"
PHP_CONFIG=$(command -v "php-config${PHP_VERSION}" || command -v php-config)

if ! command -v "$PHPIZE" &>/dev/null; then
    echo "phpize not found. Ensure php-devel is installed."
    exit 1
fi

# --- Download and build SSH2 extension ---
SSH2_VERSION="1.5.0"
cd /tmp
sudo curl -fsSL -O "https://pecl.php.net/get/ssh2-${SSH2_VERSION}.tgz"
sudo rm -rf "ssh2-${SSH2_VERSION}"
sudo tar xf "ssh2-${SSH2_VERSION}.tgz"
cd "ssh2-${SSH2_VERSION}"

"$PHPIZE"
./configure --with-php-config="$PHP_CONFIG"
sudo make -j"$(nproc)"
sudo make install

if [ "$OS_FAMILY" = "debian" ]; then

    ExtensionDir=$(php-config --extension-dir)

    if sudo test ! -f $ExtensionDir/ssh2.so ; then
        sudo cp /usr/local/goadmio/so/ssh2/${PHP_VERSION}/ssh2.so $ExtensionDir/
    fi

    for SAPI in cli fpm apache2 cgi; do

        DIR="/etc/php/${PHP_VERSION}/${SAPI}/conf.d"
        if sudo test -d "$DIR" ; then
            echo "extension=ssh2.so" >"${DIR}/20-ssh2.ini"
        fi

    done

elif [ "$OS_FAMILY" = "rhel" ]; then

    # Install for CLI
    if sudo test -d "/etc/php.d" ; then
        echo "extension=ssh2.so" >"/etc/php.d/20-ssh2.ini"
    fi

    # Install for FPM
    if sudo test ! -f /opt/remi/php${Version}/root/usr/lib64/php/modules/ssh2.so ; then
    
        if sudo test -d /opt/remi/php${Version}/root/usr/lib64/php/modules ; then
            
            if sudo test -f /tmp/ssh2-${SSH2_VERSION}/modules/ssh2.so ; then
                sudo cp /tmp/ssh2-${SSH2_VERSION}/modules/ssh2.so /opt/remi/php${Version}/root/usr/lib64/php/modules/
            else
                sudo cp /usr/local/goadmio/so/ssh2/${PHP_VERSION}/ssh2.so /opt/remi/php${Version}/root/usr/lib64/php/modules/
            fi

        fi
    fi

    if sudo test -d "/etc/opt/remi/php${Version}/php.d" ; then
        echo "extension=ssh2.so" >"/etc/opt/remi/php${Version}/php.d/20-ssh2.ini"
    fi

fi
