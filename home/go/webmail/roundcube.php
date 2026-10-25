<?php
session_start();

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$MailID=$_REQUEST['MailID'];

$Result = SQL("select * from Mail where MailID='$MailID'");
foreach ($Result as $Row)
{ 

	$Pass=$Row['Pass'];
	$Email=$Row['Email'];
	$EmailArray=explode("@",$Row['Email']);

}

$Result = SQL("select * from Mail where Email='{$_SESSION['SessionEmail']}' and Pass='{$_SESSION['SessionEmailPass']}'");
foreach ($Result as $Row)
{
	$Admin=$Row['Admin'];
	$AdminEmailArray=explode("@",$_SESSION['SessionEmail']);
	
}

if ($Admin!=1 or $EmailArray[1]!=$AdminEmailArray[1])
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
header("Location: roundcube/login.php?T=$T");

?>