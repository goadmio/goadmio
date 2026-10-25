#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# This script automates the installation of an OpenVPN server on AlmaLinux
# and automatically generates a client configuration file with embedded certificates.

# IMPORTANT: Run this script as root or with sudo.

# --- Configuration Variables ---
# !!! IMPORTANT: Replace with your server's public IP address or hostname !!!
# If left empty, the script will attempt to detect it, but it's safer to set it manually.
SERVER_IP=""
OPENVPN_PORT="1194"
OPENVPN_PROTOCOL="udp" # Can be 'udp' or 'tcp'

# Client name for the auto-generated configuration
CLIENT_NAME="config"

# --- Paths ---
EASY_RSA_DIR="/etc/openvpn/easy-rsa"
OPENVPN_SERVER_DIR="/etc/openvpn/server"
CLIENT_CONFIG_OUTPUT_DIR="/usr/local/goadmio/home/go/vpn"

# --- Functions ---

# Function to check for root privileges
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root or with sudo."
        exit 1
    fi
}

# Function to install necessary packages
install_packages() {
    echo "--- Installing OpenVPN, Easy-RSA"
    sudo dnf install -y openvpn
    sudo dnf install -y easy-rsa
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install required packages. Please check your internet connection or DNF repositories."
        exit 1
    fi
    echo "Required packages installed successfully."
}

# Function to detect server's public IP
detect_server_ip() {
    if [ -z "$SERVER_IP" ]; then
        echo "Attempting to detect server's public IP..."
        # Use curl to get public IP. This might not work correctly if behind complex NAT.
        SERVER_IP=$(curl -s ifconfig.me)
        if [ -z "$SERVER_IP" ]; then
            echo "Warning: Could not automatically detect public IP. Please manually enter your server's public IP."
            read -p "Enter your server's public IP address: " SERVER_IP
            if [ -z "$SERVER_IP" ]; then
                echo "Error: Server IP cannot be empty. Exiting."
                exit 1
            fi
        fi
        echo "Detected/Using Server IP: $SERVER_IP"
    else
        echo "Using pre-configured Server IP: $SERVER_IP"
    fi
}

