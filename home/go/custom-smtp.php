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

if ($_REQUEST['Action']=="GetZoneID")
{

	
	// $Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cloudflare all getzoneid'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);


}

$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

echo "
<div class='NavigatorInfo'>	
This feature allows each domain on your server to send emails through its own custom SMTP configuration. Enter your custom SMTP details (host, port, encryption, username, password) – emails from that domain will use it. Get free SMTP from: <a href='https://www.brevo.com' target='_blank' rel='noopener noreferrer'>Brevo</a> (300/day), <a href='https://www.sendpulse.com' target='_blank' rel='noopener noreferrer'>SendPulse</a> (15k/month). You must verify your domain and set up SPF/DKIM for any custom SMTP service.
";

if ($_SESSION['SessionType'] == "Root")
{
echo "Use <a href=\"javascript:Load('smtp.php')\">{$LNG['GlobalSMTPRelay']}</a> to toggle SMTP Auth.";
}

echo "
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
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPHost')\">SMTP Hostname</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPUser')\">SMTP Username</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPPass')\">SMTP Password</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPPort')\">SMTP Port</a>
    </TH>
	
    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPAuth')\">SMTP Auth</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPStatus')\">Status</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SMTPActive')\">Active</a>
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

	$SMTPHost=$Row['SMTPHost'];
	$SMTPUser=$Row['SMTPUser'];
	$SMTPPass=$Row['SMTPPass'];
	$SMTPPort=$Row['SMTPPort'];
		
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
	

		if ($Row['SMTPActive']==1)
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('SMTPActive','$SiteID',encodeURI(document.getElementById('SMTPActive{$SiteID}').checked),'SMTPActive{$SiteID}')\">
		<input type='checkbox' id='SMTPActive{$SiteID}' value='1' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('SMTPActive','$SiteID',encodeURI(document.getElementById('SMTPActive{$SiteID}').checked),'SMTPActive{$SiteID}')\">
		<input type='checkbox' id='SMTPActive{$SiteID}' value='1'>
		<span></span>
		</label>	
		";
		}


		if ($Row['SMTPStatus']==1) 
		{
			$StatusCode = "<div title='Success' style='width:20px;height:20px;border-radius:50%;background-color:#22c55e;display:inline-block;'></div>";
		} 
		elseif ($Row['SMTPStatus']==0) 
		{
			$StatusCode = "<div title='Failed' style='width:20px;height:20px;border-radius:50%;background-color:#ef4444;display:inline-block;'></div>";
		}
		else
		{
			$StatusCode = "";
		}

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    {$Row['Domain']}
    </td>

	<TD>
	<input type='text' id='SMTPHost{$SiteID}' value='$SMTPHost' placeholder='smtp.yourdomain.com' onchange=\"Setting('SMTPHost','$SiteID',encodeURI(document.getElementById('SMTPHost{$SiteID}').value),'SMTPHost{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='SMTPUser{$SiteID}' value='$SMTPUser' placeholder='user@yourdomain.com' onchange=\"Setting('SMTPUser','$SiteID',encodeURI(document.getElementById('SMTPUser{$SiteID}').value),'SMTPUser{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='SMTPPass{$SiteID}' value='$SMTPPass' placeholder='SMTP password' onchange=\"Setting('SMTPPass','$SiteID',encodeURI(document.getElementById('SMTPPass{$SiteID}').value),'SMTPPass{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='SMTPPort{$SiteID}' value='$SMTPPort' placeholder='SMTP Port' onchange=\"Setting('SMTPPort','$SiteID',encodeURI(document.getElementById('SMTPPort{$SiteID}').value),'SMTPPort{$SiteID}')\" class=InputZ>
    </td>
	
	<TD>
	<input type='text' value='$SMTPAuth' readonly class=InputZ>
    </td>


	<TD align='center'>
	$StatusCode
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