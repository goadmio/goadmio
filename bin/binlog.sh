#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Dir=$1

if [ $# -eq 0 ]; then
    exit 1
fi

if sudo test ! -d $Dir ; then
    exit 1
fi

cd $Dir
for File in *; do

    NewFile="${File}1"

    if sudo test ! -f $NewFile ; then

        if [[ ! "$File" = *1 ]] && [ "$File" != "bash" ] && [ "$File" != "chmod" ] && [ "$File" != "rm" ] && [ "$File" != "mv" ] && [ "$File" != "ls" ] && [ "$File" != "dnf" ] && [ "$File" != "yum" ] && [ "$File" != "apt" ] && [ "$File" != "nano" ]; then

            sudo mv $File $NewFile

            echo "#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log" >$File
            echo "echo \"$File \$@\" >> /root/log.txt" >>$File
            echo "$NewFile \$@" >>$File

            sudo chmod +x $File

        fi

    fi

done
