<?php
include "nav.php";
$Buttons= "<a href='javascript:Load(\"$CurrentFileName?Refresh=1&ControlID=$ControlID&Page=$Page\",\"$ControlID\")' class='ButtonB {$Dir}ButtonB'>{$LNG['DomainExpiryDateChecker']}</a>";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$CheckList=$_REQUEST['CheckList'];

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	if ($_SESSION['SessionResellerUsername']=="")
	{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	}
}

$SiteID=intval($_REQUEST['SiteID']);

if ($_REQUEST['Refresh']==1)
{
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/expire'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);		
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
	$Domain=$Row['Domain'];
		
		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}

		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

		$ExpiresOn = date("D j M Y", strtotime($Row['ExpiresOn']));
		$DomainExpiresOn = date("D j M Y", strtotime($Row['DomainExpiresOn']));

		$Date=date ("Y-m-d");
		$DaysLeft=floor((strtotime($Row['ExpiresOn'])-strtotime($Date))/(60*60*24));
		$DomainDaysLeft=floor((strtotime($Row['DomainExpiresOn'])-strtotime($Date))/(60*60*24));

		$HostingExpire="";
		if (!stristr($ExpiresOn,"1970"))
		{
		$HostingExpire="$ExpiresOn ($DaysLeft Days)";
		}


		$DomainExpire="";
		if (!stristr($DomainExpiresOn,"1970"))
		{
		$DomainExpire="$DomainExpiresOn ($DomainDaysLeft Days)";
		}

		echo DesignCode($Loop,"$Control (Loop)");

	
	$X++;
	}
	

	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;
		
?>