<?php
session_start();

session_unset();
session_destroy();
unset($_SESSION['SessionUsername'],$_SESSION['SessionUserID'],$_SESSION['SessionPassword'],$_SESSION['SessionUserGroup'],$_SESSION['SessionFullName'],$_SESSION['SessionUserType'],$_SESSION['ResetPassword'],$_SESSION['SessionTIP']);

setcookie ("CookiesUserID","",time() -3600);
setcookie ("CookiesUserGroup","",time() -3600);
setcookie ("CookiesUsername","",time() -3600);
setcookie ("CookiesPassword","",time() -3600);
setcookie ("CookiesUserType","",time() -3600);

?>