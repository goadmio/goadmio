<?php
include "nav.php";
$Buttons="";
include "title.php";

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid GoAdmio Path";
	exit;
}

$SortBy=$_REQUEST['SortBy'];
$Step=$_REQUEST['Step'];
$Delete=$_REQUEST['Delete'];
$Action=$_REQUEST['Action'];

$Username=ValidateUsername($_REQUEST['Username']);
$Domain=ValidateUsername($_REQUEST['Domain']);
$SiteID=$_REQUEST['SiteID'];
$CompanyNotes=$_REQUEST['CompanyNotes'];
$Action=$_REQUEST['Action'];
$Restore=$_REQUEST['Restore'];
$CheckList=$_REQUEST['CheckList'];

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	
	if ($_SESSION['SessionResellerUsername']=="")
	{
		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";
		
		exit;
	}
}

$UserNo=RowCount("select * from Site where Trash=0");

If ($Restore==1)
{
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo /go/recover $Username",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
}

If ($Delete==1 and $Step==1)
{
	include "access.php";
	
	echo Error("Delete $Domain ? <a href=\"javascript:Load(' $CurrentFileName?Delete=1&&Step=2&Username=$Username&Domain=$Domain&SiteID=$SiteID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ServiceControl=$CurrentFileName')\" class=Action>No</a>");
	exit;
	
}

If ($Delete==1 and $Step==2)
{
	include "access.php";
		
	$Error=SSH ("sudo screen -d -m bash -c '/go/delete $Domain > /var/log/go/delete/$Domain.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Account $Domain ($Username) has been terminated.");
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
	$Username=$Row['Username'];
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
	
	if ($Row['Suspend']==1)
	{
		$Status="Suspended";
	}
	elseif ($Row['Unpublish']==1)
	{
		$Status="Unpublished";
	}
	
	if (file_exists("/etc/letsencrypt/live/$Domain/cert.pem"))
	{
		$PingIP=$IPv4;
	}
	else
	{
		$PingIP=gethostbyname($Domain);
	}
	
	echo DesignCode($Loop,"$Control (Loop)");
	
	$X++;
}

$Footer=DesignCode($Footer,"$Control (Footer)");
echo $Footer;

?>