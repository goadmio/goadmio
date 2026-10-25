<?php



include "navigator.php";
$Buttons="";
include "title.php";


$DefaultWebsitePageCode=$_REQUEST['DefaultWebsitePageCode'];
$AccountSuspendedCode=$_REQUEST['AccountSuspendedCode'];
$DiskQuotaExceededCode=$_REQUEST['DiskQuotaExceededCode'];
$BandwidthLimitExceededCode=$_REQUEST['BandwidthLimitExceededCode'];
$AccountUnpublishedCode=$_REQUEST['AccountUnpublishedCode'];
$HostingExpiredCode=$_REQUEST['HostingExpiredCode'];

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{
		echo "
		You Are Not Allowed to Access This Page
		";

	exit;
	}


if ($DefaultWebsitePageCode!="" or $AccountSuspendedCode!="" or $AccountUnpublishedCode!="")
{

	$Result = SQL("UPDATE Template Set Code='$DefaultWebsitePageCode' where Name='Default Website Page'");
	$Result = SQL("UPDATE Template Set Code='$AccountSuspendedCode' where Name='Account Suspended'");
	$Result = SQL("UPDATE Template Set Code='$DiskQuotaExceededCode' where Name='Disk Quota Exceeded'");
	$Result = SQL("UPDATE Template Set Code='$BandwidthLimitExceededCode' where Name='Bandwidth Limit Exceeded'");
	$Result = SQL("UPDATE Template Set Code='$AccountUnpublishedCode' where Name='Account Unpublished'");
	$Result = SQL("UPDATE Template Set Code='$HostingExpiredCode' where Name='Hosting Expired'");
	
	$Error=SSH ("/usr/bin/sudo /go/template",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}

	$Result = SQL("select * from Template where TemplateID>=1");
	foreach ($Result as $Row)
	{
	
		if ($Row['Name']=="Default Website Page")
		{
		$DefaultWebsitePageCode=$Row['Code'];
		}
	
		if ($Row['Name']=="Account Suspended")
		{
		$AccountSuspendedCode=$Row['Code'];
		}

		if ($Row['Name']=="Disk Quota Exceeded")
		{
		$DiskQuotaExceededCode=$Row['Code'];
		}

		if ($Row['Name']=="Bandwidth Limit Exceeded")
		{
		$BandwidthLimitExceededCode=$Row['Code'];
		}

		if ($Row['Name']=="Account Unpublished")
		{
		$AccountUnpublishedCode=$Row['Code'];
		}

		if ($Row['Name']=="Hosting Expired")
		{
		$HostingExpiredCode=$Row['Code'];
		}
		
	}
	

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div <div class='TitleB {$Dir}TitleB'>{$LNG['DefaultWebsitePage']}</div>
	
	<div class=DivTextarea>
	<textarea name='DefaultWebsitePageCode' id='DefaultWebsitePageCode' cols=112 style='width:100%;'>$DefaultWebsitePageCode</textarea>	
	</div>
	
	<div <div class='TitleB {$Dir}TitleB'>{$LNG['AccountSuspended']}</div>
	
	<div class=DivTextarea>
	<textarea name='AccountSuspendedCode' id='AccountSuspendedCode' cols=112 style='width:100%'>$AccountSuspendedCode</textarea>
	</div>

	<div <div class='TitleB {$Dir}TitleB'>{$LNG['DiskQuotaExceeded']}</div>
	
	<div class=DivTextarea>
	<textarea name='DiskQuotaExceededCode' id='DiskQuotaExceededCode' cols=112 style='width:100%'>$DiskQuotaExceededCode</textarea>
	</div>
	
	<div <div class='TitleB {$Dir}TitleB'>{$LNG['BandwidthLimitExceeded']}</div>
	
	<div class=DivTextarea>
	<textarea name='BandwidthLimitExceededCode' id='BandwidthLimitExceededCode' cols=112 style='width:100%'>$BandwidthLimitExceededCode</textarea>
	</div>
		
	<div <div class='TitleB {$Dir}TitleB'>{$LNG['AccountUnpublished']}</div>
	
	<div class=DivTextarea>
	<textarea name='AccountUnpublishedCode' id='AccountUnpublishedCode' cols=112 style='width:100%'>$AccountUnpublishedCode</textarea>
	</div>

	<div <div class='TitleB {$Dir}TitleB'>{$LNG['HostingExpired']}</div>
	
	<div class=DivTextarea>
	<textarea name='HostingExpiredCode' id='HostingExpiredCode' cols=112 style='width:100%'>$HostingExpiredCode</textarea>
	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['Save']}' class=InputButton>
	</div>

	</form>
	";

?>