#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/apk "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

CreateAPK() {
    Domain="$1"

    if sudo test -d /home/$Domain/www ; then

        sudo mkdir -p /home/$Domain/www/app

        cd /home/$Domain/www/app

        sudo wget https://www.goadmio.com/app.tar.gz --no-check-certificate &>/dev/null
        sudo tar -xzf app.tar.gz
        sudo rm -rf /home/$Domain/www/app/app.tar.gz

        sudo sed -i "s/goadmio\.com/$Domain/g" /home/$Domain/www/app/app/smali/com/usr/local/goadmio/app/MainActivity.smali
        sudo sed -i "s/GoAdmio/$Domain/g" /home/$Domain/www/app/app/res/values/strings.xml
        sudo sed -i "s/GoAdmio/$Domain/g" /home/$Domain/www/app/app/assets/htmlapp/helpers/loading.html

        if sudo test ! -f /home/$Domain/www/app/logo.png ; then

            wkhtmltoimage --width 1024 --height 1024 https://$Domain /home/$Domain/www/app/logo.png

        fi

        if sudo test -f /home/$Domain/www/app/logo.png ; then

            convert /home/$Domain/www/app/logo.png -resize 192x192 /home/$Domain/www/app/app/res/mipmap-xxxhdpi/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 432x432 /home/$Domain/www/app/app/res/mipmap-xxxhdpi/ic_launcher_foreground.png
            convert /home/$Domain/www/app/logo.png -resize 192x192 /home/$Domain/www/app/app/res/mipmap-xxxhdpi/ic_launcher_round.png

            convert /home/$Domain/www/app/logo.png -resize 144x144 /home/$Domain/www/app/app/res/mipmap-xxhdpi/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 324x324 /home/$Domain/www/app/app/res/mipmap-xxhdpi/ic_launcher_foreground.png
            convert /home/$Domain/www/app/logo.png -resize 144x144 /home/$Domain/www/app/app/res/mipmap-xxhdpi/ic_launcher_round.png

            convert /home/$Domain/www/app/logo.png -resize 96x96 /home/$Domain/www/app/app/res/mipmap-xhdpi/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 216x216 /home/$Domain/www/app/app/res/mipmap-xhdpi/ic_launcher_foreground.png
            convert /home/$Domain/www/app/logo.png -resize 96x96 /home/$Domain/www/app/app/res/mipmap-xhdpi/ic_launcher_round.png

            convert /home/$Domain/www/app/logo.png -resize 48x48 /home/$Domain/www/app/app/res/mipmap-mdpi/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 108x108 /home/$Domain/www/app/app/res/mipmap-mdpi/ic_launcher_foreground.png
            convert /home/$Domain/www/app/logo.png -resize 48x48 /home/$Domain/www/app/app/res/mipmap-mdpi/ic_launcher_round.png

            convert /home/$Domain/www/app/logo.png -resize 72x72 /home/$Domain/www/app/app/res/mipmap-hdpi/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 162x162 /home/$Domain/www/app/app/res/mipmap-hdpi/ic_launcher_foreground.png
            convert /home/$Domain/www/app/logo.png -resize 72x72 /home/$Domain/www/app/app/res/mipmap-hdpi/ic_launcher_round.png

            convert /home/$Domain/www/app/logo.png -resize 192x192 /home/$Domain/www/app/app/res/mipmap/ic_launcher.png
            convert /home/$Domain/www/app/logo.png -resize 72x72 /home/$Domain/www/app/app/res/mipmap/ic_launcher_round.png

            echo "Building APK..."
            sudo /go/apktool b /home/$Domain/www/app/app

            sudo rm -rf /home/$Domain/www/app/app.apk
            sudo mv /home/$Domain/www/app/app/dist/app.apk /home/$Domain/www/app/app.apk
            sudo rm -rf /home/$Domain/www/app/app

            keytool -genkey -v -keystore crm.mls.eg.keystore -alias goadmio -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=mqttserver.ibm.com, OU=ID, O=IBM, L=Hursley, S=Hants, C=EG" -keystore keystore -storepass tiger -keypass tiger
            jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore keystore app.apk goadmio -storepass tiger -keypass tiger

            echo "<?php header('Location: app.apk'); ?>" | sudo tee /home/$Domain/www/app/index.php >/dev/null

            Email=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Email from Site where Domain='$Domain'")

            if [[ "$Email" = *"@"* ]]; then
                sudo /go/sendmail "Free Mobile App ($Domain)" "Dear Customer,\n\nDownload your free mobile app:\nhttps://$Domain/app\n\nGoAdmio Team" "Free Mobile App" "$Email"
            fi

        else

            echo "File /home/$Domain/www/app/logo.png not Exists."

        fi

    fi
}

if [ "$1" = "all" ] || [ "$1" = "" ]; then

    cd /home
    for Domain in *; do

        CreateAPK "$Domain"

    done

else

    CreateAPK "$1"

fi
