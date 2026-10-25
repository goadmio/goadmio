<?php

include "navigator.php";
$Buttons="";
include "title.php";

$SpamID=intval($_REQUEST['SpamID']);
$CheckList=$_REQUEST['CheckList'];

if ($_SESSION['SessionType']!="Root")
{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	
}


	if ($_REQUEST['ChangeUserLimit']==1)
	{
		$UserLimit=intval($_REQUEST['UserLimit']);
		
		SQL("UPDATE Config SET UserLimit='$UserLimit'");
	
		SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			
	}

	if ($_REQUEST['ChangeSMTPDelay']==1)
	{
		$SMTPDelay=$_REQUEST['SMTPDelay'];
	
		SQL("UPDATE Config SET SMTPDelay='$SMTPDelay'");
		

		$Error=SSH ("postconf -e 'default_destination_rate_delay = {$SMTPDelay}s' && systemctl restart postfix",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			
	}

	if ($_REQUEST['ChangeSPAM']==1)
	{
		$SPAM=$_REQUEST['SPAM'];
		SQL("UPDATE Config SET SPAM='$SPAM'");
		
	}

	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
	$SPAM=$Row['SPAM'];
	$UserLimit=$Row['UserLimit'];
	$SMTPDelay=$Row['SMTPDelay'];
	}




	echo "

	<div id=DivPHPVersion class=DivInput>
	<span class=ColonA>Max hourly emails per user</span>
	<br>
	";
	
	for ($H=0;$H<=60;$H+=5) 
	{
		$OptionName=$H;
		
		if ($H==0)
		{
		$OptionName=$LNG['UnlimitedEmailsPerHour'];
		}
		else
		{
		$OptionName="$H {$LNG['EmailsPerHour']}";
		}
	
		if ($UserLimit==$H)
		{
		echo "
		<label class=Label> $OptionName
			<input type='radio' name='UserLimit' value='$H' checked='checked'>
			<span class='Radio'></span>
		</label>
		";
		}
		else
		{
		echo "
		<label class=Label onclick=\"Load('$CurrentFileName?ChangeUserLimit=1&UserLimit=$H','$ControlID')\"> $OptionName
			<input type='radio' name='UserLimit' value='$H'>
			<span class='Radio RadioRadius'></span>
		</label>
		";
		}
	}
	
	echo "
	</div>
	";







	echo "

	<div id=DivPHPVersion class=DivInput>
	<span class=ColonA>{$LNG['ServerSendOneEmailEvery']}</span>
	<br>
	";
	
	for ($H=0;$H<=60;$H+=10) 
	{
		$OptionName=$H;
		
		if ($H==0)
		{
		$OptionName="{$LNG['NoDelay']} ({$LNG['Recommended']})";
		}
		elseif ($H==60)
		{
		$OptionName="1 {$LNG['Minute']}";
		}
		else
		{
		$OptionName="$H {$LNG['Seconds']}";
		}
	
		if ($SMTPDelay==$H)
		{
		echo "
		<label class=Label> $OptionName
			<input type='radio' name='SMTPDelay' value='$H' checked='checked'>
			<span class='Radio'></span>
		</label>
		";
		}
		else
		{
		echo "
		<label class=Label onclick=\"Load('$CurrentFileName?ChangeSMTPDelay=1&SMTPDelay=$H','$ControlID')\"> $OptionName
			<input type='radio' name='SMTPDelay' value='$H'>
			<span class='Radio RadioRadius'></span>
		</label>
		";
		}
	}
	
	echo "
	</div>
	";

	echo "

	<div id=DivPHPVersion class=DivInput>
	<span class=ColonA>{$LNG['TrackingEvery']}</span>
	<br>
	";
	
	for ($H=0;$H<=6;$H++) 
	{
	
	
		$OptionName=$H;
		
		if ($H==0)
		{
		$OptionName=$LNG['DisableSPAMTracking'];
		}
		
		if ($H==1)
		{
		$OptionName="$H {$LNG['Hour']}";
		}
		elseif ($H>1)
		{
		$OptionName="$H {$LNG['Hours']}";
		}
		
	
		if ($SPAM==$H)
		{
		echo "
		<label class=Label> $OptionName
			<input type='radio' name='SPAM' value='$H' checked='checked'>
			<span class='Radio'></span>
		</label>
		";
		}
		else
		{
		echo "
		<label class=Label onclick=\"Load('$CurrentFileName?ChangeSPAM=1&SPAM=$H','$ControlID')\"> $OptionName
			<input type='radio' name='SPAM' value='$H'>
			<span class='Radio RadioRadius'></span>
		</label>
		";
		}
	}
	
	echo "
	</div>
	";



$Date=date ("Y-m-d");

    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	

	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='30%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Email')\">{$LNG['Email']}</a>
    </TH>
	
    <TH align='$DAlign' width='25%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='25%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Date')\">{$LNG['Date']}</a>
    </TH>

    <TH width='20%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Spam";$Field="SpamID>=1";
	$DefaultSortBy="Date";
	$DefaultDirection="DESC";
	include "include/sql.php";
    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SpamID=$Row['SpamID'];
	$Email=$Row['Email'];
	$Domain=$Row['Domain'];
	$Date=$Row['Date'];
		
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
		

	// $CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
	
    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}-{$Row['Date']}'>

    <TD>
    {$Row['Email']}
    </td>

	<TD>
    {$Row['Domain']}
    </td>

	<TD>
    {$Date}
    </td>
	
	<TD align='$OAlign'>
	
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

	<th align='$DAlign' colspan=2>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=4>
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