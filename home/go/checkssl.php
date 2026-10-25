<?php
include "nav.php";
$Buttons="";
include "title.php";


$SiteID=$_REQUEST['SiteID'];
$Action=$_REQUEST['Action'];

$UserNo=RowCount("select * from Site where SiteID>=1");
    
$Domain=ValidateDomain($_REQUEST['Domain']);
	
If ($Action=="Renew")
{
	include "access.php";
	
	$ProgressFile="ssl-$Domain.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/ssl $Domain --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("SSL installation for $Domain is running in the background. You can safely close this page.");
	echo Progress("Installing SSL for $Domain",$ProgressFile);
	
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

		$Renew=0;

		if ($Row['SSLExpiresOn']=="")
		{
		$ExpiresOn="-";
		}
		else
		{
		$Date=date ("Y-m-d");
		$SSLExpiresOn = date("D j M Y", strtotime($Row['SSLExpiresOn']));
		$DaysLeft=floor((strtotime($Row['SSLExpiresOn'])-strtotime($Date))/(60*60*24));

		$ExpiresOn="$SSLExpiresOn ($DaysLeft Days)";
		
			if ($DaysLeft<80)
			{
			$Renew=1;	
			}
		
		}

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



		echo DesignCode($Loop,"$Control (Loop)");

	$X++;
	}
	
	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;
		
?>