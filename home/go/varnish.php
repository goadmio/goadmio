<?php
include "navigator.php";

if ($Action=="")
{
$Status=SSH ("/usr/bin/sudo /go/varnish status",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>$Status</div>";

}


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


if ($Action!="")
{

	if ($DemoPassword!="")
	{
	echo Error("This functionality is not available in demo mode.");
	exit;
	}


	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/varnish $Action'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if ($Action=="disable")
	{
	echo Error("Varnish is currently disabled.");
	}
	else
	{
	echo Error("Varnish is currently enabled.");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;
}




	Echo "

	<div class=UnderTitle>
	<b>{$LNG['WhatIsVarnishCache']}</b>
	<br>
	<br>
	{$LNG['VarnishDescription']}
	</div>
	
	<br>
	";
	
	if (stristr($Status,"disabled"))
	{
	echo "
	<div id=DivSubmit class=DivSubmit>
	<input type=button value='Enable' onclick=\"Load('$CurrentFileName?Action=enable')\" Class=InputButton>
	</div>
	";
	}
	else
	{
	echo "
	<div id=DivSubmit class=DivSubmit>
	<input type=button value='Disable' onclick=\"Load('$CurrentFileName?Action=disable')\" Class=InputButton>
	</div>
	";
	}

?>
