#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/hash "$@"
fi

Domain="uae.mls.red"

if sudo test -d /home/$Domain/www/module/property/upload/image ; then

    cd /home/$Domain/www/module/property/upload/image

    for File in $(printf "%s\n" * | shuf); do

        if sudo test -f $File ; then

            if [[ "$File" = *"-"* ]]; then

                MD5File=$(md5sum $File | cut -d' ' -f1)

                if sudo test -f ${MD5File}.webp ; then

                    echo "File ${MD5File}.webp Found"
                    sudo rm -rf $File

                else

                    echo "File ${MD5File}.webp Created"
                    sudo mv $File ${MD5File}.webp

                fi

                sudo mariadb -e "update uae.Image SET ImageName='${MD5File}.webp' where ImageName='$File'"

            fi

        fi

    done

fi
