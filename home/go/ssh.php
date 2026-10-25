<?php
include "nav.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);

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

if ($Action!="")
{
	include "access.php";

	if ($Action=="EnableShell")
	{
	$Error=SSH ("/usr/bin/sudo /go/shell $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}

	if ($Action=="DisableShell")
	{
	$Error=SSH ("/usr/bin/sudo /go/shell $Domain --disable",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}



	if ($Action=="EnableJailedShell")
	{
	$Error=SSH ("/usr/bin/sudo /go/jailedshell $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}

	if ($Action=="DisableJailedShell")
	{
	$Error=SSH ("/usr/bin/sudo /go/jailedshell $Domain --disable",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}
	
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
	
	$Shell=$Row['Shell'];
	$JailedShell=$Row['JailedShell'];
	
	if ($X%2==0)
	{
		$TDColor="Td";
	}
	else
	{
		$TDColor="TdB";
	}
	

	

	if ($Shell==1)
	{
	$ShellCode="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableShell&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>	
	";
	}
	else
	{
	$ShellCode="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableShell&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>	
	";
	}
	
	

	if ($JailedShell==1)
	{
	$JailedShellCode="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableJailedShell&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>	
	";
	}
	else
	{
	$JailedShellCode="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableJailedShell&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>	
	";
	}
	
	echo DesignCode($Loop,"$Control (Loop)");
	
	$X++;
}

	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;

?>