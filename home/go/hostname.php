<?php

include "nav.php";
if (file_exists("/etc/hostname.bak"))
{
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Restore&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
}
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['HostnameTitle']}</div>";

$Hostname=$_REQUEST['Hostname'];

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";

	exit;
	}

if ($_REQUEST['Action']=="Restore")
{

	$Error=SSH ("/usr/bin/sudo /go/hostname restore",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
exit;
}


if ($_REQUEST['Hostname']!="")
{
	$Error=SSH ("/usr/bin/sudo /go/hostname $Hostname",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=Error($Error);
}

$Hostname=gethostname();
$Reverse=SSH ("host $IPv4",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
$ReverseArray=explode(" ",$Reverse);
$ReverseDNS=trim($ReverseArray[4]);
$ReverseDNS=trim($ReverseDNS,".");

if ($ReverseDNS!=$Hostname)
{
$HostnameError="<br><span style='color:var(--red);font-size:16px'>Reverse DNS Mismatch ($ReverseDNS)</span>";
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;

?>