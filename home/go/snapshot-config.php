<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Storage=trim($_REQUEST['Storage']);
$Action=trim($_REQUEST['Action']);

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";
	
	exit;
	
}

if ($Action=="EnableSnapshot")
{
	SQL("UPDATE Site SET Snapshot='1' where SiteID='$SiteID'");
}

if ($Action=="DisableSnapshot")
{
	SQL("UPDATE Site SET Snapshot='0' where SiteID='$SiteID'");
}

if ($_REQUEST['Cron']!="" or $_REQUEST['Destination']!="" or $_REQUEST['RemoteDir']!="")
{

	$Cron=$_REQUEST['Cron'];
	$Destination=trim($_REQUEST['Destination']);
	
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

	$Port=trim($_REQUEST['Port']);
	
	$RemoteDir=trim($_REQUEST['RemoteDir']);
	$Storage="snapshot";

	$Error=SSH ("set -f && /usr/bin/sudo /go/backup --cron '$Cron' --destination '$Destination' --remoteserver '$RemoteServer' --key '$Key' --apikey '$ApiKey' --token '$Token' --apptoken '$AppToken' --accesstoken '$AccessToken' --accesskeyid '$AccessKeyID' --secretaccesskey '$SecretAccessKey' --endpoint '$Endpoint' --provider '$Provider' --region '$Region' --url '$Url' --vendor '$Vendor' --email '$Email' --account '$Account' --sharename '$ShareName' --remoteuser '$RemoteUser' --remotepass '$RemotePass' --megauser '$MegaUser' --megapass '$MegaPass' --opendriveuser '$OpenDriveUser' --opendrivepass '$OpenDrivePass' --pikpakuser '$PikPakUser' --pikpakpass '$PikPakPass' --protondriveuser '$ProtonDriveUser' --protondrivepass '$ProtonDrivePass' --mailruuser '$MailruUser' --mailrupass '$MailruPass' --uloztouser '$UloztoUser' --uloztopass '$UloztoPass' --webdavuser '$WebDAVUser' --webdavpass '$WebDAVPass' --port '$Port' --remotedir '$RemoteDir' --storage '$Storage' --setup 1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);

	


	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
	
}

$Storage=="snapshot";
$StorageFile="snapshot.conf";

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
	
	$Port = $Config['Port'];
	$RemoteDir = $Config['RemoteDir'];
	$Retention = $Config['Retention'];
	$Sync = $Config['Sync'];
}
else
{
	$Cron = "";
	$Destination = "local";
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
	
	$Port = "22";
	$RemoteDir = "/snapshot";
	$Email = "";
	$Account = "";
	$ShareName = "";
}

if ($RemoteDir=="")
{
	$RemoteDir="/snapshot";
}

if ($Cron=="0 0 */1 * *")
{
	$DailySelected="selected";
}
elseif ($Cron=="0 0 */2 * *")
{
	$TwoSelected="selected";
}
elseif ($Cron=="0 0 */3 * *")
{
	$ThereSelected="selected";
}
elseif ($Cron=="0 0 */4 * *")
{
	$FourSelected="selected";
}
elseif ($Cron=="0 0 */5 * *")
{
	$FiveSelected="selected";
}
elseif ($Cron=="0 0 */6 * *")
{
	$SixSelected="selected";
}
elseif ($Cron=="0 0 * * 6")
{
	$SATSelected="selected";
}
elseif ($Cron=="0 0 * * 0")
{
	$SUNSelected="selected";
}
elseif ($Cron=="0 0 * * 1")
{
	$MONSelected="selected";
}
elseif ($Cron=="0 0 * * 2")
{
	$TUESelected="selected";
}
elseif ($Cron=="0 0 * * 3")
{
	$WEDSelected="selected";
}
elseif ($Cron=="0 0 * * 4")
{
	$THUSelected="selected";
}
elseif ($Cron=="0 0 * * 5")
{
	$FRISelected="selected";
}
elseif ($Cron=="0 0 * * 2,6")
{
	$SatTueSelected="selected";
}
elseif ($Cron=="0 0 * * 0,3")
{
	$SunWedSelected="selected";
}
elseif ($Cron=="0 0 * * 1,4")
{
	$MonThuSelected="selected";
}
elseif ($Cron=="0 0 1 * *")
{
	$MonthlySelected="selected";
}

if ($Port=="")
{
	$Port="22";
}

echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
<input type=hidden name=ControlID value='$ControlID'>

<div class='DivInput {$Dir}DivInput'>Snapshot Interval<br>
<select name='Cron' class=Select>
<option value=''>Disable Snapshot</option>
<option value='0 0 */1 * *' $DailySelected>Daily</option>
<option value='0 0 */2 * *' $TwoSelected>2 Days</option>
<option value='0 0 */3 * *' $ThereSelected>3 Days</option>
<option value='0 0 */4 * *' $FourSelected>4 Days</option>
<option value='0 0 */5 * *' $FiveSelected>5 Days</option>
<option value='0 0 */6 * *' $SixSelected>6 Days</option>
<option value='0 0 * * 6' $SATSelected>Sat</option>
<option value='0 0 * * 0' $SUNSelected>Sun</option>
<option value='0 0 * * 1' $MONSelected>Mon</option>
<option value='0 0 * * 2' $TUESelected>Tue</option>
<option value='0 0 * * 3' $WEDSelected>Wed</option>
<option value='0 0 * * 4' $THUSelected>Thu</option>
<option value='0 0 * * 5' $FRISelected>Fri</option>
<option value='0 0 * * 2,6' $SatTueSelected>Sat & Tue</option>
<option value='0 0 * * 0,3' $SunWedSelected>Sun & Wed</option>
<option value='0 0 * * 1,4' $MonThuSelected>Mon & Thu</option>
<option value='0 0 1 * *' $MonthlySelected>Monthly</option>
</select>
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

<div class=DivInput id=Port>{$LNG['Port']}<br>
<input type='text' name='Port' value='{$Port}' maxlength=5 class=InputText>
</div>

<div class=DivInput id=RemoteDir>{$LNG['RemoteDir']}<br>
<input type='text' name='RemoteDir' value='{$RemoteDir}' maxlength=100 class=InputText>
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
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Snapshot')\">{$LNG['SnapshotStatus']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=SnapshotStamp')\">{$LNG['SnapshotDate']}</a>
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
	$Snapshot=$Row['Snapshot'];
	
	$SnapshotStamp=intval($Row['SnapshotStamp']);
	
	if ($SnapshotStamp>=1)
	{
		$SnapshotDate=date("D j M Y g:i a",$SnapshotStamp);
	}
	else
	{
		$SnapshotDate="-";
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
	
	if ($Snapshot==1)
	{
		$SnapshotCode="✔";
	}
	else
	{
		$SnapshotCode="✖";
	}
	
	
	if ($Snapshot==1)
	{
		$SnapshotStatus= "
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=DisableSnapshot&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
	}
	else
	{
		$SnapshotStatus="
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=EnableSnapshot&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
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
	$SnapshotCode
	</td>
	
	<TD>
	$SnapshotDate
	</td>
	
	<TD>
	$SpaceUsed
	</td>
	
	<TD align='$OAlign'>
	$SnapshotStatus
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