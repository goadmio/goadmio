<?php

$OS=trim(file_get_contents("/usr/local/goadmio/linux/os.db"));

SQL("DELETE FROM Extension");

$Name="BCMath";
$Extension="bcmath";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);

$Name="Brotli";
$Extension="brotli";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="cURL";
$Extension="curl";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="dBase";
$Extension="dbase";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="dba";
$Extension="dba";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="dom";
$Extension="dom";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="igbinary";
$Extension="igbinary";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="FileInfo";
$Extension="fileinfo";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="FTP";
$Extension="ftp";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="GD Graphics Library";
$Extension="gd";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="GNU Multiple Precision";
$Extension="gmp";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);




$Name="Gettext";
$Extension="gettext";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="iconv";
$Extension="iconv";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Imagick";
$Extension="imagick";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="Intl";
$Extension="intl";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);





$Name="IMAP";
$Extension="imap";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="InterBase";
$Extension="interbase";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="LDAP";
$Extension="ldap";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="mailparse";
$Extension="mailparse";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="MBstring";
$Extension="mbstring";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="Mcrypt";
$Extension="mcrypt";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Memcached";
$Extension="memcached";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="msgpack";
$Extension="msgpack";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);




$Name="MS-SQL";
$Extension="mssql";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="MySQL";
$Extension="mysql";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Ncurses";
$Extension="ncurses";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="ODBC";
$Extension="odbc";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="OpenSSL";
$Extension="openssl";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="PDO";
$Extension="pdo";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Phalcon";
$Extension="phalcon";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="POSIX";
$Extension="posix";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="PostgreSQL";
$Extension="pgsql";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Pspell";
$Extension="pspell";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="pcntl";
$Extension="pcntl";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="pdo_mysql";
$Extension="pdo_mysql";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="pdo_pgsql";
$Extension="pdo_pgsql";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="pdo_sqlite";
$Extension="pdo_sqlite";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="recode";
$Extension="recode";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="soap";
$Extension="soap";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="sodium";
$Extension="sodium";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="SNMP";
$Extension="snmp";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="SimpleXML";
$Extension="simplexml";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Sockets";
$Extension="sockets";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="SSH2";
$Extension="ssh2";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);



$Name="SQLite";
$Extension="sqlite3";
$Required="1";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="WDDX";
$Extension="wddx";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="XML (Xpath)";
$Extension="xml";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="XML-RPC";
$Extension="xmlrpc";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="YAZ";
$Extension="yaz";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="ZIP";
$Extension="zip";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


$Name="Zlib";
$Extension="zlib";
$Required="";
SQL("INSERT INTO Extension (Name,Extension,Required) VALUES (?,?,?)", [$Name, $Extension, $Required]);


	

?>