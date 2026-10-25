<?php
include "nav.php";
$Buttons="";
include "title.php";

$SiteID=$_REQUEST['SiteID'];
$Password=ValidatePassword($_REQUEST['Password']);
$TXTRecord=$_REQUEST['TXTRecord'];

if ($_REQUEST['Action']=="Reset")
{

	$Sql = "UPDATE Site SET VisitorNo=0,RefererUrl='',TargetUrl=''";
	$Result = SQL($Sql);
	
}


if ($_REQUEST['Domain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);

		$Error=SSH ("whois $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("<pre>Whois: $Domain\n$Error</pre>");
		
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
		
exit;
}


	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;


?>