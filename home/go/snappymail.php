<?php
session_start();

include("include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);
$Domain = preg_replace("/^go\./","",$Domain);
$Domain = preg_replace("/^webmail\./","",$Domain);

$MailID=$_REQUEST['MailID'];

$Result = SQL("select * from Mail where MailID='$MailID'");
foreach ($Result as $Row)
{ 

	$Pass=$Row['Pass'];
	$Email=$Row['Email'];
	$EmailArray=explode("@",$Row['Email']);
	

}

if ($EmailArray[1]!=$_SESSION['SessionUsername'] and $_SESSION['SessionUsername']!="root")
{
echo "Please login...";
exit;
}


// Enable SnappyMail API
$_ENV['SNAPPYMAIL_INCLUDE_AS_API'] = true;
require_once '/usr/local/goadmio/home/go/webmail/snappymail/index.php';;
$ssoHash = \RainLoop\Api::CreateUserSsoHash($Email, $Pass);
header('Location: webmail/snappymail?sso&hash=' . $ssoHash);




?>