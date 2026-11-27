<?php
include "nav.php";
$Buttons="";
include "title.php";

$Password=ValidatePassword($_REQUEST['Password']);

if ($_SESSION['SessionType']!="Root")
{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
}



if ($Password!="")
{

	$Error=SSH ("/usr/bin/sudo /go/mysqlreset $Password",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
	exit;
	
}

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>