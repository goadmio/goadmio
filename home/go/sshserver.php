<?php
include "nav.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Action']=="Restart")
{

	$Error=SSH ("/usr/bin/sudo /go/ssh restart",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	if ($Error=="")
	{
	echo Error("SSHD restarted successfully.");
	}
	else
	{
	echo Error("$Error");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	
exit;
}


	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
	

?>
