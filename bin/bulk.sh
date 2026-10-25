#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Port="22222"

sudo mkdir -p /var/log/go/bulk
sudo rm -rf /var/log/go/bulk/*.log

MAC=$(sudo /usr/sbin/ifconfig | awk '/ether/ {print $2}' | base64)
RemotePassword=$(sudo openssl base64 -d -aes-128-cbc -d -pbkdf2 -nosalt -md md5 -in /var/go/etc/go.key -pass pass:"$MAC")

if [ $# -eq 0 ]; then

    while true; do

        printf 'bulk> '
        read -r cmd

        if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]; then
            break
        fi

        eval "/go/bulk $cmd"

    done

    exit 1

fi

if sudo test -f /var/go/etc/bulk ; then

    if [ "$1" = "delete" ] && [ "$2" = "all" ]; then
        sudo rm -rf /var/go/etc/bulk
        exit 1
    elif [ "$1" = "delete" ] && [[ "$2" = *"."* ]]; then

        sudo sed -i "/^$2/d" /var/go/etc/bulk

        exit 1
    fi

    if [ "$1" = "list" ]; then
        sudo cat /var/go/etc/bulk
        exit 1
    fi

fi

if [ "$1" = "add" ] && [[ "$2" = *"."* ]]; then

    sudo sed -i "/^$2/d" /var/go/etc/bulk
    echo "$2" | sudo tee -a /var/go/etc/bulk >/dev/null

    exit 1

fi

if sudo test ! -f /var/go/etc/bulk ; then
    exit 1
fi

Exist=0
while IFS= read -r RemoteServer; do

    if [[ "$RemoteServer" = *"."* ]]; then

        Exist=1

        echo "$RemoteServer:" | sudo tee /var/log/go/bulk/${RemoteServer}.log >/dev/null

        # Run each ssh command with nohup in background
        sudo nohup sshpass -p "$RemotePassword" ssh -p $Port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@$RemoteServer $@ >>/var/log/go/bulk/${RemoteServer}.log 2>&1 &

        # Store PID
        PIDS+=($!)

        # echo "Started on $RemoteServer with PID: ${PIDS[-1]}"

    fi

done </var/go/etc/bulk

if [ "$Exist" -eq "0" ]; then
    echo "No Servers"
    exit 1
fi

# Wait for all processes to complete
for pid in "${PIDS[@]}"; do
    wait $pid
    # echo "PID $pid completed"
done

C=$(ls /var/log/go/bulk/*.log | wc -l)

if [ "$C" -eq "0" ]; then
    exit 1
fi

if [ "$C" -gt "5" ]; then

    while IFS= read -r RemoteServer; do

        if [[ "$RemoteServer" = *"."* ]]; then

            sudo cat /var/log/go/bulk/${RemoteServer}.log
            for ((i = 0; i < $(tput cols); i++)); do echo -n '─'; done
            echo

        fi

    done </var/go/etc/bulk

else

    W=$(((COLUMNS / $C) - 1))

    sudo sed -i 's/$/                                                                                                                             /' /var/log/go/bulk/*.log

    eval paste $(printf '<(cut -c1-$W "%s") ' /var/log/go/bulk/*.log) | head -7 |
        sudo awk -F'\t' '
	BEGIN {
		# Various dark backgrounds
		colors[1]="\033[100m"  # Bright black (dark gray)
		colors[2]="\033[0;41m" # Regular red (not bright)
		colors[3]="\033[40m"   # Black
		colors[4]="\033[0;45m" # Regular magenta (not bright)
		colors[4]="\033[0;44m" # Regular blue (not bright)
		colors[5]="\033[101m"  # Bright red (darker than \033[41m)
		colors[7]="\033[102m"  # Bright green (darker than \033[42m)
		colors[8]="\033[0;42m" # Regular green (not bright)
		
		white="\033[97m"       # Bright white foreground
		reset="\033[0m"
	}
	{
		for(i=1; i<=NF; i++) {
			printf "%s%s%s%s", white, colors[(i-1)%8+1], $i, reset
			if(i < NF) printf "│"
		}
		printf "\n"
	}'

fi
