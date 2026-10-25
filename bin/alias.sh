#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)

AliasDomain=$1
Domain=$2
Action=$3

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

if [ "$Action" = "delete" ]; then

    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "delete from Alias where AliasDomain='$AliasDomain'"

    echo "Alias Domain $AliasDomain has been deleted."

    exit 1

fi

TrashExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Trash from Site where Domain='$AliasDomain'")

if [ "$TrashExists" = "1" ]; then
    echo "Account $AliasDomain already exists in recycle bin"
    echo "To create $AliasDomain Alias please remove it from recycle bin:"
    echo "Recover Terminated Accounts > Remove forever"
    exit 1
fi

if sudo test -d "/home/$AliasDomain" ; then
    echo "Website $AliasDomain already exists."
    exit 1
fi

if sudo test ! -d "/home/$Domain" ; then
    echo "Website $Domain not exists."
    exit 1
fi

AliasExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select AliasDomain from Alias where AliasDomain='$AliasDomain'")

if [ "$AliasExists" = "$Domain" ]; then

    PrimaryDomain=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "select Domain from Alias where AliasDomain='$AliasDomain'")

    echo "Sorry Domain $AliasDomain already exists as Alias Domain."
    echo "Primary Domain: $PrimaryDomain."

    exit 1

fi

echo "Creating a domain alias $AliasDomain..."

TimeStamp=$(date +'%s')
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/alias.db "INSERT INTO Alias (AliasDomain,Domain,Username,TimeStamp) VALUES ('$AliasDomain','$Domain','$Username','$TimeStamp')"

# Create VHOST CONF
sudo /go/apache $Domain
sudo /go/nginx $Domain
sudo /go/ssl $Domain

echo "The domain alias $AliasDomain was created."
