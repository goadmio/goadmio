<?php
session_start();

include("include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

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

if ($Email=="" or $Pass=="")
{
	echo "Please Login.";
	exit;
}

setcookie ("CookiesRoundcubeEmail",$Email,0,"/","");
setcookie ("CookiesRoundcubePass",$Pass,0,"/","");

setcookie ("CookiesRoundcubeEmail",$Email,0,"/","",true);
setcookie ("CookiesRoundcubePass",$Pass,0,"/","",true);

$T=time();
header("Location: webmail/roundcube/login.php?T=$T");

?>