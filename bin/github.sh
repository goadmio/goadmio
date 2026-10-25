#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

URL=$1
Directory=$2
Sync=$3

if [ $# -eq 0 ]; then

    SQL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/github.db "select  GithubID || ',' || URL || ',' || Directory || ',' || Date from Github where Sync=1;")
    for Result in $SQL; do

        IFS=',' read -r -a Row <<<"$Result"

        GithubID="${Row[0]}"
        URL="${Row[1]}"
        Directory="${Row[2]}"
        Date="${Row[3]}"

        IFS='/' read -r -a Array <<<"$URL"

        Folder=${Array[-1]}
        Repository="${Array[-2]}/${Array[-1]}"
        RepositoryDate=$(curl -s "https://api.github.com/repos/$Repository/commits?path=&page=1&per_page=1" | jq -r '.[0].commit.committer.date')
        Email=$(curl -s "https://api.github.com/repos/$Repository/commits?path=&page=1&per_page=1" | jq -r '.[0].commit.committer.email')

        if [ "$Date" != "$RepositoryDate" ]; then

            echo "Syncing $URL -> $Directory"

            cd /usr/local/goadmio/tmp

            git clone $URL
            rsync -azlh /usr/local/goadmio/tmp/$Folder/ $Directory/
            sudo rm -rf /usr/local/goadmio/tmp/$Folder

            sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/github.db "UPDATE Github SET Date='$RepositoryDate' where GithubID='$GithubID'"

        fi

    done

    exit 1

fi

if [[ $@ = *"--script"* ]]; then

    IFS='/' read -r -a Array <<<"$URL"

    ScriptName="${Array[3]}/${Array[4]}"

    File=$(echo "${Array[3]}-${Array[4]}" | tr '[:upper:]' '[:lower:]')

    if sudo test -f "$File.tar.gz" ; then

        echo "File $File.tar.gz Already Exists."

        exit 1

    fi

    sudo rm -rf $File
    sudo mkdir $File

    git clone $URL $File

    # if sudo test -f "$File/index.php"  || sudo test -f "$File/public/index.php" ; then

    # if sudo test -f "$File/composer.json" ; then

    #	cd $File
    #	composer install
    #	cd ..

    # fi

    sudo tar -cpzf $File.tar.gz $File
    sudo rm -rf $File

    Content=$(sudo wget -qO- "$URL" | sed ':a;N;$!ba;s/\n/ /g')
    Description=$(echo "$Content" | grep -oE '<p class="f4 my-3">.*</p>' | sed 's/<p class="f4 my-3">//' | sed 's/<\/p>//' | sed -e 's/^[ \t]*//g')
    ScriptVersion=$(echo "$Content" | grep -oE "\/releases\/tag\/[a-z0-9\.]+" | sed 's/\/releases\/tag\///')

    echo "\$ScriptName=\"$ScriptName\";"
    echo "\$ScriptFile=\"$File\";"
    echo "\$ScriptLanguage=\"English\";"
    echo "\$ScriptVersion=\"$ScriptVersion\";"
    echo "\$Category=\"\";"
    echo "\$Description=\"$Description\";"
    echo "\$URL=\"https://script.goadmio.com/$File.tar.gz\";"
    echo "\$GithubURL=\"$URL\";"
    echo "\$Sql = \"INSERT INTO Script (ScriptName,ScriptFile,ScriptLanguage,ScriptVersion,Category,Description,URL) VALUES ('\$ScriptName','\$ScriptFile','\$ScriptLanguage','\$ScriptVersion','\$Category','\$Description','\$URL')\";"
    echo "SQL(\$Sql);"
    echo ""

    ScriptFile="script.txt"

    echo "\$ScriptName=\"$ScriptName\";" >>$ScriptFile
    echo "\$ScriptFile=\"$File\";" >>$ScriptFile
    echo "\$ScriptLanguage=\"English\";" >>$ScriptFile
    echo "\$ScriptVersion=\"$ScriptVersion\";" >>$ScriptFile
    echo "\$Category=\"$2\";" >>$ScriptFile
    echo "\$Description=\"$Description\";" >>$ScriptFile
    echo "\$URL=\"https://script.goadmio.com/$File.tar.gz\";" >>$ScriptFile
    echo "\$GithubURL=\"$URL\";" >>$ScriptFile
    echo "\$Sql = \"INSERT INTO Script (ScriptName,ScriptFile,ScriptLanguage,ScriptVersion,Category,Description,URL) VALUES ('\$ScriptName','\$ScriptFile','\$ScriptLanguage','\$ScriptVersion','\$Category','\$Description','\$URL')\";" >>$ScriptFile
    echo "SQL(\$Sql);" >>$ScriptFile
    echo "" >>$ScriptFile

    # else

    #	echo "File index.php Not Exists."

    # fi

    exit 1

fi

if sudo test -d "$Directory" ; then

    IFS='/' read -r -a Array <<<"$URL"

    Folder=${Array[-1]}
    Repository="${Array[-2]}/${Array[-1]}"

    IFS='/' read -r -a DirectoryArray <<<"$Directory"
    Domain=${DirectoryArray[2]}
    Username=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select Username from Site where Domain='$Domain'")

    if [ "$Folder" != "" ]; then

        if [[ $@ = *"--progress"* ]]; then
            echo "Download in progress, Please wait..."
            echo "15"
        fi

        sudo mkdir -p $Directory
        cd $Directory

        sudo rm -rf .git
        sudo rm -rf .gitignore
        sudo rm -rf .gitattributes

        git clone $URL --depth 1 .

        RepositoryDate=$(curl -s "https://api.github.com/repos/$Repository/commits?path=&page=1&per_page=1" | jq -r '.[0].commit.committer.date')
        Email=$(curl -s "https://api.github.com/repos/$Repository/commits?path=&page=1&per_page=1" | jq -r '.[0].commit.committer.email')
        echo "Last Updated: $RepositoryDate"
        echo "Email: $Email"

        if [[ $@ = *"--progress"* ]]; then
            echo "The download has completed successfully, Last Updated: $RepositoryDate, Email: $Email..."
            echo "100"
        fi

        sudo screen -d -m bash -c '/go/fix'

        echo "Github files ($Folder) downloaded successfully"

        sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/github.db "INSERT INTO Github (URL,Directory,Date,Username,Sync) VALUES ('$URL','$Directory','$RepositoryDate','$Username','$Sync')"

        sudo /go/sendmail "Repository: $Repository" "Your Repository $Repository has been downloaded by $Domain.\n\nBest regards,\nGoAdmio Team\nwww.goadmio.com" "Repository"
        sudo /go/sendmail "Repository: $Repository" "Your Repository $Repository has been downloaded by $Domain.\n\nBest regards,\nGoAdmio Team\nwww.goadmio.com" "Repository"

    fi

    # github https://github.com/justmarkham/pandas-videos /home/goadmio.com/www
    # curl -s "https://api.github.com/repos/justmarkham/pandas-videos/commits?path=&page=1&per_page=1" | jq -r '.[0].commit.committer.date'

else

    echo "Directory $Directory not Exists."

fi
