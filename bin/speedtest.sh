#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

#!/bin/bash

# Record start time
start_time=$(date +%s)

sudo mariadb -e "CREATE DATABASE SpeedTest;"
sudo mariadb -e "CREATE TABLE SpeedTest.T (ID INT AUTO_INCREMENT PRIMARY KEY,N INT DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"
sudo mariadb -e "TRUNCATE TABLE SpeedTest.T;"

echo "0" >/tmp/SpeedTest.test

for i in $(seq 1 1000); do
    echo "$i"
    echo "$i" >>/tmp/SpeedTest.test
    sudo mariadb -e "INSERT INTO SpeedTest.T (N) VALUES ('$i');"
done

sudo mariadb -e "DROP DATABASE SpeedTest;"

# Record end time
end_time=$(date +%s)

# Calculate elapsed time
elapsed=$((end_time - start_time))
echo "Time taken: $elapsed seconds"
