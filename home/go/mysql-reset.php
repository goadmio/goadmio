<?php
include "nav.php";
$Buttons="";
include "title.php";

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$Password=ValidatePassword($_REQUEST['Password']);

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
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