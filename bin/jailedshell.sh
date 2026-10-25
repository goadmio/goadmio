#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Action=$2

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [[ "$@" = *"--disable"* ]] || [ "$Action" = "0" ]; then

    sudo gpasswd -d $Username Jailed

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET JailedShell=0 where Domain='$Domain'"

else

    # Create Jailed Group
    sudo groupadd Jailed

    # Add $Username to Jailed Group 
    sudo usermod -aG Jailed $Username

    sudo chown root:root /home/$Domain
    sudo chmod 755 /home/$Domain

    sudo mkdir -p /home/$Domain/{bin,lib,lib64}
    sudo cp /bin/bash /home/$Domain/bin/

    sudo mkdir -p /home/$Domain/etc

# Create system-wide profile
sudo tee "/home/$Domain/etc/profile" > /dev/null <<'EOF' >/dev/null
# /etc/profile inside chroot jail
export PATH="/bin:/usr/bin:/usr/local/bin"
export HOME="$PWD"
export PS1='[\u@\h \W]\$ '
EOF

# Create /etc/bashrc for non-login shells
sudo tee "/home/$Domain/etc/bashrc" > /dev/null <<'EOF' >/dev/null
# /etc/bashrc inside chroot jail
export PATH="/bin:/usr/bin:/usr/local/bin"
EOF

# Create user's .bash_profile (sources /etc/profile)
sudo tee "/home/$Domain/.bash_profile" > /dev/null <<'EOF' >/dev/null
# ~/.bash_profile inside chroot jail
if sudo test -f /etc/profile ; then
    . /etc/profile
fi
if sudo test -f ~/.bashrc ; then
    . ~/.bashrc
fi
EOF

# Create user's .bashrc (sources /etc/bashrc)
sudo tee "/home/$Domain/.bashrc" > /dev/null <<'EOF' >/dev/null
# ~/.bashrc inside chroot jail
if sudo test -f /etc/bashrc ; then
    . /etc/bashrc
fi
EOF

    # Find and copy the dependencies
    DEPS=$(ldd /bin/bash | grep -Po '\/lib(64)?\/[a-zA-Z0-9\-_/.]+.so((.[0-9]{1,2})*.[0-9]{1,2})?' | tr '\n' ' ')
    sudo cp --parents $DEPS /home/$Domain/

    for bin in /bin/ls /bin/cat /bin/rm /bin/mkdir; do
        sudo cp $bin /home/$Domain/bin/
        # Copy dependencies for each binary
        for dep in $(ldd $bin | grep -Po '\/lib(64)?\/[a-zA-Z0-9\-_/.]+.so((.[0-9]{1,2})*.[0-9]{1,2})?'); do
            sudo cp --parents $dep /home/$Domain/
        done
    done

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "UPDATE Site SET JailedShell=1,Shell=0 where Domain='$Domain'"

fi

sudo /go/ssh