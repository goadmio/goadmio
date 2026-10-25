<?php
include "navigator.php";
include "no.php";

if (file_exists("/home/{$_SESSION['SessionUsername']}/www/backup"))
{
$Buttons="<a href=\"javascript:Load('history.php','0')\" class='ButtonB {$Dir}ButtonB'>{$LNG['BackupHistory']}</a>";
}

include "title.php";

$Date=date ("Y-m-d");

if ($_REQUEST['Domain']!="")
{
$Domain=ValidateUsername($_REQUEST['Domain']);

include "access.php";

$Destination=trim($_REQUEST['Destination']);
$Type=trim($_REQUEST['Type']);
$RemoteServer=trim($_REQUEST['RemoteServer']);
$RemoteUser=trim($_REQUEST['RemoteUser']);
$RemotePassword=trim($_REQUEST['RemotePassword']);
$RemoteDir=trim($_REQUEST['RemoteDir']);
$Email=trim($_REQUEST['Email']);
	

	if ($Type=="") {$Type="full";}
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/backup --domain $Domain --type $Type --destination $Destination --remoteserver $RemoteServer --remoteuser $RemoteUser --remotepassword $RemotePassword  --remotedir $RemoteDir --email $Email'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	if ($Destination=="url")
	{
	echo Error("{$LNG['GeneratingTemporaryDownloadURLPleaseWait']}...");
	}
	elseif ($Type=="full" or $Type=="www" or $Type=="mail" or $Type=="database")
	{
		if ($Destination=="homedir")
		{
			if (file_exists("/home/$Domain/$Type-backup-$Date-$Domain.tar.gz"))
			{
			echo Error("Backup /home/$Domain/$Type-backup-$Date-$Domain.tar.gz already exists.");
			}
			else
			{
			echo Error("Backup (/home/$Domain/$Type-backup-$Date-$Domain.tar.gz)...");
			}
		}
		elseif ($Destination=="backup")
		{
			if (file_exists("/backup/$Type-backup-$Date-$Domain.tar.gz"))
			{
			echo Error("Backup /backup/$Type-backup-$Date-$Domain.tar.gz already exists.");
			}
			else
			{
			echo Error("Backup (/backup/$Type-backup-$Date-$Domain.tar.gz)...");
			}
		}
		else
		{
		echo Error("Backup in Progress...");
		}
	}
	else
	{
	echo Error("{$LNG['WorkingOnIt']} ($Domain/$Type-backup-$Date-$Domain.tar.gz)...");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;

}


	if ($_SESSION['SessionType'] == "Root")
	{
		$BackupDirectoryOption="<option value='backup' selected>{$LNG['BackupDirectory']}</option>";
		
		$Result = SQL("select * from Config");
		foreach ($Result as $Row)
		{
			$Email=$Row['AdminEmail'];
		}
		
	}
	else
	{
		$HomeDirectorySelected="selected";
		
		$Result = SQL("select * from Site where Domain='{$_SESSION['SessionDomain']}'");
		foreach ($Result as $Row)
		{
			$Email=$Row['AdminEmail'];
		}
	}


	echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=ControlID value='$ControlID'>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	";


		$Sql = "select * from Site where Trash=0 $SearchSql";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		$Account['Domain'][]=$Row['Domain'];
		$Account['Username'][]=$Row['Username'];
		}
		
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);

		echo "<select name='Domain' id='Domain' class=Select>";
		
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			echo "<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]}</option>";
			}
			else
			{
			echo "<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]}</option>";
			}
		}

		echo "</select>";
		
	echo "
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Type']}<br>
	<select name='Type' class=Select>
	<option value='full'>Full Backup</option>
	<option value='database'>Database Backup</option>
	<option value='www'>Home Directory Backup</option>
	<option value='mail'>Mail Backup</option>
	</select>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Destination']}<br>
	<select name='Destination' class=Select onchange='BackupDestination()'>
	<option value='homedir' $HomeDirectorySelected>{$LNG['HomeDirectory']}</option>
	$BackupDirectoryOption
	<option value='url'>{$LNG['TemporaryURL']}</option>
	<option value='ftp'>{$LNG['RemoteFTPServer']}</option>
	<option value='passiveftp'>{$LNG['RemoteFTPServerPassive']}</option>
	<option value='scp'>{$LNG['SecureCopySCP']}</option>	
	</select>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	<input type='text' name='Email' value='$Email' maxlength=100 class=InputText>
	</div>


	<div class=DivInput style='display:none' id=RemoteServer>{$LNG['RemoteServer']}<br>
	<input type='text' name='RemoteServer' maxlength=100 class=InputText size=40>
	</div>

	<div class=DivInput style='display:none' id=RemoteUser>{$LNG['RemoteUser']}<br>
	<input type='text' name='RemoteUser' maxlength=100 class=InputText> 
	</div>

	<div class=DivInput style='display:none' id=RemotePassword>{$LNG['RemotePassword']}<br>
	<input type='text' name='RemotePassword' maxlength=100 class=InputText>
	</div>

	<div class=DivInput style='display:none' id=RemoteDir>{$LNG['RemoteDir']}<br>
	<input type='text' name='RemoteDir' maxlength=100 class=InputText size=40>
	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['GenerateBackup']}' Class=InputButton>
	</div>

</form>
";

	
	
?>