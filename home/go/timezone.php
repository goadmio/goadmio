<?php
include "nav.php";
$Buttons="";

$CurrentTime=date ("D j M Y g:i a");
$DefaultTimezone=date_default_timezone_get();

$Buttons="
<a href=\"javascript:Load('$CurrentFileName?Action=Update&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class='ButtonB {$Dir}ButtonB'>Update Time Zone Database</a>
";
include "title.php";

	if ($_REQUEST['Timezone']=="")
	{
		echo "
		<div class=NavigatorInfo>
		{$LNG['CurrentTime']}: $CurrentTime<span style='float:right'>$DefaultTimezone</span>
		</div>
		";
	}


$Timezone=$_REQUEST['Timezone'];

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
	
		";

	exit;
	}


if ($Action=="Update")
{		
$Error=SSH ("/usr/bin/sudo /go/dst",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("Time Zone Database has been updated");

echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;	
}


if ($_REQUEST['Timezone']!="")
{		
$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/timezone $Timezone'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("Local timezone has been set to $Timezone.");

echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;	
}

	$Timezone=date_default_timezone_get();

	$Checked=$Timezone;
	$Checked=str_replace("/","",$Checked);
	$Checked=str_replace("-","",$Checked);
	$Checked=str_replace(" ","",$Checked);


	$$Checked="selected";
	
	

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
	
?>
