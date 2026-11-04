<?php
include "nav.php";
$Buttons = "";
include "title.php";

$AdminEmail     = trim((string)($_REQUEST['AdminEmail']     ?? ''));
$CronEmail      = trim((string)($_REQUEST['CronEmail']      ?? ''));
$AdminMobile    = trim((string)($_REQUEST['AdminMobile']    ?? ''));
$WAInstanceID   = trim((string)($_REQUEST['WAInstanceID']   ?? ''));
$WAAPIKey       = trim((string)($_REQUEST['WAAPIKey']       ?? ''));
$ConfigPassword = trim((string)($_REQUEST['ConfigPassword'] ?? ''));

$SSHAlert        = intval($_REQUEST['SSHAlert']        ?? 0);
$IMAPAlert       = intval($_REQUEST['IMAPAlert']       ?? 0);
$Junk            = intval($_REQUEST['Junk']            ?? 0);
$Welcome         = intval($_REQUEST['Welcome']         ?? 0);
$Heal            = intval($_REQUEST['Heal']            ?? 0);
$PermitRootLogin = intval($_REQUEST['PermitRootLogin'] ?? 0);
$RemoteMariaDB   = intval($_REQUEST['RemoteMariaDB']   ?? 0);

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";

		exit;
	}


if ($_REQUEST['AdminEmail']!="")
{
	
	SQL("UPDATE Config SET AdminEmail=?,CronEmail=?,AdminMobile=?,WAInstanceID=?,WAAPIKey=?,IMAPAlert=?,Junk=?,Heal=?,PermitRootLogin=?,RemoteMariaDB=?,Welcome=?", [$AdminEmail,$CronEmail,$AdminMobile,$WAInstanceID,$WAAPIKey,$IMAPAlert,$Junk,$Heal,$PermitRootLogin,$RemoteMariaDB,$Welcome]);

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