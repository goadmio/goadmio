<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Storage=trim($_REQUEST['Storage']);

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";
	
	exit;
	
}

if ($_REQUEST['Cron']!="" or $_REQUEST['Destination']!="" or $_REQUEST['RemoteDir']!="")
{

	$Cron=$_REQUEST['Cron'];
	$Destination=trim($_REQUEST['Destination']);
	
	$WWWBackup=trim($_REQUEST['WWWBackup']);
	$MailBackup=trim($_REQUEST['MailBackup']);
	$DatabaseBackup=trim($_REQUEST['DatabaseBackup']);
	$Type="{$WWWBackup}{$MailBackup}{$DatabaseBackup}";
	
	if ($Type=="wwwmaildatabase")
	{
	$Type="full";
	}
	
	$RemoteServer=trim($_REQUEST['RemoteServer']);
	$Key=trim($_REQUEST['Key']);
	$ApiKey=trim($_REQUEST['ApiKey']);
	$Token=trim($_REQUEST['Token']);
	$AppToken=trim($_REQUEST['AppToken']);
	$AccessToken=trim($_REQUEST['AccessToken']);
	$AccessKeyID = trim($_REQUEST['AccessKeyID']);
	$SecretAccessKey = trim($_REQUEST['SecretAccessKey']);
	$Endpoint = trim($_REQUEST['Endpoint']);
	$Provider = trim($_REQUEST['Provider']);
	$Region = trim($_REQUEST['Region']);
	$Url = trim($_REQUEST['Url']);
	$Vendor = trim($_REQUEST['Vendor']);
	$Email = trim($_REQUEST['Email']);
	$Account = trim($_REQUEST['Account']);
	$ShareName = trim($_REQUEST['ShareName']);

	$RemoteUser=trim($_REQUEST['RemoteUser']);
	$RemotePass=trim($_REQUEST['RemotePass']);
	
	$MegaUser=trim($_REQUEST['MegaUser']);
	$MegaPass=trim($_REQUEST['MegaPass']);
	
	$OpenDriveUser=trim($_REQUEST['OpenDriveUser']);
	$OpenDrivePass=trim($_REQUEST['OpenDrivePass']);

	$PikPakUser=trim($_REQUEST['PikPakUser']);
	$PikPakPass=trim($_REQUEST['PikPakPass']);

	$ProtonDriveUser=trim($_REQUEST['ProtonDriveUser']);
	$ProtonDrivePass=trim($_REQUEST['ProtonDrivePass']);

	$MailruUser=trim($_REQUEST['MailruUser']);
	$MailruPass=trim($_REQUEST['MailruPass']);

	$UloztoUser=trim($_REQUEST['UloztoUser']);
	$UloztoPass=trim($_REQUEST['UloztoPass']);
	
	$WebDAVUser=trim($_REQUEST['WebDAVUser']);
	$WebDAVPass=trim($_REQUEST['WebDAVPass']);

	$IDriveUser=trim($_REQUEST['IDriveUser']);
	$IDrivePass=trim($_REQUEST['IDrivePass']);

	$Port=trim($_REQUEST['Port']);
	$Retention=intval($_REQUEST['Retention']);
	$Sync=intval($_REQUEST['Sync']);
	
	if ($RemoteServer=="")
	{
		$RemoteServer="-";
	}
	
	if ($RemoteUser=="")
	{
		$RemoteUser="root";
	}
	
	if ($RemotePass=="")
	{
		$RemotePass="";
	}
	
	if ($Port=="")
	{
		$Port="22";
	}
	
	if ($Retention==0)
	{
		$Retention="12";
	}
	
	$RemoteDir=trim($_REQUEST['RemoteDir']);

	$Error=SSH ("set -f && /usr/bin/sudo /go/backup --cron '$Cron' --type '$Type' --destination '$Destination' --remoteserver '$RemoteServer' --key '$Key' --apikey '$ApiKey' --token '$Token' --apptoken '$AppToken' --accesstoken '$AccessToken' --accesskeyid '$AccessKeyID' --secretaccesskey '$SecretAccessKey' --endpoint '$Endpoint' --provider '$Provider' --region '$Region' --url '$Url' --vendor '$Vendor' --email '$Email' --account '$Account' --sharename '$ShareName' --remoteuser '$RemoteUser' --remotepass '$RemotePass' --megauser '$MegaUser' --megapass '$MegaPass' --opendriveuser '$OpenDriveUser' --opendrivepass '$OpenDrivePass' --pikpakuser '$PikPakUser' --pikpakpass '$PikPakPass' --protondriveuser '$ProtonDriveUser' --protondrivepass '$ProtonDrivePass' --mailruuser '$MailruUser' --mailrupass '$MailruPass' --uloztouser '$UloztoUser' --uloztopass '$UloztoPass' --webdavuser '$WebDAVUser' --webdavpass '$WebDAVPass' --idriveuser '$IDriveUser' --idrivepass '$IDrivePass' --port '$Port' --remotedir '$RemoteDir' --retention '$Retention' --sync '$Sync' --storage '$Storage' --setup 1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
	
}

if ($Action=="EnableBackup")
{
	SQL("UPDATE Site SET Backup='1' where SiteID='$SiteID'");
}

if ($Action=="DisableBackup")
{
	SQL("UPDATE Site SET Backup='0' where SiteID='$SiteID'");
}

if ($Storage=="" or $Storage=="backup")
{
	$BackupCheck="checked";
	$StorageFile="backup.conf";
		
	$IPv4Array=explode(".",$IPv4);
	$H=($IPv4Array[3]%5)+2;
	$M=($IPv4Array[0]%60);
}
elseif ($Storage=="secondary")
{
	$SecondaryCheck="checked";
	$StorageFile="secondary.conf";
	
	$IPv4Array=explode(".",$IPv4);
	$H=($IPv4Array[2]%5)+8;
	$M=($IPv4Array[1]%60);
}
else
{
	$TertiaryCheck="checked";
	$StorageFile="tertiary.conf";
	
	$IPv4Array=explode(".",$IPv4);
	$H=($IPv4Array[1]%5)+14;
	$M=($IPv4Array[2]%60);
}

if (file_exists("/var/go/etc/$StorageFile"))
{
	$Config = parse_ini_file("/var/go/etc/$StorageFile");
	$Cron = $Config['Cron'];
	$Type = $Config['Type'];
	$Destination = $Config['Destination'];
	$RemoteServer = $Config['RemoteServer'];
	$Key = $Config['Key'];
	$ApiKey = $Config['ApiKey'];
	$Token = $Config['Token'];
	$AppToken = $Config['AppToken'];
	$AccessToken = $Config['AccessToken'];
	$AccessKeyID = $Config['AccessKeyID'];
	$SecretAccessKey = $Config['SecretAccessKey'];
	$Endpoint = $Config['Endpoint'];
	$Provider = $Config['Provider'];
	$Region = $Config['Region'];
	$Url = $Config['Url'];
	$Vendor = $Config['Vendor'];
	$Email = $Config['Email'];
	$Account = $Config['Account'];
	$ShareName = $Config['ShareName'];
	
	$RemoteUser = $Config['RemoteUser'];
	$RemotePass = $Config['RemotePass'];

	$MegaUser = $Config['MegaUser'];
	$MegaPass = $Config['MegaPass'];

	$OpenDriveUser = $Config['OpenDriveUser'];
	$OpenDrivePass = $Config['OpenDrivePass'];

	$PikPakUser = $Config['PikPakUser'];
	$PikPakPass = $Config['PikPakPass'];

	$ProtonDriveUser = $Config['ProtonDriveUser'];
	$ProtonDrivePass = $Config['ProtonDrivePass'];

	$MailruUser = $Config['MailruUser'];
	$MailruPass = $Config['MailruPass'];
	
	$UloztoUser = $Config['UloztoUser'];
	$UloztoPass = $Config['UloztoPass'];
	
	$WebDAVUser = $Config['WebDAVUser'];
	$WebDAVPass = $Config['WebDAVPass'];
	
	$IDriveUser = $Config['IDriveUser'];
	$IDrivePass = $Config['IDrivePass'];

	$Port = $Config['Port'];
	$RemoteDir = $Config['RemoteDir'];
	$Retention = $Config['Retention'];
	$Sync = $Config['Sync'];
}
else
{
	$Cron = "";
	$Type = "wwwmaildatabase";
	$Destination = "sftp";
	$RemoteServer = "";
	$Key = "";
	$ApiKey = "";
	$Token = "";
	$AppToken = "";
	$AccessToken = "";
	$AccessKeyID = "";
	$SecretAccessKey = "";
	$Endpoint = "";
	$Provider = "";
	$Region = "";
	$Url = "";
	$Vendor = "";
	$Email = "";
	$Account = "";
	$ShareName = "";
	
	$RemoteUser = "";
	$RemotePass = "";
	
	$MegaUser = "";
	$MegaPass = "";
	
	$OpenDriveUser = "";
	$OpenDrivePass = "";

	$PikPakUser = "";
	$PikPakPass = "";
	


	$ProtonDriveUser = "";
	$ProtonDrivePass = "";

	$MailruUser = "";
	$MailruPass = "";
	
	$UloztoUser = "";
	$UloztoPass = "";
	
	$WebDAVUser = "";
	$WebDAVPass = "";

	$IDriveUser = "";
	$IDrivePass = "";
	
	$Port = "22";
	$RemoteDir = "/backup";
	$Email = "";
	$Account = "";
	$ShareName = "";
	$Retention = "8";
	$Sync = "1";
}

if ($RemoteDir=="")
{
	$RemoteDir="/backup";
}


if ($Cron=="$M $H */1 * *")
{
	$DailySelected="selected";
}
elseif ($Cron=="$M $H */2 * *")
{
	$TwoSelected="selected";
}
elseif ($Cron=="$M $H */3 * *")
{
	$ThereSelected="selected";
}
elseif ($Cron=="$M $H */4 * *")
{
	$FourSelected="selected";
}
elseif ($Cron=="$M $H */5 * *")
{
	$FiveSelected="selected";
}
elseif ($Cron=="$M $H */6 * *")
{
	$SixSelected="selected";
}
elseif ($Cron=="$M $H * * 6")
{
	$SATSelected="selected";
}
elseif ($Cron=="$M $H * * 0")
{
	$SUNSelected="selected";
}
elseif ($Cron=="$M $H * * 1")
{
	$MONSelected="selected";
}
elseif ($Cron=="$M $H * * 2")
{
	$TUESelected="selected";
}
elseif ($Cron=="$M $H * * 3")
{
	$WEDSelected="selected";
}
elseif ($Cron=="$M $H * * 4")
{
	$THUSelected="selected";
}
elseif ($Cron=="$M $H * * 5")
{
	$FRISelected="selected";
}
elseif ($Cron=="$M $H * * 2,6")
{
	$SatTueSelected="selected";
}
elseif ($Cron=="$M $H * * 0,3")
{
	$SunWedSelected="selected";
}
elseif ($Cron=="$M $H * * 1,4")
{
	$MonThuSelected="selected";
}
elseif ($Cron=="$M $H 1 * *")
{
	$MonthlySelected="selected";
}

if ($Type=="full" or stristr($Type,"www"))
{
	$WWWChecked="checked";
}

if ($Type=="full" or stristr($Type,"mail"))
{
	$MailChecked="checked";
}

if ($Type=="full" or stristr($Type,"database"))
{
	$DatabaseChecked="checked";
}

if ($Port=="")
{
	$Port="22";
}

if ($Retention=="")
{
	$Retention="12";
}

if ($Sync=="1")
{
	$SyncChecked="checked";
}

echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
<input type=hidden name=ControlID value='$ControlID'>

<div class='DivInput {$Dir}DivInput'>{$LNG['StorageBox']}:<br>

	<label class=\"radio-enhanced\">
		<input type='radio' name='Storage' value='backup' onclick=\"Load('schedule.php?ControlID=$ControlID&Storage=backup')\" $BackupCheck>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">
		{$LNG['PrimaryBackup']}
		</span>
	</label>

	<label class=\"radio-enhanced\">
		<input type='radio' name='Storage' value='secondary' onclick=\"Load('schedule.php?ControlID=$ControlID&Storage=secondary')\" $SecondaryCheck>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">
		{$LNG['SecondaryBackup']}
		</span>
	</label>

	<label class=\"radio-enhanced\">
		<input type='radio' name='Storage' value='tertiary' onclick=\"Load('schedule.php?ControlID=$ControlID&Storage=tertiary')\" $TertiaryCheck>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">
		{$LNG['TertiaryBackup']}
		</span>
	</label>

</div>

<div class='DivInput {$Dir}DivInput'>Backup Interval<br>
<select name='Cron' class=Select>
<option value=''>Disable Backup</option>
<option value='$M $H */1 * *' $DailySelected>Daily</option>
<option value='$M $H */2 * *' $TwoSelected>2 Days</option>
<option value='$M $H */3 * *' $ThereSelected>3 Days</option>
<option value='$M $H */4 * *' $FourSelected>4 Days</option>
<option value='$M $H */5 * *' $FiveSelected>5 Days</option>
<option value='$M $H */6 * *' $SixSelected>6 Days</option>
<option value='$M $H * * 6' $SATSelected>Sat</option>
<option value='$M $H * * 0' $SUNSelected>Sun</option>
<option value='$M $H * * 1' $MONSelected>Mon</option>
<option value='$M $H * * 2' $TUESelected>Tue</option>
<option value='$M $H * * 3' $WEDSelected>Wed</option>
<option value='$M $H * * 4' $THUSelected>Thu</option>
<option value='$M $H * * 5' $FRISelected>Fri</option>
<option value='$M $H * * 2,6' $SatTueSelected>Sat & Tue</option>
<option value='$M $H * * 0,3' $SunWedSelected>Sun & Wed</option>
<option value='$M $H * * 1,4' $MonThuSelected>Mon & Thu</option>
<option value='$M $H 1 * *' $MonthlySelected>Monthly</option>
</select>
</div>

<div class='DivInput {$Dir}DivInput' >{$LNG['Type']}:</div>

<div class=DivCheckbox>
	<label class=LabelCheckbox>{$LNG['WWWBackup']}
		<input type='checkbox' name='WWWBackup' id='WWWBackup' value='www' $WWWChecked>
		<span class='Checkbox'></span>
	</label>
</div>

<div class=DivCheckbox>
	<label class=LabelCheckbox>{$LNG['MailBackup']}
		<input type='checkbox' name='MailBackup' id='MailBackup' value='mail' $MailChecked>
		<span class='Checkbox'></span>
	</label>
</div>

<div class=DivCheckbox>
	<label class=LabelCheckbox>{$LNG['DatabaseBackup']}
		<input type='checkbox' name='DatabaseBackup' id='DatabaseBackup' value='database' $DatabaseChecked>
		<span class='Checkbox'></span>
	</label>
</div>

<div class='DivInput'>{$LNG['Destination']}<br>
<select name='Destination' class=Select onchange='Rclone()'>
<option value='local'>Local Disk</option>
";

$Result = SQL("SELECT * FROM Rclone ORDER By Destination");
foreach ($Result as $Row)
{
	if ($Destination==$Row['Destination'])
	{
	echo "<option value='{$Row['Destination']}' selected>{$Row['Name']}</option>";
	}
	else
	{
	echo "<option value='{$Row['Destination']}'>{$Row['Name']}</option>";	
	}
}
echo "
</select>
</div>

<div class=DivInput id=RemoteServer>{$LNG['RemoteServer']}<br>
<input type='text' name='RemoteServer' value='{$RemoteServer}' maxlength=100 class=InputText>
</div>

<div class=DivInput id=Account>Account<br>
<input type='text' name='Account' value='{$Account}' maxlength=1000 class=InputText>
</div>


<div class=DivInput id=ShareName>Share Name<br>
<input type='text' name='ShareName' value='{$ShareName}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Key>Key<br>
<input type='text' name='Key' value='{$Key}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=ApiKey>Api Key<br>
<input type='text' name='ApiKey' value='{$ApiKey}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Token>Token<br>
<input type='text' name='Token' value='{$Token}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=AppToken>App Token<br>
<input type='text' name='AppToken' value='{$AppToken}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=AccessToken>Access Token<br>
<input type='text' name='AccessToken' value='{$AccessToken}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=AccessKeyID>Access Key ID<br>
<input type='text' name='AccessKeyID' value='{$AccessKeyID}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=SecretAccessKey>Secret Access Key<br>
<input type='text' name='SecretAccessKey' value='{$SecretAccessKey}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Endpoint>Endpoint<br>
<input type='text' name='Endpoint' value='{$Endpoint}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Provider>Provider<br>
<input type='text' name='Provider' value='{$Provider}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Region>Region<br>
<input type='text' name='Region' value='{$Region}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Url>URL<br>
<input type='text' name='Url' value='{$Url}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Vendor>Vendor<br>
<input type='text' name='Vendor' value='{$Vendor}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=Email>Email<br>
<input type='email' name='Email' value='{$Email}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=RemoteUser>{$LNG['Username']}<br>
<input type='text' name='RemoteUser' value='{$RemoteUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=MegaUser>{$LNG['Username']}<br>
<input type='text' name='MegaUser' value='{$MegaUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=OpenDriveUser>{$LNG['Username']}<br>
<input type='text' name='OpenDriveUser' value='{$OpenDriveUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=PikPakUser>{$LNG['Username']}<br>
<input type='text' name='PikPakUser' value='{$PikPakUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=ProtonDriveUser>{$LNG['Username']}<br>
<input type='text' name='ProtonDriveUser' value='{$ProtonDriveUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=MailruUser>{$LNG['Username']}<br>
<input type='text' name='MailruUser' value='{$MailruUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=UloztoUser>{$LNG['Username']}<br>
<input type='text' name='UloztoUser' value='{$UloztoUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=WebDAVUser>{$LNG['Username']}<br>
<input type='text' name='WebDAVUser' value='{$WebDAVUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=IDriveUser>{$LNG['Username']}<br>
<input type='text' name='IDriveUser' value='{$IDriveUser}' maxlength=1000 class=InputText> 
</div>

<div class=DivInput id=RemotePass>{$LNG['Password']}<br>
<input type='password' name='RemotePass' value='{$RemotePass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=MegaPass>{$LNG['Password']}<br>
<input type='password' name='MegaPass' value='{$MegaPass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=OpenDrivePass>{$LNG['Password']}<br>
<input type='password' name='OpenDrivePass' value='{$OpenDrivePass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=PikPakPass>{$LNG['Password']}<br>
<input type='password' name='PikPakPass' value='{$PikPakPass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=ProtonDrivePass>{$LNG['Password']}<br>
<input type='password' name='ProtonDrivePass' value='{$ProtonDrivePass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=MailruPass>{$LNG['Password']}<br>
<input type='password' name='MailruPass' value='{$MailruPass}' maxlength=1000 class=InputText>
</div>


<div class=DivInput id=UloztoPass>{$LNG['Password']}<br>
<input type='password' name='UloztoPass' value='{$UloztoPass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=WebDAVPass>{$LNG['Password']}<br>
<input type='password' name='WebDAVPass' value='{$WebDAVPass}' maxlength=1000 class=InputText>
</div>

<div class=DivInput id=IDrivePass>{$LNG['Password']}<br>
<input type='password' name='IDrivePass' value='{$IDrivePass}' maxlength=1000 class=InputText>
</div>


<div class=DivInput id=Port>{$LNG['Port']}<br>
<input type='text' name='Port' value='{$Port}' maxlength=5 class=InputText>
</div>

<div class=DivInput id=RemoteDir>{$LNG['RemoteDir']}<br>
<input type='text' name='RemoteDir' value='{$RemoteDir}' maxlength=100 class=InputText>
</div>

<div class=DivInput id=Retention>Retention<br>
<input type='text' name='Retention' value='{$Retention}' maxlength=100 class=InputText> How many backups to keep
</div>

<div class=DivCheckbox>
	<label class=LabelCheckbox>MySQL Sync
		<input type='checkbox' name='Sync' id='Sync' value='1' $SyncChecked>
		<span class='Checkbox'></span>
	</label>
</div>

<div id=DivSubmit class=DivSubmit>
<input type=submit value='{$LNG['Save']}' Class=InputButton>
</div>

</form>
";

include "search.php";

Echo "
<form name=CheckForm id=CheckForm action='$CurrentFileName'>
<input type=hidden name=Action id=Action>

<div class=DivXTable>
<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

<THEAD>

<tr>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Backup')\">{$LNG['BackupStatus']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=BackupStamp')\">{$LNG['BackupDate']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=SpaceUsed')\">{$LNG['DiskUsage']}</a>
</TH>

