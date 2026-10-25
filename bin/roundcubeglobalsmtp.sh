#!/bin/bash

echo "$(date +'[%b %d %H:%M:%S]#') $(basename "$0") $@" >>"/var/log/go/$(basename "$0").log"

RoundcubeSMTPHost=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select RoundcubeSMTPHost FROM Config where ConfigID=1")
RoundcubeSMTPUser=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select RoundcubeSMTPUser FROM Config where ConfigID=1")
RoundcubeSMTPPass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select RoundcubeSMTPPass FROM Config where ConfigID=1")
RoundcubeSMTPPort=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select RoundcubeSMTPPort FROM Config where ConfigID=1")
RoundcubeSMTPActive=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/config.db "select RoundcubeSMTPActive FROM Config where ConfigID=1")

if [ "$RoundcubeSMTPPort" = "465" ]; then
    Protocol="ssl://"
elif [ "$RoundcubeSMTPPort" = "587" ]; then
    Protocol="tls://"
else
    Protocol=""
fi

if [ "$RoundcubeSMTPHost" = "" ] || [ "$RoundcubeSMTPUser" = "" ] || [ "$RoundcubeSMTPPass" = "" ] || [ "$RoundcubeSMTPPort" = "" ] || [ "$RoundcubeSMTPActive" = "0" ]; then

    sudo rm -rf /var/go/etc/roundcube.php

else

    echo "<?php" | sudo tee /var/go/etc/roundcube.php >/dev/null
    echo "\$config['smtp_server'] = \"${Protocol}${RoundcubeSMTPHost}\";" | sudo tee -a /var/go/etc/roundcube.php >/dev/null
    echo "\$config['smtp_user'] = \"$RoundcubeSMTPUser\";" | sudo tee -a /var/go/etc/roundcube.php >/dev/null
    echo "\$config['smtp_pass'] = \"$RoundcubeSMTPPass\";" | sudo tee -a /var/go/etc/roundcube.php >/dev/null
    echo "\$config['smtp_port'] = \"$RoundcubeSMTPPort\";" | sudo tee -a /var/go/etc/roundcube.php >/dev/null
    echo "?>" | sudo tee -a /var/go/etc/roundcube.php >/dev/null

    sudo chmod 777 /var/go/etc/roundcube.php

fi
