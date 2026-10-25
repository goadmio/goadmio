#!/bin/bash

echo $(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@ >> /var/log/go/$(basename "$0").log

  ____         _       _           _       
 / ___| ___   / \   __| |_ __ ___ (_) ___  
| |  _ / _ \ / _ \ / _` | '_ ` _ \| |/ _ \ 
| |_| | (_) / ___ \ (_| | | | | | | | (_) |
 \____|\___/_/   \_\__,_|_| |_| |_|_|\___/ 


# sudo yum install figlet toilet
# figlet GoAdmio
