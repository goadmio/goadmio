<?php
include "nav.php";
include "no.php";
$Buttons="<a href='javascript:Load(\"$CurrentFileName?Action=CreateSnapshot&Page=$Page\")' class='ButtonB {$Dir}ButtonB'>{$LNG['CreateSnapshot']}</a> <a href=\"phpmyadmin.php\" target='_blank' class='ButtonB'>phpMyAdmin</a>";
include "title.php";

$Date=date ("Y-m-d");

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid GoAdmio Path";
	exit;
}

$Edit=intval($_REQUEST['Edit']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$Name=ValidateDatabaseName($_REQUEST['Name']);
$User=ValidateUsername($_REQUEST['User']);
$Pass=ValidatePassword($_REQUEST['Pass']);
$PHPMyAdmin=intval($_REQUEST['PHPMyAdmin']);
$Remote=intval($_REQUEST['Remote']);
$MysqlID=intval($_REQUEST['MysqlID']);

$Restore=intval($_REQUEST['Restore']);
$BackupID=trim($_REQUEST['BackupID']);

if ($_REQUEST['Action']=="CreateSnapshot")
{

	if ($_SESSION['SessionType']=="Website")
	{
		if ($_SESSION['SessionDomain']!="")
		{
			
			if (file_exists("/var/log/go/snapshot/{$_SESSION['SessionDomain']}-$Date.log"))
			{
			echo Error("Snapshot for Domain {$_SESSION['SessionDomain']} ($Date) Already Exists");		
			}
			else
			{
			$Error=SSH ("sudo screen -d -m bash -c '/go/snapshot {$_SESSION['SessionDomain']} > /var/log/go/snapshot/{$_SESSION['SessionDomain']}-$Date.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			echo Error("Creating snapshot for domain {$_SESSION['SessionDomain']}...");
			}
		}
		else
		{
			echo Error("Invalid Domain {$_SESSION['SessionDomain']}");		
		}
	}
	else
	{
		if (file_exists("/var/log/go/snapshot/all-$Date.log"))
		{
		echo Error("Snapshot ($Date) Already Exists");		
		}
		else
		{
		$Error=SSH ("sudo screen -d -m bash -c '/go/snapshot all > /var/log/go/snapshot/all-$Date.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("{$LNG['WorkingOnIt']}...");
		}
	}
	
}


If ($Delete==1 and $Step==1)
{

	echo Error("Delete Database \"$Name\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=2&Domain={$_REQUEST['Domain']}&Name={$_REQUEST['Name']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ServiceControl=$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
	include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/mysql $Domain $Name AnyUser AnyPass AnyRemote delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}

If ($Restore==1 and $Step==1)
{
	
	echo "
	<div class=DivXTable>
	
		";

		$List=SSH ("/usr/bin/sudo /go/snapshot $Domain --list",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
		$ListArray=explode("\n",$List);

		echo "
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th colspan=2 width='100%' height=40>Restore Database ($Name)</th>
		
		</THEAD>
			
		<TBODY>
		";

		$X=0;


		foreach ($ListArray as $Value) 
		{
			if (stristr($Value,"|"))
			{
				$BackupArray=explode("|",$Value);
				$BackupID=$BackupArray[0];
				$BackupDate=date("D j M Y g:i a", $BackupArray[2]);
	
				if ($X%2==0)
				{
				$TDColor="Td";
				}
				else
				{
				$TDColor="TdB";
				}
				
				echo "
				<tr class='$TDColor'>

				<TD align='middle'>$BackupDate</TD>
				<TD align='middle'><a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=2&Domain=$Domain&Name=$Name&BackupID=$BackupID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Snapshot</a></TD>
				";
				
				$X++;
				
				
			}
			
		}

	echo "
		</TBODY>
		</TABLE>
		
	</div>
	";
	
}
	
If ($Restore==1 and $Step==2)
{
	
	if ($BackupID!="")
	{
	$Error=SSH ("/usr/bin/sudo /go/snapshot /home/$Domain/var/log/go/mysql/$Name.sql $BackupID",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=Error("$Error");	
	}
}

if ($User!="")
{
	include "access.php";

	if ($Edit==1)
	{
	$Error=SSH ("/usr/bin/sudo /go/mysql $Domain $Name $User '$Pass' $Remote edit",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}
	else
	{
	$Error=SSH ("/usr/bin/sudo /go/mysql $Domain $Name $User '$Pass' $Remote",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");	
	}

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}


	if ($Edit==1)
	{
		$Readonly="readonly";
	
		$Result = SQL("select * from Mysql where MysqlID='$MysqlID'");
		foreach ($Result as $Row)
		{
			$Domain=$Row['Domain'];
			$Username=$Row['Username'];
			$Name=$Row['Name'];
			$User=$Row['User'];
			$Pass="";
			$Remote=$Row['Remote'];
		
			if ($Remote==1)
			{
			$RemoteConnectionChecked="checked";
			}
		
		}
	}

	$DomainCount=0;
	$Result = SQL("select * from Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
		$DomainCount++;
	
		$Account['Domain'][]=$Row['Domain'];
		$Account['Username'][]=$Row['Username'];
		
	}
	
	if (is_array($Account['Domain']))
	{
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);
		
		$SelectDomain="<select name='Domain' id='Domain' class=Select onchange='MySQL()'>";
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			$SelectDomain.="<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]}</option>";
			}
			else
			{
			$SelectDomain.="<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]}</option>";
			}
		}
		
		$SelectDomain.="</select>";

		if ($Edit!=1)
		{
			$NameArray=explode(".",$Account['Domain'][0]);
			$Name=str_replace("-","",$NameArray[0]);
			$Name=ltrim($Name,"0123456789");
			$Name="{$Name}_";

			$User=$Name;
		
			if ($DomainCount==1)
			{
			$NamePattern="pattern=\"^{$Name}.*[^_]$\" title=\"Database Name must start with '{$Name}'\"";
			$UserPattern="pattern=\"^{$User}.*[^_]$\" title=\"Database Username must start with '{$User}'\"";
			}
			else
			{
			$NamePattern="pattern=\"^.*[^_]$\"";
			$UserPattern="pattern=\"^.*[^_]$\"";
			}
		}

		$Content=DesignCode($Content,"$Control (Content)");
		echo $Content;

	}
	else
	{

		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}
		





	if($Edit!=1)
	{

		include "search.php";
				
		$Header=DesignCode($Header,"$Control (Header)");
		echo $Header;

		$Table="Mysql";$Field="MysqlID>=1";
		$DefaultSortBy="Name";
		$DefaultDirection="ASC";
		include "include/sql.php";
		

		$X=0;		
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
		
			$MysqlID=$Row['MysqlID'];
			$ID=$Row['MysqlID'];
			
			if ($X==0)
			{
			echo "<TBODY>";
			}

			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);

			$Size=FormatSize($Row['Size']);

			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);



			echo DesignCode($Loop,"$Control (Loop)");
			
			
		$X++;
		}
				
		$Footer=DesignCode($Footer,"$Control (Footer)");
		echo $Footer;
		
		
	}

?>