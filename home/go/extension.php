<?php

include "nav.php";
$Buttons="";
include "title.php";

$ExtensionID=intval($_REQUEST['ExtensionID']);
$CheckList=$_REQUEST['CheckList'];

$PageNo=1000;

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

		$Result = SQL("select * from Extension where ExtensionID=$ExtensionID");
		foreach ($Result as $Row)
		{
		$Name=$Row["Name"];
		$Extension=$Row["Extension"];
		}
	
		if ($Action=="Install")
		{
			if (stristr($Extension,"/"))
			{
			$Error=SSH ("sudo screen -d -m bash -c '$Extension'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			else
			{
			$Error=SSH ("sudo screen -d -m bash -c '/go/extension $Extension'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			
			echo Error("Installing $Name, Please wait...");
		}

		if ($Action=="Remove")
		{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/extension $Extension remove'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		
		echo Error("Removing $Name, Please wait...");
		}
		
	}

	include "search.php";
	
	$Header=DesignCode($Header,"$Control (Header)");
	echo $Header;	

	$Table="Extension";$Field="ExtensionID>=1";
	$DefaultSortBy="Extension";
	$DefaultDirection="ASC";
	include "include/sql.php";
	
	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$ExtensionID=$Row['ExtensionID'];
		$Name=$Row['Name'];
		
		if (strlen($Name)<=4)
		{
		$Name=strtoupper($Name);
		}

		if ($Name=="bcmath")
		{
			$Name="BCMath";
		}
		
		if ($Name=="brotli")
		{
			$Name="Brotli";
		}
		
		if ($Name=="dbase")
		{
			$Name="dBase";
		}
		
		if ($Name=="fileinfo")
		{
			$Name="Fileinfo";
		}
		
		if ($Name=="gettext")
		{
			$Name="Gettext";
		}
		
		if ($Name=="mbstring")
		{
			$Name="MBstring";
		}
		
		if ($Name=="mssql")
		{
			$Name="MS-SQL";
		}
		
		if ($Name=="mysql")
		{
			$Name="MySQL";
		}

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}

		$Description=$Row['Description'];
		
		if (extension_loaded($Row['Extension'])) 
		{
		$Status=$LNG['Installed'];
		}
		elseif ($Row['Extension']=="") 
		{
		$Status=$LNG['NotAvailable'];
		}
		else
		{
		$Status=$LNG['NotInstalled'];
		}
		
		$ActionLink="";
		if ($Status=="Installed") 
		{
			if ($Row['Required']==0)
			{
				if ($ExtensionID==$_REQUEST['ExtensionID'] and $Lock=="")
				{
				$ActionLink="{$LNG['RemovingNow']}...";
				}
				else
				{
				$ActionLink="<a title='Modify $Domain' href=\"javascript:Load('extension.php?Action=Remove&ExtensionID=$ExtensionID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=ActionB>{$LNG['Remove']}</a>";
				}
			}
		
		}
		elseif ($Status=="Not Available") 
		{
		$ActionLink="";
		}
		else
		{
			if ($ExtensionID==$_REQUEST['ExtensionID'] and $Lock=="")
			{
			$ActionLink="{$LNG['InstallingNow']}...";
			}
			else
			{
			$ActionLink="<a title='Modify $Domain' href=\"javascript:Load('extension.php?Action=Install&ExtensionID=$ExtensionID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['Install']}</a>";	
			}
		}
	
		echo DesignCode($Loop,"$Control (Loop)");

	$X++;
	}
	
	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;

?>