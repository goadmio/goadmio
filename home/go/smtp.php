<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Edit=$_REQUEST['Edit'];
$Delete=$_REQUEST['Delete'];
$Step=$_REQUEST['Step'];

$SMTPID=intval($_REQUEST['SMTPID']);

$SMTPHost=trim($_REQUEST['SMTPHost']);
$SMTPPort=intval($_REQUEST['SMTPPort']);
$SMTPUser=trim($_REQUEST['SMTPUser']);
$SMTPPass=trim($_REQUEST['SMTPPass']);

$Action=trim($_REQUEST['Action']);
$Active=intval($_REQUEST['Active']);
$Priority=intval($_REQUEST['Priority']);


if ($Priority>=1)
{

	SQL("update SMTP set Priority=$Priority where SMTPID='$SMTPID'");
	
	$Priority=0;
	$Result = SQL("select * from SMTP ORDER BY Priority");
	foreach ($Result as $Row)
	{
	$Priority=$Priority+10;
	$SMTPID=$Row['SMTPID'];
	SQL("update SMTP set Priority=$Priority where SMTPID='$SMTPID'");	
	}
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


if ($Action=="Auth")
{

	if ($_REQUEST['SMTPAuth']=="yes")
	{
		SQL("update Config set SMTPAuth='no' where ConfigID=1");	
	}
	else
	{
		SQL("update Config set SMTPAuth='yes' where ConfigID=1");	
	}
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


if ($Action=="Active")
{

	if ($_REQUEST['Active']=="1")
	{
		SQL("update SMTP set Active=0 where SMTPID='$SMTPID'");	
	}
	else
	{
		SQL("update SMTP set Active=1 where SMTPID='$SMTPID'");
	}
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


If ($Delete==1 and $Step==1)
{

	echo Error("Delete SMTP Hostname \"{$SMTPHost}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&SMTPID={$_REQUEST['SMTPID']}&SMTPHost={$_REQUEST['SMTPHost']}&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
	SQL("DELETE FROM SMTP WHERE SMTPID='$SMTPID'");
	echo Error("SMTP Hostname \"$SMTPHost\" has been deleted.");
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	exit;
	
}

if ($SMTPHost!="" and $SMTPPort>=1)
{	
	include "access.php";

	if ($Edit==1)
	{

		$Result = SQL("select * from SMTP where SMTPHost='$SMTPHost' and SMTPPort='$SMTPPort' AND SMTPID!='$SMTPID'");
		foreach ($Result as $Row)
		{
			echo Error("Hostname \"$SMTPHost\" already exists.");
			echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
			exit;
		}
	
		SQL("UPDATE SMTP SET SMTPHost='$SMTPHost',SMTPPort='$SMTPPort',SMTPUser='$SMTPUser',SMTPPass='$SMTPPass',SMTPStatus='-1' where SMTPID='$SMTPID'");
		echo Error("SMTP Hostname \"$SMTPHost\" Edited Successfully.");
	}
	else
	{
	
		$Result = SQL("select * from SMTP where SMTPHost='$SMTPHost' and SMTPPort='$SMTPPort'");
		foreach ($Result as $Row)
		{
			echo Error("Hostname \"$SMTPHost\" already exists.");
			echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
			exit;
		}
	
		$Priority=time();
		SQL("INSERT INTO SMTP (SMTPHost,SMTPPort,SMTPUser,SMTPPass,Priority,SMTPStatus) VALUES ('$SMTPHost','$SMTPPort','$SMTPUser','$SMTPPass','$Priority','-1')");
		echo Error("SMTP Hostname \"$SMTPHost\" Created Successfully.");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	exit;
	
}


	if ($Edit==1)
	{
		$Result = SQL("select * from SMTP where SMTPID='$SMTPID'");
		foreach ($Result as $Row)
		{
		$SMTPHost=$Row['SMTPHost'];
		$SMTPPort=$Row['SMTPPort'];
		$SMTPUser=$Row['SMTPUser'];
		$SMTPPass=$Row['SMTPPass'];
		}
		
	}


echo "
<div class=NavigatorInfo>
Route outgoing email through an external SMTP server (also known as a smart host) to improve deliverability. Get free SMTP from <a href=\"https://www.brevo.com\" target=\"_blank\" rel=\"noopener noreferrer\">Brevo</a>, <a href=\"https://www.sendpulse.com\" target=\"_blank\" rel=\"noopener noreferrer\">SendPulse</a>. You can add many SMTP relays; if one fails, the next one will run. To make the server send via local SMTP, remove or deactivate all SMTP relay services.
</div>
";

	if ($SMTPHost=="")
	{
		$SMTPHost="localhost";
	}
	
	if (intval($SMTPPort)==0)
	{
		$SMTPPort="587";
	}

	$Result = SQL("select SMTPAuth from Config WHERE ConfigID=1");
	foreach ($Result as $Row)
	{
		$SMTPAuth=$Row['SMTPAuth'];
		
		if ($SMTPAuth=="yes")
		{
		$SMTPAuthChecked="checked";
		}
	
	
	}




	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=SMTPID value='$SMTPID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPHostname']}<br>
	<input type='text' name='SMTPHost' id='SMTPHost' value='$SMTPHost' maxlength=255 required class=InputText>
	</div>


	<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPPort']}<br>
	<input type='text' name='SMTPPort' value='$SMTPPort' maxlength=5 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPUsername']}<br>
	<input type='text' name='SMTPUser' value='$SMTPUser' maxlength=255 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['SMTPPassword']}<br>
	<input type='text' name='SMTPPass' value='$SMTPPass' maxlength=1000 class=InputText>
	</div>


	<div id=DivSubmit class=DivSubmit>
	";

	if ($Edit==1)
	{
		echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		echo "<input type=submit value='{$LNG['Save']}' Class=InputButton>";
	}

	Echo "
	</div>

</form>



<div class=DivCheckbox>

	<label class=LabelCheckbox onclick=\"javascript:Load('$CurrentFileName?Action=Auth&SMTPAuth=$SMTPAuth&Page=$Page&ScrollTo=TR{$ID}')\">Enable SMTP Authentication
		<input type='checkbox' name='SMTPAuth' id='SMTPAuth' value='yes' $SMTPAuthChecked>
		<span class='Checkbox'></span>
	</label>

</div>





		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='18%'>
		{$LNG['SMTPHostname']}
		</th>
		
		<th align='$DAlign' width='5%'>
		{$LNG['SMTPPort']}
		</th>
		
		<th align='$DAlign' width='18%'>
		{$LNG['SMTPUsername']}
		</th>
		
		<th align='$DAlign' width='18%'>
		{$LNG['SMTPPassword']}
		</th>
		
		<th align='$DAlign' width='10%'>
		{$LNG['Active']}
		</th>
		
		<th align='$OAlign' width='10%'>
		Priority
		</th>

		<th align='$OAlign' width='6%'>
		Status
		</th>

		<th align='$OAlign' width='15%'>
		
		</th>

 		</THEAD>
		";
		
		$Table="SMTP";$Field="SMTPID>=1";
		$DefaultSortBy="Priority";
		$DefaultDirection="ASC";
		include "include/sql.php";

		$Priority=0;
		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
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

			if ($Row['Active']==1)
			{
			$ActiveCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Active&Active={$Row['Active']}&SMTPID={$Row['SMTPID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$ActiveCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Active&Active={$Row['Active']}&SMTPID={$Row['SMTPID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
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

			echo "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

			<TD><input value='{$Row['SMTPHost']}' class='InputZ'></TD>
			<TD><input value='{$Row['SMTPPort']}' class='InputZ'></TD>
			<TD><input value='{$Row['SMTPUser']}' class='InputZ'></TD>
			<TD><input value='{$Row['SMTPPass']}' class='InputZ'></TD>
			
			<TD>$ActiveCode</TD>
			
			<TD title='{$Row['Priority']}'>
			";
			
			if ($Priority!=0)
			{
			echo "<a href=\"javascript:Load('$CurrentFileName?Priority=$Priority&SMTPID={$Row['SMTPID']}')\" class=Action>Up</a>";
			}
			
			echo "
			</TD>

			<TD align='center'>$StatusCode</TD>

			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&SMTPID={$Row['SMTPID']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&SMTPID={$Row['SMTPID']}&SMTPHost={$Row['SMTPHost']}')\" class=Action>Delete</a>

			</TD> 
			";
			
			$Priority=$Row['Priority']-5;
			
		$X++;
		}
			
		if ($X!=0)
		{
		echo "</TBODY>";
		}

		echo "
		</TABLE>
		</div>
		";
		
?>