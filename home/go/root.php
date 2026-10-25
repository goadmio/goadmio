<?php
include "nav.php";
$Buttons="";
include "title.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

$Password=ValidatePassword($_REQUEST['Password']);

if ($Password!="")
{

	if ($DemoPassword!="")
	{
	echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
	exit;
	}

	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo /go/root '$Password'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);

	if ($_SESSION['SessionUsername']=="root" or $_SESSION['SessionSSHUsername']=="root")
	{
		$_SESSION['SessionPassword']=$Password;
		$_SESSION['SessionSSHPassword']=$Password;
		SQL("UPDATE User SET Username='root',Password='".md5($Password)."' where UserID=1");
	}

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	

	
	exit;
}


	$Content=DesignCode($Content,"ROOT Content");
	echo $Content;


?>
