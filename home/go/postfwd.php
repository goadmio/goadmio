<?php
include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Restore&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
include "title.php";

$Action=$_REQUEST['Action'];
$SiteID=$_REQUEST['SiteID'];
$Domain=$_REQUEST['Domain'];

if ($Action=="Enable")
{
	SQL("UPDATE Site SET PostfwdIgnore='1' where SiteID='$SiteID'");
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}

if ($Action=="Disable")
{
	SQL("UPDATE Site SET PostfwdIgnore='0' where SiteID='$SiteID'");
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}

if ($Action=="Restore")
{
	SQL("UPDATE Config SET ServerLimit='10000',ExternalLimit='5000',DomainLimit='250',UserLimit='20'");
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}


$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
$MyNetworks=$Row['MyNetworks'];
$ExternalLimit=$Row['ExternalLimit'];
$ServerLimit=$Row['ServerLimit'];
$DomainLimit=$Row['DomainLimit'];
$UserLimit=$Row['UserLimit'];
$SMTPDelay=$Row['SMTPDelay'];
$QueueNo=$Row['QueueNo'];
}


Echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>MyNetworks<br>
<input type='text' value='$MyNetworks' id='MyNetworks' onchange=\"Config('MyNetworks',encodeURI(document.getElementById('MyNetworks').value))\" class=InputText> Separate IPs with a single space
</div>

<div class='DivInput {$Dir}DivInput'>Server Rate Limit<br>
<input type='text' value='$ServerLimit' id='ServerLimit' onchange=\"Config('ServerLimit',encodeURI(document.getElementById('ServerLimit').value))\" class=InputText> / Emails Day
</div>

<div class='DivInput {$Dir}DivInput'>External IPs Rate Limit<br>
<input type='text' value='$ExternalLimit' id='ExternalLimit' onchange=\"Config('ExternalLimit',encodeURI(document.getElementById('ExternalLimit').value))\" class=InputText> / Emails Day (0 = Unlimited)
</div>

<div class='DivInput {$Dir}DivInput'>Domain Rate Limit<br>
<input type='text' value='$DomainLimit' id='DomainLimit' onchange=\"Config('DomainLimit',encodeURI(document.getElementById('DomainLimit').value))\" class=InputText> / Emails Day (0 = Unlimited)
</div>

<div class='DivInput {$Dir}DivInput'>User Rate Limit<br>
<input type='text' value='$UserLimit' id='UserLimit' onchange=\"Config('UserLimit',encodeURI(document.getElementById('UserLimit').value))\" class=InputText> / Emails Hour (0 = Unlimited)
</div>

<div class='DivInput {$Dir}DivInput'>Inter-Message Delay<br>
<input type='text' value='$SMTPDelay' id='SMTPDelay' onchange=\"Config('SMTPDelay',encodeURI(document.getElementById('SMTPDelay').value))\" class=InputText> / Emails Second (0 = No Delay)
</div>

<div class='DivInput {$Dir}DivInput'>Email Outbound Queue Alerts:<br>
<input type='text' value='$QueueNo' id='QueueNo' onchange=\"Config('QueueNo',encodeURI(document.getElementById('QueueNo').value))\" class=InputText>
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

<TH align='$DAlign' width='30%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
</TH>

<TH align='$DAlign' width='30%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=PostfwdDomainLimit')\">Domain Limit / Emails Day</a>
</TH>

<TH align='$DAlign' width='30%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=PostfwdUserLimit')\">User Limit / Emails Hour</a>
</TH>

<TH align='center' width='10%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=PostfwdIgnore')\">Custom Rate Limiting</a>
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
	$ID=$Row['SiteID'];
	
	$Domain=$Row['Domain'];
	$PostfwdIgnore=$Row['PostfwdIgnore'];

	$PostfwdDomainLimit=$Row['PostfwdDomainLimit'];
	$PostfwdUserLimit=$Row['PostfwdUserLimit'];
	
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
	
	if ($PostfwdIgnore==1)
	{
		$StatusCode="✔";
	}
	else
	{
		$StatusCode="✖";
	}
	
	
	if ($PostfwdIgnore==1)
	{
		$PostfwdIgnoreCode= "
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Disable&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
	}
	else
	{
		$PostfwdIgnoreCode="
		<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Enable&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
	}
		
	echo "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>
	
	<TD>
	<a href='http://{$Row['Domain']}' target='_blank'>{$Row['Domain']}</a>
	</td>
	
	<TD>
	";

	if ($PostfwdIgnore==1)
	{
	echo "
	<input type='text' id='PostfwdDomainLimit{$SiteID}' value='$PostfwdDomainLimit' onchange=\"Setting('PostfwdDomainLimit','$SiteID',encodeURI(document.getElementById('PostfwdDomainLimit{$SiteID}').value),'PostfwdDomainLimit{$SiteID}')\" class=InputZ>
    ";
	}
	else
	{
	echo "
	<input type='text' value='$DomainLimit' readonly class=InputZ>
    ";
	}

	echo "
	</td>

	<TD>
	";

	if ($PostfwdIgnore==1)
	{
	echo "
	<input type='text' id='PostfwdUserLimit{$SiteID}' value='$PostfwdUserLimit' onchange=\"Setting('PostfwdUserLimit','$SiteID',encodeURI(document.getElementById('PostfwdUserLimit{$SiteID}').value),'PostfwdUserLimit{$SiteID}')\" class=InputZ>
    ";
	}
	else
	{
	echo "
	<input type='text' value='$UserLimit' readonly class=InputZ>
    ";
	}

	echo "
	</td>
	
	<TD align='center'>
	$PostfwdIgnoreCode
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