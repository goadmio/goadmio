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

setcookie ("HordeLogin","1",time() + (86400 * 30), "/");
setcookie ("HordeEmail",$Email,time() + (86400 * 30), "/");
setcookie ("HordePassword",$Pass,time() + (86400 * 30), "/");


if ($_SERVER['HTTPS']=="on")
{
$URL = "https://{$_SERVER['HTTP_HOST']}/horde/horde.php";
}
else
{
$URL = "http://{$_SERVER['HTTP_HOST']}/horde/horde.php";
}


header("Location: $URL");
	

?>