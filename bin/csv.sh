#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# csv -s "SELECT * from crm.DLD where Mobile like '20%' or Keywords like '%egypt%' group by Mobile" -o egypt.csv

while getopts ":s:o:" opt; do
    case ${opt} in
    s) SQL=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    \?) echo "Usage: csv [-s] SQL Query [-o] Output File Name" ;;
    esac
done

sudo find /var/lib/mysql -name "file.csv" -delete

sudo mariadb -e "$SQL INTO OUTFILE 'file.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

CSVFile=$(sudo find /var/lib/mysql -name "file.csv" -print | head -n 1)

if [[ "$CSVFile" = *"file.csv"* ]]; then
    sudo mv $CSVFile $OUTPUT
fi
