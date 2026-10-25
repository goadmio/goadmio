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


// Enable RainLoop Api and include index file 
$_ENV['RAINLOOP_INCLUDE_AS_API'] = true;
include '/usr/local/goadmio/home/go/webmail/rainloop/index.php';
$ssoHash = \RainLoop\Api::GetUserSsoHash($Email, $Pass);
header("Location: webmail/rainloop/?sso&hash=".$ssoHash);

?>