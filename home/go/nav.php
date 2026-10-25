<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
$CurrentFileName=basename ($_SERVER['PHP_SELF']);
$HTMLFileName=str_replace(".php",".html",$CurrentFileName);

include("include/function/function.php");
include("include/function/design.php");
include "/usr/local/goadmio/include/config/config.php";

$Page=$_REQUEST['Page'];
$SortBy=$_REQUEST['SortBy'];
$SortDir=$_REQUEST['SortDir'];
$Direction=$_REQUEST['Direction'];
$SearchFor=$_REQUEST['SearchFor'];
$Action=$_REQUEST['Action'];
$Edit=$_REQUEST['Edit'];
$Delete=$_REQUEST['Delete'];
$ControlID=intval($_REQUEST['ControlID']);
$Step=$_REQUEST['Step'];
$CheckList=$_REQUEST['CheckList'];
$NavigatorTitle=$_REQUEST['NavigatorTitle'];

$TimeStamp=time();

if ($_SESSION['SessionDomain']=="" and $_SESSION['SessionUsername']=="")
{
echo "<META HTTP-EQUIV='Refresh' Content='0;URL=index.php'>";

exit;
}

include "language/en.php";
if ($_SESSION['SessionLng']!="en")
{
include "language/{$_SESSION['SessionLng']}.php";
}

if (stristr("|ar|fa|ps|sd|ug|ur|yi|","|{$_SESSION['SessionLng']}|"))
{
$DAlign="right";
$OAlign="left";
$Dir="RTL";
}
else
{
$DAlign="left";
$OAlign="right";
$Dir="LTR";
}

$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{	
	$IPv4=$Row['IPv4'];
	$IPv6=$Row['IPv6'];
	$Version=intval($Row['Version']);
	$LoginNo=$Row['LoginNo'];
	
	$CloudflareAccountID=trim($Row['CloudflareAccountID']);
	
	$PageNo=$Row['PageNo'];
	$PageBarNo=$Row['PageBarNo'];

	$HardDiskInfo=$Row['HardDiskInfo'];
}





	if ($ControlID>=1)
	{
		if ($_SESSION['SessionType']=="Website")
		{
		SQL("UPDATE Control SET UClick=UClick+1 where ControlID='$ControlID'");
		}
		else
		{
		SQL("UPDATE Control SET RClick=RClick+1 where ControlID='$ControlID'");
		}
	}
	
	if ($CurrentFileName=="home.php")
	{
	$Navigator['Name'][0]=$LNG['Tools'];
	$Navigator['URL'][0]="";
	}
	elseif ($CurrentFileName=="category.php")
	{


		$ControlMenu=trim($_REQUEST['ControlMenu']);

		$Result = SQL("select * from Control where ControlMenu='$ControlMenu'");
		foreach ($Result as $Row)
		{
		$ControlMenu=$Row['ControlMenu'];
		$ControlMenuText=$LNG[$Row['ControlMenu']];		
		}
	
	$Navigator['Name'][0]=$LNG['Home'];
	$Navigator['URL'][0]="javascript:Load(\"home.php\")";
	
	$Navigator['Name'][1]=$ControlMenuText;
	$Navigator['URL'][1]="";
	}
	else
	{

	
		if ($ControlID>=1)
		{

			$Result = SQL("select * from Control where ControlID='$ControlID'");
			foreach ($Result as $Row)
			{
				$Service=$Row['Service'];
				
				$Control=$LNG[$Row['Control']];
				$ControlMenu=$Row['ControlMenu'];
				$ControlMenuText=$LNG[$Row['ControlMenu']];
				$ControlImage=$Row['ControlImage'];
			}
		}
		else
		{
			$Result = SQL("select * from Control where ControlUrl like '$CurrentFileName%'");
			foreach ($Result as $Row)
			{
				$Service=$Row['Service'];
			
				if ($_REQUEST['NavigatorTitle']=="")
				{
				$Control=$LNG[$Row['Control']];
				}
				else
				{
				$Control=$_REQUEST['NavigatorTitle'];
				}
				
				$ControlMenu=$Row['ControlMenu'];
				$ControlMenuText=$LNG[$Row['ControlMenu']];
				$ControlImage=$Row['ControlImage'];
			}
		}
	
	$Navigator['Name'][0]=$LNG['Home'];
	$Navigator['URL'][0]="javascript:Load(\"home.php\")";

	$Navigator['Name'][1]=$ControlMenuText;
	$Navigator['URL'][1]="javascript:Load(\"category.php?ControlMenu=$ControlMenu\")";

	$Navigator['Name'][2]=$Control;
	$Navigator['URL'][2]="";
	}


if (file_exists("html/$HTMLFileName"))
{
$HTML=file_get_contents("html/$HTMLFileName");
preg_match('/<content>(.*?)<\/content>/s', $HTML, $ContentArray);
$Content=$ContentArray[1];
preg_match('/<nav>(.*?)<\/nav>/s', $HTML, $NavArray);
$Nav=$NavArray[1];

preg_match('/<header>(.*?)<\/header>/s', $HTML, $HeaderArray);
$Header=$HeaderArray[1];

preg_match('/<footer>(.*?)<\/footer>/s', $HTML, $FooterArray);
$Footer=$FooterArray[1];

preg_match('/<loop>(.*?)<\/loop>/s', $HTML, $LoopArray);
$Loop=$LoopArray[1];
}
else
{
	echo "File html/$HTMLFileName not Exists.";
}

$Nav=DesignCode($Nav,"$Control (Nav)");
echo $Nav;

$Success=0;
if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
$Success=1;
}
elseif ($_SESSION['SessionType']=="Website")
{

	if (stristr($Service,"Website"))
	{
	$Success=1;
	}

}
else
{

	if (stristr($Service,"Website") or stristr($Service,"Reseller"))
	{
	$Success=1;
	}

}

if ($CurrentFileName!="home.php" and $CurrentFileName!="category.php")
{
	if ($Success==0)
	{
		Echo "
		<div class=Error>
		Sorry, You Are Not Allowed to Access This Page...
		</div>
		";
		
		exit;
	}

}


if ($_SESSION['SessionUserID']==1)
{
$SearchSql="";
}
elseif ($_SESSION['SessionType']=="Website")
{
	// Addon Domains
	$Result = SQL("select * from Site where Domain='{$_SESSION['SessionDomain']}' or Owner='{$_SESSION['SessionDomain']}'");
	foreach ($Result as $Row)
	{
		if ($Owner=="")
		{
		$Owner="'{$Row['Domain']}'";
		}
		else
		{
		$Owner.=",'{$Row['Domain']}'";
		}
		
		$Domains[]=$Row['Domain'];
	}

	if ($Owner=="")
	{
	$SearchSql="and Domain='{$_SESSION['SessionDomain']}'";
	}
	else
	{
	$SearchSql="and Domain in ($Owner)";
	}
	
	$_SESSION['SessionDomains']=$Domains;
}
elseif ($_SESSION['SessionType']=="Reseller")
{

	$Result = SQL("select * from Site where UserID='{$_SESSION['SessionUserID']}'");
	foreach ($Result as $Row)
	{
		if ($Owner=="")
		{
		$Owner="'{$Row['Domain']}'";
		}
		else
		{
		$Owner.=",'{$Row['Domain']}'";
		}

	}

	if ($Owner=="")
	{
	$SearchSql="and Domain=''";
	}
	else
	{
	$SearchSql="and Domain in ($Owner)";
	}
		
}
else
{
$SearchSql="and Domain='google.com'";
}

?>