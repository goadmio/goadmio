<?php
session_start();

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Result = SQL("select * from Mail where Email='{$_SESSION['SessionEmail']}' and Pass='{$_SESSION['SessionEmailPass']}'");
foreach ($Result as $Row)
{
	$Success=1;
}

If ($Success!=1)
{
	echo Error("Session has been expired.");
	exit;
	
}

$Pass=addslashes($_REQUEST['Pass']);

$EmailArray=explode("@",$_SESSION['SessionEmail']);
$Domain=$EmailArray[1];

$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
	$SSHPassword=$Row['SSHPassword'];
}

$Email=$_SESSION['SessionEmail'];

if ($Email!="" AND $Pass!="" AND $Domain!="")
{
$Error=SSH ("/usr/bin/sudo /go/mail --email $Email --pass $Pass --domain $Domain --action edit",$SSHUsername,$SSHPassword);
echo Error($Error);
}

?>