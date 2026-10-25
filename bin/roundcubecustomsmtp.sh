#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

RoundcubeSMTPHost=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select RoundcubeSMTPHost from Site where Domain='$Domain'")
RoundcubeSMTPUser=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select RoundcubeSMTPUser from Site where Domain='$Domain'")
RoundcubeSMTPPass=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select RoundcubeSMTPPass from Site where Domain='$Domain'")
RoundcubeSMTPPort=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select RoundcubeSMTPPort from Site where Domain='$Domain'")
RoundcubeSMTPActive=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select RoundcubeSMTPActive from Site where Domain='$Domain'")

if [ "$RoundcubeSMTPPort" = "465" ]; then
    Protocol="ssl://"
elif [ "$RoundcubeSMTPPort" = "587" ]; then
    Protocol="tls://"
else
    Protocol=""
fi

if sudo test -d /home/$Domain/www ; then

    if [ "$RoundcubeSMTPHost" = "" ] || [ "$RoundcubeSMTPUser" = "" ] || [ "$RoundcubeSMTPPass" = "" ] || [ "$RoundcubeSMTPPort" = "" ] || [ "$RoundcubeSMTPActive" = "0" ]; then

        echo "Custom Roundcube SMTP \"$Domain\" disabled successfully."
        sudo rm -rf /home/$Domain/etc/roundcube.php

    else

        sudo mkdir -p /home/$Domain/etc

        echo "Custom Roundcube SMTP \"$Domain\" created successfully."

        echo "<?php" | sudo tee /home/$Domain/etc/roundcube.php >/dev/null
        echo "\$config['smtp_server'] = \"${Protocol}${RoundcubeSMTPHost}\";" | sudo tee -a /home/$Domain/etc/roundcube.php >/dev/null
        echo "\$config['smtp_user'] = \"$RoundcubeSMTPUser\";" | sudo tee -a /home/$Domain/etc/roundcube.php >/dev/null
        echo "\$config['smtp_pass'] = \"$RoundcubeSMTPPass\";" | sudo tee -a /home/$Domain/etc/roundcube.php >/dev/null
        echo "\$config['smtp_port'] = \"$RoundcubeSMTPPort\";" | sudo tee -a /home/$Domain/etc/roundcube.php >/dev/null
        echo "?>" | sudo tee -a /home/$Domain/etc/roundcube.php >/dev/null

        sudo chmod 777 /home/$Domain/etc/roundcube.php

    fi

else

    echo "Domain $Domain does not exist."

fi
