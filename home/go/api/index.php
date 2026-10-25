<?php

header('Content-Type: text/html; charset=UTF-8');

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Action=$_REQUEST['Action'];
$APIKey=$_REQUEST['APIKey'];
$Command=$_REQUEST['Command'];
$Email=trim($_REQUEST['Email']);
$Password=trim($_REQUEST['Password']);

if ($Action=="" and $APIKey=="")
{
	header("Location: api.php");
	exit;
}


if ($Action=="Renew")
{
	RenewVPS();
	exit;
}

if (strlen($APIKey)!=50) 
{
echo "Invalid API Key.";
exit;
}

$Sql = "select * from Config where ConfigID=1";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$SSHPassword=$Row['SSHPassword'];
}

$Success=0;
$Sql = "select APIKey from API where APIKey='$APIKey' and Command=''";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$Success=1;
}

if ($Success!=1)
{
echo "Invalid API Key.";
exit;
}

if ($Command!="")
{
	
	if (!str_starts_with($Command,"/go/")) 
	{
	$Command="/go/$Command";
	}

	$Error=SSH ($Command,$SSHUsername,$SSHPassword);
	echo "$Error";
	
}

?>