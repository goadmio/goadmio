<?php
include "navigator.php";
$Buttons="";
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

$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

echo "
<div class='NavigatorInfo'>	
This feature allows each domain on your server to send emails <strong>through Roundcube webmail</strong> using its own custom SMTP configuration. Enter your custom SMTP details (host, port, username, password) and when sending emails via Roundcube webmail, that domain will use its dedicated SMTP relay. To send via Roundcube, SnappyMail, Outlook, and all email client apps using a custom SMTP configuration, use <a href=\"javascript:Load('custom-smtp.php')\">Custom SMTP Relay</a> instead. Get free SMTP from: <a href='https://www.brevo.com' target='_blank' rel='noopener noreferrer'>Brevo</a> (300/day), <a href='https://www.sendpulse.com' target='_blank' rel='noopener noreferrer'>SendPulse</a> (15k/month). You must verify your domain and set up SPF/DKIM for any custom SMTP service.
</div>
";
    
	include "search.php";
	
	Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='25%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=RoundcubeSMTPHost')\">SMTP Hostname</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=RoundcubeSMTPUser')\">SMTP Username</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=RoundcubeSMTPPass')\">SMTP Password</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=RoundcubeSMTPPort')\">SMTP Port</a>
    </TH>
	
    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPAuth')\">SMTP Auth</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=RoundcubeSMTPAuth')\">Active</a>
    </TH>

	</tr>
	
	</THEAD>
	";
	
	// SMTP Auth (Cannot be custom for every domaon its yes or no for all server and domains
	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
		$SMTPAuth=$Row['SMTPAuth'];
	}

	
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

	$RoundcubeSMTPHost=$Row['RoundcubeSMTPHost'];
	$RoundcubeSMTPUser=$Row['RoundcubeSMTPUser'];
	$RoundcubeSMTPPass=$Row['RoundcubeSMTPPass'];
	$RoundcubeSMTPPort=$Row['RoundcubeSMTPPort'];
	$RoundcubeSMTPActive=$Row['RoundcubeSMTPActive'];

		
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
		


		if ($Row['RoundcubeSMTPActive']==1)
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('RoundcubeSMTPActive','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPActive{$SiteID}').checked),'RoundcubeSMTPActive{$SiteID}')\">
		<input type='checkbox' id='RoundcubeSMTPActive{$SiteID}' value='1' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('RoundcubeSMTPActive','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPActive{$SiteID}').checked),'RoundcubeSMTPActive{$SiteID}')\">
		<input type='checkbox' id='RoundcubeSMTPActive{$SiteID}' value='1'>
		<span></span>
		</label>	
		";
		}




    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    {$Row['Domain']}
    </td>

	<TD>
	<input type='text' id='RoundcubeSMTPHost{$SiteID}' value='$RoundcubeSMTPHost' placeholder='smtp.yourdomain.com' onchange=\"Setting('RoundcubeSMTPHost','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPHost{$SiteID}').value),'RoundcubeSMTPHost{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='RoundcubeSMTPUser{$SiteID}' value='$RoundcubeSMTPUser' placeholder='user@yourdomain.com' onchange=\"Setting('RoundcubeSMTPUser','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPUser{$SiteID}').value),'RoundcubeSMTPUser{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='RoundcubeSMTPPass{$SiteID}' value='$RoundcubeSMTPPass' placeholder='SMTP password' onchange=\"Setting('RoundcubeSMTPPass','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPPass{$SiteID}').value),'RoundcubeSMTPPass{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='RoundcubeSMTPPort{$SiteID}' value='$RoundcubeSMTPPort' placeholder='SMTP Port' onchange=\"Setting('RoundcubeSMTPPort','$SiteID',encodeURI(document.getElementById('RoundcubeSMTPPort{$SiteID}').value),'RoundcubeSMTPPort{$SiteID}')\" class=InputZ>
    </td>
	
	<TD>
	<input type='text' value='$SMTPAuth' readonly class=InputZ>
    </td>

	<TD>
	$ActiveCode
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



	<th align='$DAlign' colspan=3>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=3>
	";
			
	include "pages.php";

	echo "
	</th>



	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
		
?>