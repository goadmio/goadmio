<?php
include "nav.php";
include "no.php";

$MainMenu.="
<div class='DropdownButton'>

	<button onclick=\"DropdownButton('MainMenu', event)\" class='DropButton'>Bulk Actions</button>	
  
	<div id='MainMenu' class='DropdownButtonContent'>

		<a href=\"javascript:Load('$CurrentFileName?Action=Troubleshoot&Domain={$_SESSION['SessionDomain']}&Page=$Page&ScrollTo=TR{$ID}')\">{$LNG['TroubleshootProblems']}</a>				
		<a href='javascript:Load(\"$CurrentFileName?Action=List&Page=$Page\")'>Show Email Passwords</a> 
		<a href='javascript:Load(\"$CurrentFileName?Action=CreateSnapshot&Page=$Page\")'>{$LNG['CreateSnapshot']}</a> 
		<a href='javascript:Load(\"$CurrentFileName?Action=Outlook&Page=$Page\")'>{$LNG['SendIMAPConfiguration']}</a>

	</div>
  
</div>
";

include "title.php";

$WebmailDomain = preg_replace("/^go\./","",$_SERVER['SERVER_NAME']);

$Date=date ("Y-m-d");

if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	$LogTimeStamp=time()-86400;
	$Result = SQL("select * from Log where Keyword='Outbound SPAM' and TimeStamp>$LogTimeStamp ORDER BY TimeStamp DESC LIMIT 1");
	foreach ($Result as $Row)
	{
		$Subject=$Row['Subject'];
	}
	
	if ($Subject!="")
	{
	echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>$Subject</div>";
	}
	elseif (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') 
	{	
	echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['AccessWebmailDirectly']} <a href='https://$WebmailDomain:2025' target='_blank'>https://$WebmailDomain:2025</a></div>";
	}
	else
	{
	echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['AccessWebmailDirectly']} <a href='http://$IPv4:2024' target='_blank'>http://$IPv4:2024</a></div>";	
	}
}
else
{	
echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['AccessWebmailDirectly']} <a href='https://webmail.{$_SESSION['SessionDomain']}' target='_blank'>https://webmail.{$_SESSION['SessionDomain']}</a></div>";
}

$Domain=ValidateDomain($_REQUEST['Domain']);

$User=ValidateUsername($_REQUEST['User']);
$User=strtolower($User);

$Email=ValidateEmail($_REQUEST['Email']);
$Email=strtolower($Email);

$Pass=ValidatePassword($_REQUEST['Pass']);

$Restore=intval($_REQUEST['Restore']);
$BackupID=trim($_REQUEST['BackupID']);

$Action=$_REQUEST['Action'];


If ($Action=="Config")
{
	include "access.php";

	$Sql = "select * from Mail where Email='$Email'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{ 
		$Domain=$Row['Domain'];
		$Email=$Row['Email'];
		$Pass=$Row['Pass'];
	}
			
	echo "
	<div class=DivXTable>

		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th width='33%' height=40>
		Setting
		</th>
		
		<th width='33%'>
		Value (Recommended - SSL/TLS)
		</th>
		
		<th width='33%'>
		Value (Non-SSL - Not Recommended)
		</th>
		
		</THEAD>
			
		<TBODY>
		
		<tr class='Td'>
		<TD>Username</TD>
		<TD>$Email</TD>
		<TD>$Email</TD>
		
		<tr class='TdB'>
		<TD>Password</TD>
		<TD>$Pass</TD>
		<TD>$Pass</TD>
		
		<tr class='Td'>
		<TD>Incoming Server (IMAP)</TD>
		<TD>imap.$Domain</TD>
		<TD>imap.$Domain</TD>
		
		<tr class='TdB'>
		<TD>IMAP Port</TD>
		<TD>993 (SSL)</TD>
		<TD>143</TD>
		
		<tr class='Td'>
		<TD>POP3 Port (Alt.)</TD>
		<TD>995 (SSL)</TD>
		<TD>110</TD>
		

		<tr class='TdB'>
		<TD>Outgoing Server (SMTP)</TD>
		<TD>smtp.$Domain</TD>
		<TD>smtp.$Domain</TD>
		
		<tr class='Td'>
		<TD>SMTP Port</TD>
		<TD>465 (SSL)</TD>
		<TD>587 (TLS)</TD>
		

		<tr class='TdB'>
		<TD>Authentication</TD>
		<TD>Required (Use same as incoming server)</TD>
		<TD>Required</TD>
		
		</TBODY>
		</TABLE>

	</div>
	";
	
}
	

If ($Action=="List")
{
	include "access.php";
			
	echo "
	<div class=DivXTable>

		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th width='25%' height=40>
		Email
		</th>
		
		<th width='75%'>
		Password
		</th>
		
		</THEAD>
			
		<TBODY>
		";
		
		$X=0;
		
		if ($_SESSION['SessionType']=="Root")
		{
		$Sql = "select * from Mail ORDER BY Email";
		}
		elseif ($_SESSION['SessionType']=="Website")
		{
		$Sql = "select * from Mail where Domain='{$_SESSION['SessionDomain']}' ORDER BY Email";
		}
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
			$Email=$Row['Email'];
			$Pass=$Row['Pass'];
			
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
			<TD>$Email</TD>
			<TD>$Pass</TD>
			";
			
			$X++;
			
		}
		
		echo "
		</TBODY>
		</TABLE>

	</div>
	";
	
}
	
if ($Action=="CreateSnapshot")
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


