<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
$CurrentFileName=basename ($_SERVER['PHP_SELF']);
include("include/function/function.php");
include "/usr/local/goadmio/include/config/config.php";

	$Error=SSH ("/usr/bin/sudo /go/update",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
	include "setup.php";
	
?>