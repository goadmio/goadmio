<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$Resource=$_REQUEST['Resource'];

if ($_SESSION['SessionType']!="Root")
{

	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	
}

if ($Resource!="")
{
	include "access.php";
	
	SQL("UPDATE Config SET Resource='$Resource' WHERE ConfigID=1");

	if ($Resource=="Unlimited")
	{
		SQL("UPDATE Config SET MemoryLimit='100',CPULimit='100' WHERE ConfigID=1");
		SQL("UPDATE MariaDB SET MAX_USER_CONNECTIONS='0',MAX_QUESTIONS='0',MAX_UPDATES='0'");
	}
	
	if ($Resource=="Standard") 
	{
		SQL("UPDATE Config SET MemoryLimit='50',CPULimit='50' WHERE ConfigID=1");
		SQL("UPDATE MariaDB SET MAX_USER_CONNECTIONS='100',MAX_QUESTIONS='150000',MAX_UPDATES='30000'");
	}

	if ($Resource=="Starter") 
	{
		SQL("UPDATE Config SET MemoryLimit='25',CPULimit='25' WHERE ConfigID=1");
		SQL("UPDATE MariaDB SET MAX_USER_CONNECTIONS='50',MAX_QUESTIONS='50000',MAX_UPDATES='10000'");
	}

	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/slice'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	// /go/slice will run next command
	// /go/mariadbquota
	
}

if ($Action!="")
{
	include "access.php";

	if ($Action=="Enable")
	{
	
		$Error=SSH ("/usr/bin/sudo /go/quota on",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	else
	{
	
		$Error=SSH ("/usr/bin/sudo /go/quota off",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	
}
    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>	
	";
	
    $Result = SQL("SELECT * FROM MariaDB");
    foreach ($Result as $Row)
    {
		$MAX_USER_CONNECTIONS=$Row['MAX_USER_CONNECTIONS'];
		$MAX_QUESTIONS=$Row['MAX_QUESTIONS'];
		$MAX_UPDATES=$Row['MAX_UPDATES'];
	}
	
	
	$Table="Config";$Field="ConfigID=1";
	$DefaultSortBy="ConfigID";
	$DefaultDirection="ASC";
	include "include/sql.php";    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$Resource=$Row['Resource'];
		if ($Resource=="Unlimited") {$UnlimitedChecked="checked";}
		if ($Resource=="Standard") {$StandardChecked="checked";}
		if ($Resource=="Starter") {$StarterChecked="checked";}
		
		$Quota=$Row['Quota'];
		$MemoryLimit=$Row['MemoryLimit'];
		$CPULimit=$Row['CPULimit'];
		
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
	
	if ($Quota==1)
	{	
	$QuotaStatus="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	$QuotaStatus="
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>
	";
	
	}
	
	echo "


	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    Resources
    </td>
	
	<TD align='$OAlign'>

			
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Resource=Unlimited')\" $UnlimitedChecked>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				Unlimited
				</span>
			</label>
			
			
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Resource=Standard')\" $StandardChecked>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				Standard (Shared Hosting)
				</span>
			</label>
			
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Resource=Starter')\" $StarterChecked>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				Starter (Personal Websites)
				</span>
			</label>


	</td>

	</tr>

	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    {$LNG['QuotaStatus']}
    </td>
	
	<TD align='$OAlign'>
	$QuotaStatus
	</td>



	</tr>
	
	
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    Memory  Limit
    </td>
	
	<TD align='$OAlign'>
	<input type='text' id='MemoryLimit' value='$MemoryLimit' onchange=\"Config('MemoryLimit',document.getElementById('MemoryLimit').value)\" class=InputZ style='width:75px;text-align:right'>%
	</td>
	
	</tr>
	    
	</tr>
	
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    CPU  Limit
    </td>
	
	<TD align='$OAlign'>
	<input type='text' id='CPULimit' value='$CPULimit' onchange=\"Config('CPULimit',document.getElementById('CPULimit').value)\" class=InputZ style='width:75px;text-align:right'>%
	</td>
	
	</tr>

	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    MAX_USER_CONNECTIONS
    </td>
	
	<TD align='$OAlign'>
	<input type='text' id='MAX_USER_CONNECTIONS' value='$MAX_USER_CONNECTIONS' onchange=\"Config('MAX_USER_CONNECTIONS',document.getElementById('MAX_USER_CONNECTIONS').value)\" class=InputZ style='width:75px;text-align:right'>
	</td>
	
	</tr>

	
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    MAX_QUERIES / HOUR (How many queries a user can execute per hour)
    </td>
	
	<TD align='$OAlign'>
	<input type='text' id='MAX_QUESTIONS' value='$MAX_QUESTIONS' onchange=\"Config('MAX_QUESTIONS',document.getElementById('MAX_QUESTIONS').value)\" class=InputZ style='width:75px;text-align:right'>
	</td>
	
	</tr>
	
	
		
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

	<TD>
    MAX_UPDATES / HOUR
    </td>
	
	<TD align='$OAlign'>
	<input type='text' id='MAX_UPDATES' value='$MAX_UPDATES' onchange=\"Config('MAX_UPDATES',document.getElementById('MAX_UPDATES').value)\" class=InputZ style='width:75px;text-align:right'>
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

	</TABLE>
	</div>
	</form>
	";
	
	include "pages.php";


	
?>