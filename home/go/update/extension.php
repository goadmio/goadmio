<?php

$OS=trim(file_get_contents("/usr/local/goadmio/linux/os.db"));

SQL("DELETE FROM Extension");

$Name="BCMath";
$Extension="bcmath";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Brotli";
$Extension="brotli";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="cURL";
$Extension="curl";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="dBase";
$Extension="dbase";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="dba";
$Extension="dba";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="dom";
$Extension="dom";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="igbinary";
$Extension="igbinary";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="FileInfo";
$Extension="fileinfo";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="FTP";
$Extension="ftp";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="GD Graphics Library";
$Extension="gd";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="GNU Multiple Precision";
$Extension="gmp";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);



$Name="Gettext";
$Extension="gettext";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="iconv";
$Extension="iconv";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Imagick";
$Extension="imagick";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="Intl";
$Extension="intl";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);




$Name="IMAP";
$Extension="imap";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="InterBase";
$Extension="interbase";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="LDAP";
$Extension="ldap";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="mailparse";
$Extension="mailparse";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="MBstring";
$Extension="mbstring";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="Mcrypt";
$Extension="mcrypt";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Memcached";
$Extension="memcached";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="msgpack";
$Extension="msgpack";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);



$Name="MS-SQL";
$Extension="mssql";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="MySQL";
$Extension="mysql";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Ncurses";
$Extension="ncurses";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="ODBC";
$Extension="odbc";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="OpenSSL";
$Extension="openssl";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="PDO";
$Extension="pdo";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Phalcon";
$Extension="phalcon";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="POSIX";
$Extension="posix";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="PostgreSQL";
$Extension="pgsql";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Pspell";
$Extension="pspell";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="pcntl";
$Extension="pcntl";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="pdo_mysql";
$Extension="pdo_mysql";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="pdo_pgsql";
$Extension="pdo_pgsql";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="pdo_sqlite";
$Extension="pdo_sqlite";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="recode";
$Extension="recode";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="soap";
$Extension="soap";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="sodium";
$Extension="sodium";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="SNMP";
$Extension="snmp";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="SimpleXML";
$Extension="simplexml";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Sockets";
$Extension="sockets";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="SSH2";
$Extension="ssh2";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="SQLite";
$Extension="sqlite3";
$Required="1";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="WDDX";
$Extension="wddx";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);


$Name="XML (Xpath)";
$Extension="xml";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="XML-RPC";
$Extension="xmlrpc";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="YAZ";
$Extension="yaz";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="ZIP";
$Extension="zip";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

$Name="Zlib";
$Extension="zlib";
$Required="";
$Sql = "INSERT INTO Extension (Name,Extension,Required) VALUES ('$Name','$Extension','$Required')";
SQL($Sql);

	

?>