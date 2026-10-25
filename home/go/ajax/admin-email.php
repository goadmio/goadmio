<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$Domain=ValidateDomain($_REQUEST['Domain']);


if ($Domain!="")
{

	$Content=SSH ("whois $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	$Content=strtolower($Content);
	$Content=str_replace("\r","</n>",$Content);
	$Content=str_replace("\n","</n>",$Content);

	preg_match("/admin email(.*?)<\/n>/i",$Content,$T);
	$AdminEmail=trim(strip_tags($T[1]));
	$AdminEmail=str_replace(":","",$AdminEmail);
	$AdminEmail=trim($AdminEmail);

	if (filter_var($AdminEmail, FILTER_VALIDATE_EMAIL)) 
	{
		echo $AdminEmail;
	}
	else
	{
		echo "info@$Domain";
	}

}



?>