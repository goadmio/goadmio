#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    exec sudo -- /go/cache "$@"
fi

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

Domain=$1

CACHE() {
    Domain=$1

    if sudo test -d /home/$Domain/www ; then

        CacheTTL=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select CacheTTL from Site where Domain='$Domain'")
        CacheActive=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select CacheActive from Site where Domain='$Domain'")
        CacheLength=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select CacheLength from Site where Domain='$Domain'")
        CacheExclude=$(sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/site.db "select CacheExclude from Site where Domain='$Domain'")

        if [ "$CacheExclude" = "" ]; then
            CacheExclude="admin|/cp|login|sign|logout|forget|webmail|dashboard|ajax"
        else
            CacheExclude="admin|/cp|login|sign|logout|forget|webmail|dashboard|ajax|$CacheExclude"
        fi

        CacheExclude=$(echo "${CacheExclude//\//\\/}")
        CacheExclude=$(echo "${CacheExclude//./\\.}")

        sudo mkdir -p /home/$Domain/etc

        sudo cat <<EOF >/home/$Domain/etc/cache.php
<?php
GoCache($CacheTTL);
function GoCache(\$CacheTTL=86400)
{
    \$Domain = str_replace("www.", "", \$_SERVER["HTTP_HOST"]);
    \$Dir = "/var/cache/\$Domain";
	\$URL = (isset(\$_SERVER['HTTPS']) && \$_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://" . \$_SERVER['HTTP_HOST'] . \$_SERVER['REQUEST_URI'];
    \$File = md5(\$URL) . ".html";
    \$CacheFile = "{\$Dir}/{\$File}";

    \$CacheActive=$CacheActive;
    \$CacheLength=$CacheLength;

    if (\$CacheTTL==0)
    {
        return;
    }

    if (\$CacheActive==0)
    {
        return;
    }

	if (preg_match("/${CacheExclude}/",\$_SERVER["REQUEST_URI"])) 
    {
        return;
    }

    if (\$CacheLength!=0 and strlen(\$_SERVER["REQUEST_URI"])<=\$CacheLength)
    {
        return;
    }

    if (file_exists(\$CacheFile)) 
    {
        \$FileAge = time() - filemtime(\$CacheFile);
        if (\$FileAge <= \$CacheTTL) 
        {
            readfile(\$CacheFile);
            exit;
        } 

    }

    ob_start();
    register_shutdown_function(function() use (\$CacheFile) {
	
        \$Content = ob_get_contents();
        ob_end_clean();
		
		if (stristr(\$Content,"</html>") OR stristr(\$Content,"</body>"))
		{
			file_put_contents(\$CacheFile, \$Content);
		}

		echo \$Content;
		
    });

}
?>
EOF

        sudo chmod 777 /home/$Domain/etc/cache.php

    fi
}

if [ $# -eq 0 ] || [ "$Domain" = "all" ]; then

    cd /home
    for Domain in *; do
        CACHE "$Domain"
    done

else

    CACHE "$Domain"

fi
