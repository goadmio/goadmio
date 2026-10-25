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

	$Sql = "select Timezone from Site where Domain='$Domain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$Timezone=trim($Row['Timezone']);
	}

	
	date_default_timezone_set($Timezone);
	
}

echo "$Timezone|&nbsp;Current Time: ".date ("D j M Y g:i a");

?>