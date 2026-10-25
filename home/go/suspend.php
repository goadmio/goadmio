<?php
include "nav.php";
$Buttons="";
include "title.php";

$Suspend=$_REQUEST['Suspend'];
$Unsuspend=$_REQUEST['Unsuspend'];
$SiteID=$_REQUEST['SiteID'];
$Action=$_REQUEST['Action'];
$CheckList=$_REQUEST['CheckList'];

$UserNo=RowCount("select * from Site where SiteID>=1");
    
$Domain=ValidateDomain($_REQUEST['Domain']);
	
If ($Suspend==1)
{
	if ($DemoPassword!="")
	{
		if (stristr($Domain,"w75.net") or stristr($Domain,"demo."))
		{
		echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
		}
	}
	
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/suspend $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	echo Error("Account $Domain has been suspended.");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}
	

If ($Unsuspend==1)
{
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/unsuspend $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	echo Error("Account $Domain has been Unsuspended.");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}

	include "search.php";

	$Header=DesignCode($Header,"$Control (Header)");
	echo $Header;
	


	$Table="Site";$Field="Trash=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";


	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$SiteID=$Row['SiteID'];
		$ID=$Row['SiteID'];
		
		$Domain=$Row['Domain'];

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}

		if ($Row['Suspend']==1)
		{
		$TDColor="TdEr";
		}
		
			
		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

		$Status="Active";
		if ($Row['Trash']==1)
		{
		$Status="Terminated";
		}
		elseif ($Row['Suspend']==1)
		{
		$Status="Suspended";
		}
		elseif ($Row['Unpublish']==1)
		{
		$Status="Unpublished";
		}
				
		if ($Row['SpaceUsed']>$Row['DiskSpace'] and $Row['DiskSpace']!=0)
		{
		$Reason="Disk Quota Exceeded";
		}
		elseif ($Row['BandwidthUsed']>$Row['Bandwidth'] and $Row['DiskSpace']!=0)
		{
		$Reason=$LNG['BandwidthLimitExceeded'];
		}
		else
		{
		$Reason="";
		}
		
		echo DesignCode($Loop,"$Control (Loop)");

	$X++;
	}
	
	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;
		
?>