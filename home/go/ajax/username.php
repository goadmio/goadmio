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
	$Result = SQL("SELECT Username FROM Site where Domain='$Domain'");
	foreach ($Result as $Row)
	{
	$Username=$Row['Username'];
	}
	
	echo $Username;
}

?>