<?php
session_start();

header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$Domain=ValidateDomain($_REQUEST['Domain']);

if ($Domain!="")
{

	$Result = SQL("select Email from Mail where DefaultAddress=1 and Domain='$Domain'");
	foreach ($Result as $Row)
	{
	$Email=$Row['Email'];
	}

}

echo $Email;

?>