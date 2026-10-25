#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1
Name=$2
User=$3
Pass=$4
Action=$5

Pass=$(echo "${Pass//\[DollarSign\]/$}")
Pass=$(echo "${Pass//\[AndSign\]/&}")
Pass=$(echo "${Pass//\[EqualSign\]/=}")
Pass=$(echo "${Pass//\[HashSign\]/#}")

Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

# /var/lib/pgsql/data

if [ "$Action" = "delete" ]; then

    User=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where Name='$Name' and Domain='$Domain'")

    DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Name='$Name' and Domain='$Domain'")

    if [ "$DatabaseExists" = "$Name" ]; then

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "DELETE FROM Postgre where Name='$Name'"

        sudo -i -u postgres psql -c "DROP database $Name;"
        sudo -i -u postgres psql -c "DROP USER $User;"

        echo "Database $Name deleted successfully..."

    fi

elif [ "$Action" = "edit" ]; then

    CurrentUser=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where Name='$Name'")

    if [ "$User" = "$CurrentUser" ]; then

        sudo -i -u postgres psql -c "ALTER USER $User WITH PASSWORD '$Pass';"

        echo "Database '$Name' was successfully modified."

    else

        UserExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where Domain='$Domain'")
        if [ "$User" = "$UserExists" ]; then
            echo "Username '$User' already exists."
            exit 1
        fi

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "UPDATE Postgre SET User='$User' where Name='$Name'"

        sudo -i -u postgres psql -c "CREATE USER $User WITH PASSWORD '$Pass';"
        sudo -i -u postgres psql -c "ALTER DATABASE $Name OWNER TO $User;"
        sudo -i -u postgres psql -c "DROP USER $CurrentUser;"
        sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $Name TO $User;"
        sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $User;"
        sudo -i -u postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $User;"

    fi

else

    DomainExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Domain from Site where Domain='$Domain' and Trash=0")
    if [[ ! "$DomainExists" = "$Domain" ]]; then
        echo "Account $Domain not exists"
        exit 1
    fi

    DatabaseExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select Name from Postgre where Name='$Name'")
    if [ "$Name" = "$DatabaseExists" ]; then
        echo "Database '$Name' already exists."
        exit 1
    fi

    UserExists=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "select User from Postgre where User='$User'")
    if [ "$User" = "$UserExists" ]; then
        echo "Username '$User' already exists."
        exit 1
    fi

    TimeStamp=$(date +'%s')
    sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/postgre.db "INSERT INTO Postgre (Name,User,Pass,Domain,Username,TimeStamp) VALUES ('$Name','$User','$Pass','$Domain','$Username','$TimeStamp')"

    sudo su - postgres -c "createdb $Name"
    sudo -i -u postgres psql -c "CREATE USER $User WITH PASSWORD '$Pass';"
    sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $Name TO $User;"
    sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $User;"
    sudo -i -u postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $User;"

    echo "Database '$Name' created successfully."

fi