# Function to set up Easy-RSA PKI
setup_easy_rsa() {
    echo "--- Setting up Easy-RSA PKI ---"
    sudo mkdir -p "$EASY_RSA_DIR"
    sudo cp -r /usr/share/easy-rsa/3.2.1/* "$EASY_RSA_DIR/" # Adjust version if different
    sudo chmod 700 "$EASY_RSA_DIR"                          # Secure permissions

    cd "$EASY_RSA_DIR" || {
        echo "Error: Failed to navigate to Easy-RSA directory."
        exit 1
    }

    # Initialize PKI
    echo "Initializing PKI..."
    ./easyrsa init-pki
    if [ $? -ne 0 ]; then
        echo "Error: Failed to initialize PKI."
        exit 1
    fi

    # Build CA (Certificate Authority)
    # 'nopass' is used for automation; for production, consider using a password
    echo "Building CA (Certificate Authority)..."
    ./easyrsa build-ca nopass
    if [ $? -ne 0 ]; then
        echo "Error: Failed to build CA."
        exit 1
    fi
    echo "CA created."
}

# Function to generate server certificates and keys
generate_server_certs() {
    echo "--- Generating server certificates and keys ---"
    cd "$EASY_RSA_DIR" || {
        echo "Error: Failed to navigate to Easy-RSA directory."
        exit 1
    }

    # Generate server request
    echo "Generating server certificate request..."
    ./easyrsa gen-req server nopass
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate server request."
        exit 1
    fi

    # Sign server certificate
    echo "Signing server certificate..."
    ./easyrsa sign-req server server
    if [ $? -ne 0 ]; then
        echo "Error: Failed to sign server certificate."
        exit 1
    fi
    echo "Server certificate signed."

    # Generate Diffie-Hellman parameters
    echo "Generating Diffie-Hellman parameters (this may take a while)..."
    ./easyrsa gen-dh
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate DH parameters."
        exit 1
    fi
    echo "Diffie-Hellman parameters generated."

    # Generate TLS Auth key (HMAC firewall)
    echo "Generating TLS Auth key (ta.key)..."
    openvpn --genkey --secret "${OPENVPN_SERVER_DIR}/ta.key"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate ta.key."
        exit 1
    fi
    echo "TLS Auth key generated."
}

# Function to configure OpenVPN server
configure_openvpn_server() {
    echo "--- Configuring OpenVPN Server ---"
    sudo mkdir -p "$OPENVPN_SERVER_DIR"

    # Copy generated files to OpenVPN server directory
    echo "Copying certificates and keys to OpenVPN server directory..."
    sudo cp "${EASY_RSA_DIR}/pki/ca.crt" "${OPENVPN_SERVER_DIR}/"
    sudo cp "${EASY_RSA_DIR}/pki/issued/server.crt" "${OPENVPN_SERVER_DIR}/"
    sudo cp "${EASY_RSA_DIR}/pki/private/server.key" "${OPENVPN_SERVER_DIR}/"
    sudo cp "${EASY_RSA_DIR}/pki/dh.pem" "${OPENVPN_SERVER_DIR}/"
    # ta.key was already generated directly into OPENVPN_SERVER_DIR

    # Create server.conf
    echo "Creating server.conf..."
    sudo cat >"${OPENVPN_SERVER_DIR}/server.conf" <<EOF
port ${OPENVPN_PORT}
proto ${OPENVPN_PROTOCOL}
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0 # This is the server side of tls-auth
server 10.8.0.0 255.255.255.0 # VPN subnet
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp" # Redirect all client traffic through VPN
push "dhcp-option DNS 8.8.8.8" # Google DNS
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC # Recommended cipher, must match client
auth SHA256 # Recommended auth, must match client
comp-lzo # Data compression, must match client (deprecated in newer versions, consider 'no-compress' or 'compress lz4-v2')
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF
    echo "server.conf created."

    # Enable IP forwarding
    echo "Enabling IP forwarding..."
    echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-openvpn-forwarding.conf >/dev/null
    sudo sysctl -p /etc/sysctl.d/99-openvpn-forwarding.conf
    echo "IP forwarding enabled."
}

# Function to configure firewall (firewalld)
configure_firewall() {
    echo "--- Configuring Firewalld ---"
    sudo systemctl enable --now firewalld
    sudo systemctl start firewalld

    # Add OpenVPN service to trusted zone or open port
    echo "Adding OpenVPN port to firewalld..."
    sudo firewall-cmd --permanent --add-port=${OPENVPN_PORT}/${OPENVPN_PROTOCOL}
    sudo firewall-cmd --permanent --add-masquerade                                                             # Enable NAT for VPN clients
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.8.0.0/24" masquerade' # Masquerade VPN subnet
    sudo firewall-cmd --reload
    if [ $? -ne 0 ]; then
        echo "Error: Failed to configure firewalld. Please check firewalld status."
        exit 1
    fi
    echo "Firewalld configured for OpenVPN."
}

# Function to start and enable OpenVPN service
start_openvpn() {
    echo "--- Starting and enabling OpenVPN service ---"
    sudo systemctl enable openvpn-server@server.service
    sudo systemctl start openvpn-server@server.service
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start OpenVPN service. Check logs with 'journalctl -xeu openvpn-server@server.service'."
        exit 1
    fi
    echo "OpenVPN service started and enabled."
    echo "OpenVPN server status:"
    sudo systemctl status openvpn-server@server.service --no-pager
}

# Function to generate client certificate and configuration file
generate_client_config() {
    local client_name="$1"
    echo "--- Generating client certificate and configuration for ${client_name} ---"

    if [ -z "$client_name" ]; then
        echo "Error: Client name not provided for configuration generation."
        exit 1
    fi

    # Navigate to Easy-RSA directory
    cd "$EASY_RSA_DIR" || {
        echo "Error: Easy-RSA directory not found."
        exit 1
    }

    # Build client certificate and key
    # 'nopass' is used for automation; for production, consider more secure methods
    echo "Generating client key and certificate for ${client_name}..."
    ./easyrsa build-client-full "${client_name}" nopass
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate client certificate for ${client_name}."
        exit 1
    fi
    echo "Client certificate and key generated."

    # Create output directory for client configs if it doesn't exist
    sudo mkdir -p "$CLIENT_CONFIG_OUTPUT_DIR"

    # Paths to the generated client files
    local ca_crt="${EASY_RSA_DIR}/pki/ca.crt"
    local client_crt="${EASY_RSA_DIR}/pki/issued/${client_name}.crt"
    local client_key="${EASY_RSA_DIR}/pki/private/${client_name}.key"
    local ta_key="${OPENVPN_SERVER_DIR}/ta.key" # ta.key is copied to server config dir

    # Check if all necessary files exist
    if sudo test ! -f "$ca_crt"  || sudo test ! -f "$client_crt"  || sudo test ! -f "$client_key"  || sudo test ! -f "$ta_key" ; then
        echo "Error: Missing one or more required files for client configuration:"
        echo "CA Cert: $ca_crt (Exists: $(test -f "$ca_crt"  && echo "Yes" || echo "No"))"
        echo "Client Cert: $client_crt (Exists: $(test -f "$client_crt"  && echo "Yes" || echo "No"))"
        echo "Client Key: $client_key (Exists: $(test -f "$client_key"  && echo "Yes" || echo "No"))"
        echo "TLS Auth Key: $ta_key (Exists: $(test -f "$ta_key"  && echo "Yes" || echo "No"))"
        exit 1
    fi

    # Generate the .ovpn file content
    local ovpn_file="${CLIENT_CONFIG_OUTPUT_DIR}/${client_name}.ovpn"
    sudo cat >"${ovpn_file}" <<EOF
client
dev tun
proto ${OPENVPN_PROTOCOL}
remote ${SERVER_IP} ${OPENVPN_PORT}
resolv-retry infinite
nobind
persist-key
persist-tun
redirect-gateway def1
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
remote-cert-tls server
cipher AES-256-CBC # Must match server
auth SHA256 # Must match server
key-direction 1 # This is the client side of tls-auth (direction 1)
<ca>
$(sudo cat "${ca_crt}")
</ca>
<cert>
$(sudo cat "${client_crt}")
</cert>
<key>
$(sudo cat "${client_key}")
</key>
<tls-auth>
$(sudo cat "${ta_key}")
</tls-auth>
comp-lzo # Or "compress lz4-v2" or "no-compress" - must match server
verb 3
EOF

    echo "OpenVPN client configuration file '${ovpn_file}' created successfully."
    echo "This file contains all necessary certificates and keys inline."
    echo "You can now transfer this file to your client machine."
    echo "To connect via command line on the client: sudo openvpn --config ${ovpn_file}"
}

# --- Main script execution ---
check_root
install_packages
detect_server_ip
setup_easy_rsa
generate_server_certs
configure_openvpn_server
configure_firewall
start_openvpn
generate_client_config "${CLIENT_NAME}"

echo "--- OpenVPN server and client setup finished ---"
echo "Your OpenVPN server is now configured and running."
echo "The client configuration file is located at: ${CLIENT_CONFIG_OUTPUT_DIR}/${CLIENT_NAME}.ovpn"
echo "Transfer this file to your client machine and use it to connect."
echo "Remember to open port ${OPENVPN_PORT}/${OPENVPN_PROTOCOL} on any external firewalls if applicable."

sudo systemctl enable openvpn-server@server
sudo systemctl restart openvpn-server@server
