<?php
include "nav.php";
$Buttons="";
include "title.php";


if ($_REQUEST['Domain']!="")
{
	$Domain=ValidateDomain($_REQUEST['Domain']);

	$Error=SSH ("ping -c 1 $Domain | gawk -F'[()]' '/PING/{print $2}'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("<pre>Ping: $Domain\n$Error</pre>");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
?>