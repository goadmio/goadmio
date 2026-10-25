<?php

include "nav.php";
$Buttons="";
include "title.php";

$AdminEmail=$_REQUEST['AdminEmail'];
$CronEmail=$_REQUEST['CronEmail'];
$AdminMobile=$_REQUEST['AdminMobile'];

$ConfigPassword=trim($_REQUEST['ConfigPassword']);

$WAInstanceID=$_REQUEST['WAInstanceID'];
$WAAPIKey=$_REQUEST['WAAPIKey'];

$SSHAlert=intval($_REQUEST['SSHAlert']);
$IMAPAlert=intval($_REQUEST['IMAPAlert']);
$Junk=intval($_REQUEST['Junk']);
$Welcome=intval($_REQUEST['Welcome']);
$Heal=intval($_REQUEST['Heal']);
$PermitRootLogin=intval($_REQUEST['PermitRootLogin']);
$RemoteMariaDB=intval($_REQUEST['RemoteMariaDB']);

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";

		exit;
	}


if ($_REQUEST['AdminEmail']!="")
{
	
	SQL("UPDATE Config SET AdminEmail='$AdminEmail',CronEmail='$CronEmail',AdminMobile='$AdminMobile',WAInstanceID='$WAInstanceID',WAAPIKey='$WAAPIKey',IMAPAlert='$IMAPAlert',Junk='$Junk',Heal='$Heal',PermitRootLogin='$PermitRootLogin',RemoteMariaDB='$RemoteMariaDB',Welcome='$Welcome'");

	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/basic'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
		$AdminEmail=$Row['AdminEmail'];
		$CronEmail=$Row['CronEmail'];
		$AdminMobile=$Row['AdminMobile'];
		
		$WAInstanceID=$Row['WAInstanceID'];
		$WAAPIKey=$Row['WAAPIKey'];

		if ($Row['SSHAlert']==1)
		{
		$SSHAlertChecked="checked";
		}
		
		if ($Row['IMAPAlert']==1)
		{
		$IMAPAlertChecked="checked";
		}
		
		if ($Row['Junk']==1)
		{
		$JunkChecked="checked";
		}
		
		if ($Row['Heal']==1)
		{
		$HealChecked="checked";
		}

		if ($Row['PermitRootLogin']==1)
		{
		$PermitRootLoginChecked="checked";
		}
		
		if ($Row['RemoteMariaDB']==1)
		{
		$RemoteMariaDBChecked="checked";
		}
		
		if ($Row['Welcome']==1)
		{
		$WelcomeChecked="checked";
		}
		
	}
	
	if ($AdminMobile=="")
	{
	$AdminMobile=CallCode();
	}

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>