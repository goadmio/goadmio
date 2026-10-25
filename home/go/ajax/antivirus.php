<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";



$Domain=ValidateDomain($_REQUEST['Domain']);
$N=$_REQUEST['N'];


if ($Domain!="")
{

	if ($N==1)
	{
	$Error=SSH ("echo '' > /usr/local/goadmio/{$Domain}.av",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c 'clamscan --infected --remove --recursive /home/$Domain>/usr/local/goadmio/{$Domain}.av'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo "";
	}
	else
	{
	$Content=@file_get_contents("/usr/local/goadmio/{$Domain}.av");
	$Content=trim($Content);
	$Content=str_replace("\n","<br>",$Content);
	echo $Content;
	}
	
}


?>