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

$WS=@file_get_contents("/usr/local/goadmio/linux/ws.db");
$WS=trim($WS);

if ($_REQUEST['Action']=="Check")
{
	
	$Content = file_get_contents("/usr/local/goadmio/tmp/httpd.log");
	if (trim($Content)=="")
	{
		echo Error("$WS restarted successfully.");
	}
	else
	{
		echo Error($Content);
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
}

if ($_REQUEST['Action']=="RestartHTTPD")
{
	
	echo Error("Restarting $WS Web Server, Please wait...");
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/web > /usr/local/goadmio/tmp/httpd.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	exit;
	
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;
?>