if ($Action=="Outlook")
{

	if ($_SESSION['SessionType']=="Website")
	{
	$Error=SSH ("/usr/bin/sudo /go/outlook all {$_SESSION['SessionDomain']}",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	}
	else
	{
	$Error=SSH ("/usr/bin/sudo /go/outlook all",$_SESSION['SessionSSHUsename'],$_SESSION['SessionSSHPassword']);
	}
	
	echo Error("Email has been sent");

}

if ($Action=="Troubleshoot")
{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/troubleshoot $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Troubleshooting complete.");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;
}


if ($Action=="Admin")
{

	if ($_REQUEST['Admin']=="1")
	{
		SQL("update Mail set Admin=0 where Email='$Email'");	
	}
	else
	{
		SQL("update Mail set Admin=1 where Email='$Email'");
	}

}

If ($Delete==1 and $Step==1)
{
	echo Error("Delete \"{$Email}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&Domain=$Domain&Username=$Username&Email=$Email&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{
	include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/mail --email $Email --domain $Domain --action delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=Error("$Error");	
}

if ($Action=="suspend" or $Action=="unsuspend")
{
	$Error=SSH ("/usr/bin/sudo /go/mail --email $Email --domain $Domain --action $Action",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	$Error=Error("$Error");	
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

		<th colspan=2 width='100%' height=40>Restore Email Messages ($Email)</th>
		
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
				<TD align='middle'><a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=2&Domain=$Domain&Email=$Email&BackupID=$BackupID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Snapshot</a></TD>
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
	$Error=SSH ("/usr/bin/sudo /go/snapshot $Email $BackupID",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=Error("$Error");	
	}
}

if ($_REQUEST['User']!="")
{

	if ($DemoPassword!="") {echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");exit;}

	$Result = SQL("select Domain,EmailNo from Site where Domain='$Domain'");
	foreach ($Result as $Row)
	{
		$Domain=$Row['Domain'];
		$Username=$Row['Username'];
	
		if ($Row['EmailNo']==-1)
		{
		echo "<div class='UnderTitle'>{$LNG['ThisFeatureHasBeenDisabledYourAdministrator']}</div>";
		exit;
		}
	
	}
	
	include "access.php";

	$Email=$User."@".$Domain;

	if ($Edit==1)
	{
		if ($Email!="" AND $Pass!="" AND $Domain!="")
		{
		$Error=SSH ("/usr/bin/sudo /go/mail --email $Email --pass $Pass --domain $Domain --action edit",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}
	}
	else
	{
		if ($Email!="" AND $Pass!="" AND $Domain!="")
		{
		$TimeStamp=time();
		$Reject=0;
		$KeepCopy=0;
		$Suspend=0;
		$Admin=0;
		$Error=SSH ("/usr/bin/sudo /go/mail --email '$Email' --pass '$Pass' --forwardto '$ForwardTo' --reject '$Reject' --rejectmessage '$RejectMessage' --keepcopy '$KeepCopy' --domain '$Domain' --defaultaddress '$DefaultAddress' --suspend '$Suspend' --admin '$Admin' --description '$Description' --timestamp '$TimeStamp' --action add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}
		
	}
	
	$Error=Error("$Error");
	
	$Edit="";
	
}

	$User="";
	$Pass="";
	if ($Edit==1)
	{
		$Sql = "select * from Mail where Email='$Email'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
			$EmailArray=explode("@",$Row['Email']);
			$User=$EmailArray[0];
			$Domain=$EmailArray[1];
			
			$Pass="";

		}
		
		if ($_SESSION['SessionPassword']=="demo")
		{
		$Password="********";
		}
		
	}

	$Result = SQL("select * from Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
	$Account['Domain'][]=$Row['Domain'];
	$Account['Username'][]=$Row['Username'];
	}
	
	if (is_array($Account['Domain']))
	{
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);
	

		$SelectDomain.="<select name='Domain' id='Domain' class=Select style='width:24%'>";
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

	}
	else
	{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;


	if($Edit!=1)
	{
	
		include "search.php";

		$Header=DesignCode($Header,"$Control (Header)");
		echo $Header;

		$Table="Mail";$Field="Trash=0";
		$DefaultSortBy="Email";
		$DefaultDirection="ASC";
		include "include/sql.php";
		
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			$MailID=$Row['MailID'];
			$Domain=$Row['Domain'];
			$Username=$Row['Username'];
			
			$SentToday=$Row['SentToday'];
			$SentThisWeek=$Row['SentThisWeek'];

			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}
			
			if ($Row['Suspend']==1)
			{
			$TDColor="TdEr";
			}
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			if ($Row['TimeStamp']>=1)
			{
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
			}


			if ($Row['Admin']==1)
			{
			$AdminCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Admin&Admin={$Row['Admin']}&Domain={$Row['Domain']}&Email={$Row['Email']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$AdminCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Admin&Admin={$Row['Admin']}&Domain={$Row['Domain']}&Email={$Row['Email']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}


			if ($Row['Suspend']==0)
			{
			$SuspendCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=suspend&Domain=$Domain&Username=$Username&Email={$Row['Email']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$SuspendCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=unsuspend&Domain=$Domain&Username=$Username&Email={$Row['Email']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}

			echo DesignCode($Loop,"$Control (Loop)");
			
			
			$X++;
			
		}
		


		$Footer=DesignCode($Footer,"$Control (Footer)");
		echo $Footer;
		
		
		
	}


echo "
</div>
";

	
?>