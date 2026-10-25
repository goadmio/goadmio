<?php
include "nav.php";
$Buttons="";
include "title.php";


if ($_REQUEST['Action']=="Check")
{
	
	$Content = file_get_contents("/usr/local/goadmio/tmp/php-fpm.log");
	if (trim($Content)=="")
	{
		echo Error("PHP-FPM restarted successfully.");
	}
	else
	{
		echo Error($Content);
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
}


if ($_REQUEST['Action']=="RestartFPM")
{


	echo Error("Restarting PHP-FPM, Please wait...");
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/fpm reload > /usr/local/goadmio/tmp/php-fpm.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	
exit;
}
	
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;


?>
