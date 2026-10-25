#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/mailconf "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

if [ "$Domain" = "all" ]; then

    C=$(sudo find /home -maxdepth 1 -type d -name "*.*" | wc -l)

    cd /home
    for Domain in *; do

        if [[ "$Domain" = *"."* ]] && sudo test -d /home/$Domain ; then

            N=$(($N + 1))

            echo "$Domain..."
            sudo /go/mailconf $Domain

        fi

    done

    exit 1

fi

if sudo test -d "/home/$Domain/mail" ; then

    cd /home/$Domain/mail
    for User in *; do

        Email="$User@$Domain"

        if sudo test -d "/home/$Domain/mail/$User" ; then

            echo "# $User@$Domain Config" | sudo tee /home/$Domain/mail/$User.conf >/dev/null
            sudo sqlite3 -batch -init /usr/local/goadmio/sqlite/sqlite.conf /var/lib/sqlite/mail.db "
				SELECT IFNULL(Email,'') || '|' || IFNULL(Pass,'') || '|' || IFNULL(ForwardTo,'') || '|' || IFNULL(Reject,'0') || '|' || IFNULL(RejectMessage,'') || '|' || IFNULL(KeepCopy,'0') || '|' || IFNULL(Domain,'') || '|' || IFNULL(DefaultAddress,'0') || '|' || IFNULL(Suspend,'0') || '|' || IFNULL(Admin,'0')
				FROM Mail
				WHERE Email='$Email'
			" | while IFS='|' read -r Email Pass ForwardTo Reject RejectMessage KeepCopy Domain DefaultAddress Suspend Admin; do

                if [[ "$Email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then

                    echo "Email=\"$Email\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "Pass=\"$Pass\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "ForwardTo=\"$ForwardTo\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "Reject=\"$Reject\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "RejectMessage=\"$RejectMessage\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "KeepCopy=\"$KeepCopy\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "Domain=\"$Domain\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "DefaultAddress=\"$DefaultAddress\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "Suspend=\"$Suspend\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null
                    echo "Admin=\"$Admin\"" | sudo tee -a /home/$Domain/mail/$User.conf >/dev/null

                fi

            done

        fi

    done

fi
