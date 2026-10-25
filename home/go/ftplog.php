<?php

include "nav.php";
$Buttons="";
include "title.php";

$ServiceControl=$_REQUEST['ServiceControl'];$CTabNo=$_REQUEST['CTabNo'];$Edit=$_REQUEST['Edit'];$Delete=$_REQUEST['Delete'];
$Step=$_REQUEST['Step'];$SortBy=$_REQUEST['SortBy'];$Badwords=$_REQUEST['Badwords'];$FormSearch=$_REQUEST['FormSearch'];
$FilterSql=trim($_REQUEST['FilterSql']);
$SearchFor=trim($_REQUEST['SearchFor']);
$Name=$_REQUEST['Name'];

$Direction=$_REQUEST['Direction'];
$ConditionIcon=$_REQUEST['ConditionIcon'];
$Gmail=$_REQUEST['Gmail'];
$ClientID=$_REQUEST['ClientID'];
$ClientSecret=$_REQUEST['ClientSecret'];

$EnDeveloperName=$_REQUEST['EnDeveloperName'];
$ArDeveloperName=$_REQUEST['ArDeveloperName'];
$CenterMap=$_REQUEST['CenterMap'];
$Skip=$_REQUEST['Skip'];
$CityID=$_REQUEST['CityID'];
$DistrictID=$_REQUEST['DistrictID'];

$Directory=ValidateDirectory($_REQUEST['Directory']);
$Service=$_REQUEST['Service'];

$SMS=$_REQUEST['SMS'];

$FtplogID=$_REQUEST['FtplogID'];



		$Error=SSH ("/usr/bin/sudo /go/ftplog $DBPassword",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		include "search.php";

		$Header=DesignCode($Header,"$Control (Header)");
		echo $Header;

		$Table="Ftplog";$Field="FtplogID>=1";
		$DefaultSortBy="TimeStamp";
		$DefaultDirection="DESC";
		include "include/sql.php";
	

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{

			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}

			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			if ($Row['TransferTime']>1)
			{
			$Seconds="Seconds";
			}
			else
			{
			$Seconds="Second";
			}
			
			$FileSize=FormatSize($Row['FileSize']);
			
			$Flag="";
			if (strlen($Row['Country'])==2)
			{
			$Flag="<img src='image/flag/24x24/".strtolower($Row['Country']).".png' title='{$Row['Country']}' style='vertical-align:middle;padding:5px'>";
			}
			
			$Organization="";
			if (trim($Row['Organization'])!="")
			{
			$Organization="<hr>{$Row['Organization']}";
			}
			
			echo DesignCode($Loop,"$Control (Loop)");
		
		$X++;
		}
		

		$Footer=DesignCode($Footer,"$Control (Footer)");
		echo $Footer;
	
		
?>