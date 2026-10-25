<?php
session_start();

$FTPUsername=$_SESSION['SessionUsername'];

header("Content-Disposition: attachment; filename=$FTPUsername.bat");
header("Pragma: no-cache");
header("Expires: 0");

echo "%SystemRoot%\\explorer.exe \"ftp://$FTPUsername@$FTPUsername/www\"";
?>