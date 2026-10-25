<?php
include "nav.php";
$Buttons="";
include "title.php";

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
	$Error=SSH ("/usr/bin/sudo /go/skeleton $Password",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;
}

$Content=DesignCode($Content,"ROOT Content");
echo $Content;


?>
