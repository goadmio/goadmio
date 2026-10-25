<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8');

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "Sorry, You Are Not Allowed to Access This Page";
	exit;
}

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$Command=$_REQUEST['Command'];
$Value=$_REQUEST['Value'];

if (stristr($Command,"keepalive_timeout"))
{
$Value=preg_replace("/[^0-9\-]/","", $Value);

	if (trim($Value==""))
	{
	$Value="65";
	}
	else
	{
	$Value=intval($Value);
	}
	
	if ($Value<=0)
	{
	$Value="0";
	}
	elseif ($Value>=120)
	{
	$Value="120";
	}
	else
	{
	$Value=trim($Value);
	}
	
}
elseif (stristr($Command,"gzip"))
{

	if ($Value=="1" or stristr($Value,"n"))
	{
	$Value="on";
	}
	else
	{
	$Value="off";
	}
}
else
{
exit;
}

$Error=SSH ("$Command $Value",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

if (stristr($Error,"!"))
{
echo $Error;
}
else
{
echo $Value;
}


?>