<TH width='20%'>

</TH>

</tr>

</THEAD>

";

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
	$Backup=$Row['Backup'];
	
	$BackupStamp=intval($Row['BackupStamp']);
	
	if ($BackupStamp>=1)
	{
	$BackupDate=date("D j M Y g:i a",$BackupStamp);
	}
	
	$SpaceUsed=FormatSize($Row['SpaceUsed']);
	
	
	
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
	
	if ($Backup==1)
	{
		$BackupCode="✔";
	}
	else
	{
		$BackupCode="✖";
	}
	
	
	if ($Backup==1)
	{
		$BackupStatus= "
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=DisableBackup&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
	}
	else
	{
		$BackupStatus="
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=EnableBackup&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
	}
	
	
	
	ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>
	
	<TD>
	<a href='http://{$Row['Domain']}' target='_blank'>{$Row['Domain']}</a>
	</td>
	
	<TD>
	$BackupCode
	</td>
	
	<TD>
	$BackupDate
	</td>
	
	<TD>
	$SpaceUsed
	</td>
	
	<TD align='$OAlign'>
	$BackupStatus
	</td>
	
	</tr>
	";
	
	$X++;
}

if ($X!=0)
{
	echo "</TBODY>";
}

echo "
<TFOOT>

<tr class=TdDown>

<th align='$DAlign' colspan=3>
Showing $X of $RowsNo records.
</th>

<th align='$OAlign' colspan=3>
";

include "pages.php";

echo "
</th>

</tr>

</TFOOT>

</TABLE>
</div>
</form>
";

?>