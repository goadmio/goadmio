<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$ServerIP=ValidateUsername($_REQUEST['ServerIP']);


for ($ID=101;$ID<=9999;$ID++)
{

	$Exists=0;
	$Result = SQL("select ID from VPS where ServerIP='$ServerIP' and ID='$ID'");
	foreach ($Result as $Row)
	{
		$Exists=1;
	}
	
	if ($Exists==0)
	{
	break;
	}
	
	
	
}

echo "$ID";


?>