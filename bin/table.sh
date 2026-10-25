#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

while getopts ":f:o:r:t:" opt; do
    case ${opt} in
    f) File=$OPTARG ;;
    o) Output=$OPTARG ;;
    r) Rename=$OPTARG ;;
    t) Table=$OPTARG ;;
    \?) echo "Usage: table [-f] SQL File Name [-t] Table Name [-o] Output File Name [-r] Rename Table (Optional)" ;;
    esac
done

if [ "$File" = "" ] || [ "$Table" = "" ]; then

    echo "Usage: table [-f] SQL File Name [-t] Table Name [-o] Output File Name [-r] Rename Table (Optional)"
    exit 1

fi

if [ "$Output" = "" ]; then

    Output="/root/$Table.sql"

fi

if sudo test ! -f "$File" ; then
    echo "File $File does not exist."
    exit 1
fi

if grep -q "DROP TABLE" $File; then

    # DROP

    sudo sed -n -e "/DROP TABLE IF EXISTS.*\`$Table\`/,/DROP TABLE/p" "$File" >$Output
    sudo sed -i "s/DROP TABLE IF EXISTS \`$Table\`/_DROP_ TABLE IF EXISTS \`$Table\`/g" $Output
    sudo sed -i "/DROP TABLE/d" $Output
    sudo sed -i "/ALTER TABLE/d" $Output
    sudo sed -i "/LOCK TABLES/d" $Output
    sudo sed -i "s/_DROP_/DROP/g" $Output
    sudo sed -i "/Table structure/d" $Output

    if [ "$Rename" != "" ]; then

        sudo sed -i "s/DROP TABLE IF EXISTS \`$Table\`/DROP TABLE IF EXISTS \`$Rename\`/g" $Output
        sudo sed -i "s/CREATE TABLE \`$Table\`/CREATE TABLE \`$Rename\`/g" $Output
        sudo sed -i "s/INSERT INTO \`$Table\`/INSERT INTO \`$Rename\`/g" $Output
        sudo sed -i "s/LOCK TABLES \`$Table\`/LOCK TABLES \`$Rename\`/g" $Output
        sudo sed -i "s/table \`$Table\`/table \`$Rename\`/g" $Output

    fi

else

    # TRUNCATE

    sudo sed -n -e "/TRUNCATE TABLE.*\`$Table\`/,/TRUNCATE TABLE/p" "$File" >$Output
    sudo sed -i "s/TRUNCATE TABLE \`$Table\`/_TRUNCATE_ TABLE \`$Table\`/g" $Output
    sudo sed -i "/TRUNCATE TABLE/d" $Output
    sudo sed -i "/ALTER TABLE/d" $Output
    sudo sed -i "/LOCK TABLES/d" $Output
    sudo sed -i "s/_TRUNCATE_/TRUNCATE/g" $Output
    sudo sed -i "/Table structure/d" $Output

    if [ "$Rename" != "" ]; then

        sudo sed -i "s/TRUNCATE TABLE \`$Table\`/TRUNCATE TABLE \`$Rename\`/g" $Output
        sudo sed -i "s/INSERT INTO \`$Table\`/INSERT INTO \`$Rename\`/g" $Output
        sudo sed -i "s/LOCK TABLES \`$Table\`/LOCK TABLES \`$Rename\`/g" $Output
        sudo sed -i "s/table \`$Table\`/table \`$Rename\`/g" $Output

    fi

fi

echo "File $Output created successfully."
