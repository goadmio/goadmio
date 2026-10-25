#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/installdkim "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

OS=$(</usr/local/goadmio/linux/os.db)
Hostname=$(</etc/hostname)

if [ $# -eq 0 ]; then

    echo "Installing DKIM..."

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then

        sudo dnf install -y opendkim
        sudo dnf install -y opendkim-tools

    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then

        sudo apt -y install opendkim
        sudo apt -y install opendkim-tools

    fi

    # Config DKIM
    echo "AutoRestart             Yes" | sudo tee /etc/opendkim.conf >/dev/null
    echo "AutoRestartRate         10/1h" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "UMask                   002" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Selector                dkim" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Syslog                  yes" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "SyslogSuccess           Yes" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "LogWhy                  Yes" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Canonicalization        relaxed/simple" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "InternalHosts           refile:/etc/opendkim/TrustedHosts" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "KeyTable                refile:/etc/opendkim/KeyTable" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "SigningTable            refile:/etc/opendkim/SigningTable" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Mode                    sv" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "SignatureAlgorithm      rsa-sha256" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "UserID                  opendkim:opendkim" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Socket                  inet:8891@localhost" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "Syslog                  yes" | sudo tee -a /etc/opendkim.conf >/dev/null
    echo "OversignHeaders         From" | sudo tee -a /etc/opendkim.conf >/dev/null

    if [[ "$OS" = @(AlmaLinux|Rocky|CentOS|Red Hat|Fedora) ]]; then
        echo "PidFile                 /var/run/opendkim/opendkim.sock" | sudo tee -a /etc/opendkim.conf >/dev/null
    elif [[ "$OS" = @(Debian|Ubuntu) ]]; then
        echo "PidFile                 /var/run/opendkim/opendkim.pid" | sudo tee -a /etc/opendkim.conf >/dev/null
        echo "TrustAnchorFile         /usr/share/dns/root.key" | sudo tee -a /etc/opendkim.conf >/dev/null

        sudo sed -i '/^SOCKET/d' /etc/default/opendkim
        echo "SOCKET=\"inet:8891@localhost\"" | sudo tee -a /etc/default/opendkim >/dev/null
    fi

    echo "127.0.0.1" | sudo tee /etc/opendkim/TrustedHosts >/dev/null
    echo "::1" | sudo tee -a /etc/opendkim/TrustedHosts >/dev/null
    echo "$Hostname" | sudo tee -a /etc/opendkim/TrustedHosts >/dev/null

    # Add all domains here
    echo "blaclhost.com" | sudo tee -a /etc/opendkim/TrustedHosts >/dev/null

    echo "dkim._domainkey.w75.net w75.net:dkim:/etc/opendkim/w75.net/dkim.private" | sudo tee -a /etc/opendkim/KeyTable >/dev/null
    echo "*@w75.net dkim._domainkey.w75.net" | sudo tee -a /etc/opendkim/SigningTable >/dev/null
    sudo /go/adduser opendkim

fi

if [ "$Domain" = "all" ]; then

    # Create DKIM All Sites
    cd /home
    for Domain in *; do

        if sudo test -d "/home/$Domain/www" ; then

            if sudo test ! -f "/etc/opendkim/$Domain/dkim.txt" ; then

                sudo /go/dkim $Domain

            fi

        fi

    done

    exit 1

fi

if [ "$Action" = "dns" ]; then

    # Get DKIM TXT Record

    # read second line
    Code=$(sudo cat /etc/opendkim/$Domain/dkim.txt | sed -n '2p')

    IFS='"' read -r -a Array <<<"$Code"
    DNS="v=DKIM1; k=rsa; ${Array[1]}"

    echo "$DNS"

else

    # Generate DKIM Record

    if sudo test ! -d "/etc/opendkim" ; then
        sudo mkdir -p /etc/opendkim
    fi

    sudo mkdir -p /etc/opendkim/$Domain
    opendkim-genkey -D /etc/opendkim/$Domain -d $Domain -s dkim
    sudo chown -R opendkim /etc/opendkim/$Domain

    if grep -q "^$Domain" /etc/opendkim/TrustedHosts; then
        echo ""
    else
        echo "$Domain" | sudo tee -a /etc/opendkim/TrustedHosts >/dev/null
    fi

    if grep -q "^dkim._domainkey.$Domain" /etc/opendkim/KeyTable; then
        echo ""
    else
        echo "dkim._domainkey.$Domain $Domain:dkim:/etc/opendkim/$Domain/dkim.private" | sudo tee -a /etc/opendkim/KeyTable >/dev/null
    fi

    if grep -q "*@$Domain " /etc/opendkim/SigningTable; then
        echo ""
    else

        echo "*@$Domain dkim._domainkey.$Domain" | sudo tee -a /etc/opendkim/SigningTable >/dev/null

    fi

fi
