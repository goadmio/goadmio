<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$ForwardID=$_REQUEST['ForwardID'];
$User=ValidateUsername($_REQUEST['User']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$Email=ValidateEmail($_REQUEST['Email']);
$ForwardTo=$_REQUEST['ForwardTo'];
$KeepCopy=$_REQUEST['KeepCopy'];
$Reject=$_REQUEST['Reject'];
$RejectMessage=$_REQUEST['RejectMessage'];

If ($Delete==1 and $Step==1)
{
	echo Error("Are you sure you want to delete the email forwarder \"{$Email}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Domain=$Domain&Email=$Email&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{
	include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/forward $Email - - delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
}

if ($_REQUEST['User']!="")
{
	include "access.php";

	$Email=$User."@".$Domain;

	if ($Reject==1)
	{
		SQL ("UPDATE Mail SET Reject=1 WHERE Email='$Email'");
	
		$Error=SSH ("/usr/bin/sudo /go/reject $Email $Domain $RejectMessage",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
		
	}
	else
	{
		SQL ("UPDATE Mail SET Reject=0 WHERE Email='$Email'");
	
		if ($KeepCopy==1)
		{
		SQL ("UPDATE Mail SET KeepCopy=1 WHERE Email='$Email'");
		
		$Error=SSH ("/usr/bin/sudo /go/forward $Email $ForwardTo $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
		}
		else
		{
		SQL ("UPDATE Mail SET KeepCopy=0 WHERE Email='$Email'");
		
		$Error=SSH ("/usr/bin/sudo /go/forward $Email $ForwardTo $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");	
		}
	}
	
}

	if ($Edit==1)
	{
		$Sql = "select * from Mail where Email='$Email'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			$EmailArray=explode("@",$Row['Email']);
			$User=$EmailArray[0];
			
			$Domain=$Row['Domain'];
			
			$MailID=$Row['MailID'];
			
			$ForwardTo=$Row['ForwardTo'];
			
			if ($Row['KeepCopy']==1)
			{
			$KeepCopyChecked="checked";
			}

			if ($Row['Reject']==1)
			{
			$RejectChecked="checked";
			}
				
			
			$RejectMessage=$Row['RejectMessage'];
			
		}
	}

	echo "	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=MailID value='$MailID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	";
	
	if ($Edit==1)
	{
		echo "
		
		<input type='hidden' name='User' value='$User'>
		<input type='hidden' name='Domain' value='$Domain'>
		$User@$Domain
		";
	}
	else
	{
		Echo "
		<input type='Text' name='User' value='$User' maxlength=100 class=InputText style='width:24%'>
		@
		";
		
		unset($Domains);
		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
		
		if (is_array($Domains))
		{
			sort($Domains);
		}
		else
		{
			$Domains[]="";
		}
		
		echo "
		<select name='Domain' id='Domain' class=Select style='width:24%'>
		";
		
		foreach ($Domains as $Domain) 
		{

			if ($PlaceHolderDomain=="")
			{
			$PlaceHolderDomain=$Domain;
			}
		
			if ($Domain==$EmailArray[1])
			{
			echo "<option value='$Domain' selected>$Domain</option>";
			}
			else
			{
			echo "<option value='$Domain'>$Domain</option>";
			}

		}

		echo "</select>";
	}
	
	Echo "</div>

	<div class=DivInput id=ForwardTo>{$LNG['ForwardTo']}<br>
	<input type='text' name='ForwardTo' value='$ForwardTo' placeholder='example1@$PlaceHolderDomain,example2@gmail.com' maxlength=100 class=InputText>
	</div>
	
	<div class=DivCheckbox>
	
		<label class=LabelCheckbox>{$LNG['KeepCopy']}
			<input type='checkbox' name='KeepCopy' id='KeepCopy' value='1' $KeepCopyChecked>
			<span class='Checkbox'></span>
		</label>
		
	</div>

	";

	Echo "
	<div class=DivCheckbox id=KeepCopyTr2>
	
		<label class=LabelCheckbox>{$LNG['DiscardAndSendErrorToTheSender']}
			<input type='checkbox' name='Reject' id='Reject' value='1' onclick=\"SwitchReject()\" $RejectChecked> 
			<span class='Checkbox'></span>
		</label>
		
	</div>

	<div class=DivInput id=RejectMessage style='display:none'>
	Failure Message<br>
	";
	
	if ($RejectMessage=="")
	{
	$RejectMessage="No such person at this address.";
	}
	
	echo "
	<input type='text' name='RejectMessage' value='$RejectMessage' class=InputText maxlength=255> Seen by Sender
	</div>

	<div id=DivSubmit class=DivSubmit>
	";

	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['AddForwarder']}' Class=InputButton>";
	}
		
	Echo "
	</div>

</form>
";
	
	if($Edit!=1)
	{
		include "search.php";

		Echo "
		<div class=DivTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<th align='$DAlign' width='20%'>
		{$LNG['Email']}
		</th>
		
		<th align='$DAlign' width='15%'>
		{$LNG['ForwardTo']}
		</th>
		
		<th align='$DAlign' class='UnderBar' width='15%'>
		{$LNG['Domain']}
		</th>

		<th align='$DAlign' class='UnderBar' width='8%'>
		{$LNG['KeepCopy']}
		</th>
		
		<th align=='$LNG[DAlign]' width='8%'>
		{$LNG['Discard']}
		</th>
		
		<th align='$OAlign' width='20%'>
	
		</th>

		</tr>
		
		</THEAD>
		";
		
		$Table="Mail";$Field="ForwardTo!=''";
		$DefaultSortBy="Email";
		$DefaultDirection="ASC";
		include "include/sql.php";
	
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
			
			$ForwardTo=$Row['ForwardTo'];

			if ($ForwardTo=="")
			{
			$ForwardTo="Discard: {$Row['RejectMessage']}";
			}
			
			if ($Row['KeepCopy']==1)
			{
			$KeepCopyIcon="<img src='image/true.svg' style='width:24px;height:24px;'>";
			}
			else
			{
			$KeepCopyIcon="";
			}
			
			if ($Row['Reject']==1)
			{
			$DiscardIcon="<img src='image/true.svg' style='width:24px;height:24px;'>";
			}
			else
			{
			$DiscardIcon="";
			}
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Domain']}-{$Row['Date']}-{$Row['Time']}-{$Row['IP']}-{$Row['Country']}-{$Row['Descr']}-{$Row['Organization']}-{$Row['FileName']}-{$Row['Mode']}-{$Row['Operation']}-{$Row['Direction']}-{$Row['AccessMode']}-{$Row['Completed']}' class='$TDColor'>

			<TD>{$Row['Email']}</TD>

			<TD>$ForwardTo</TD>
			
			<TD>{$Row['Domain']}</TD>

			<TD align='center'>$KeepCopyIcon</TD>
			
			<TD align='center'>$DiscardIcon</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&ForwardID={$Row['ForwardID']}$&Domain={$Row['Domain']}&Email={$Row['Email']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Domain={$Row['Domain']}&Email={$Row['Email']}')\" class=Action>Delete</a>
			</TD>
			"; 
		
		$X++;
		}
		
		if ($X!=0)
		{
		echo "</TBODY>";
		}

		echo "
		<TFOOT>

		<tr>

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=4>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		";
	
	}

?>