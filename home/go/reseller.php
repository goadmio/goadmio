<?php
include "navigator.php";

if ($_SESSION['SessionUsername']!="root")
{
	if ($_SESSION['SessionResellerUsername']=="")
	{
	echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature has been disabled by your administrator.</div>";
	exit;
	}
}

$Buttons="";
include "title.php";

$Edit=$_REQUEST['Edit'];

$UserID=intval($_REQUEST['UserID']);
$Username=ValidateUsername($_REQUEST['Username']);
$Password=ValidatePassword($_REQUEST['Password']);
$Email=ValidateEmail($_REQUEST['Email']);
$ResellerDiskSpace=intval($_REQUEST['ResellerDiskSpace']);
$ResellerAccounts=intval($_REQUEST['ResellerAccounts']);

If ($Delete==1 and $Step==1)
{
	echo Error("Delete Reseller \"{$Username}\"? <a href=\"javascript:Load('$CurrentFileName?Delete=1&UserID=$UserID&Username=$Username&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName')\" class=Action>No</a>");
	exit;
}

if ($Delete==1 and $Step==2)
{

	$DomainNo=0;
	$Result = SQL("select * from Site where UserID='$UserID'");
	foreach ($Result as $Row)
	{
		$DomainNo++;
		$Domains.="\r\n{$Row['Domain']}";
	}

	if ($DomainNo==0)
	{

		$Result = SQL("DELETE from User where UserID!=1 and UserID='$UserID' and (CreatedBy='1' or CreatedBy='{$_SESSION['SessionUserID']}')");
		If ($Result)
		{
			echo Error("Reseller $Username has been deleted.");
		}
	}
	else
	{
		echo Error("Sorry can not remove reseller $Username. There are $DomainNo domain(s) under this reseller:$Domains");
	}
}
elseif ($Username!="" and $Email!="")
{
	if ($Edit==1)
	{
	
		$Result = SQL("UPDATE User SET Username='$Username',Email='$Email',ResellerDiskSpace='$ResellerDiskSpace',ResellerAccounts='$ResellerAccounts' where UserID!=1 and UserID='$UserID' and (CreatedBy='1' or CreatedBy='{$_SESSION['SessionUserID']}')");
		If ($Result)
		{
		
			include "include/remain.php";
			// IF over accounts afetr update
			if ($RemainAccounts<0 and $_SESSION['SessionUserID']!=1)
			{
				SQL ("UPDATE User SET ResellerAccounts=ResellerAccounts+$RemainAccounts where UserID!=1 and UserID='$UserID' and (CreatedBy='1' or CreatedBy='{$_SESSION['SessionUserID']}')");
			}
		
			if (trim($Password!=""))
			{
				$Password=md5($Password);
				SQL("UPDATE User SET Password='$Password' where UserID!=1 and UserID='$UserID' and (CreatedBy='1' or CreatedBy='{$_SESSION['SessionUserID']}')");
			}
		
			echo Error("Reseller $Username updated successfully.");
		}

		$Edit="";
	}
	else
	{
		include "include/remain.php";
		if ($ResellerAccounts>$RemainAccounts and $_SESSION['SessionUserID']!=1)
		{
		$KeepData=1;
		echo Error("You only have $RemainAccounts account(s) left.");
		}
		else
		{
			$Password=md5($Password);
			$TimeStamp=time();	

			$UserID=SQL("INSERT INTO User (Username,UserGroup,Password,Email,ResellerDiskSpace,ResellerAccounts,CreatedBy,TimeStamp) VALUES ('$Username','2','$Password','$Email','$ResellerDiskSpace','$ResellerAccounts','{$_SESSION['SessionUserID']}','$TimeStamp')");
			If ($UserID>=1)
			{
				echo Error("Reseller $Username created successfully");
			}
		}
	}
	
}

	if ($KeepData!=1)
	{
	$Username="";
	$Password="";
	$Email="";
	$ResellerDiskSpace="";
	$ResellerAccounts="";
	}
	
	if ($Edit==1)
	{
		$Result = SQL("select * from User where UserID='$UserID'");
		foreach ($Result as $Row)
		{
		
			$UserID=$Row['UserID'];
			$Username=$Row['Username'];
			$Email=$Row['Email'];
			$ResellerDiskSpace=$Row['ResellerDiskSpace'];
			$ResellerAccounts=$Row['ResellerAccounts'];

		}
	}

	echo "
	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=UserID value='$UserID'>

	<div class='TitleB {$Dir}TitleB'>
	{$LNG['CreateResellerAccount']}
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Username']}<br>
	<input type='text' name='Username' value='$Username' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Password']}
	<br>
	<input type='text' name='Password' value='$Password' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	<input type='email' name='Email' value='$Email' maxlength=100 class='InputText' required>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['ResellerDiskSpace']}<br>
	<input type='text' name='ResellerDiskSpace' value='$ResellerDiskSpace' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['AccountCreationLimits']}<br>
	<input type='text' name='ResellerAccounts' value='$ResellerAccounts' maxlength=100 class=InputText>
	</div>
	";

	echo "
	<div id=DivSubmit class=DivSubmit>
	";
	
	
	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
	}

	Echo "
	
	</div>
	
</form>
";


	if($Edit!=1)
	{
	
		include "search.php";

		Echo "
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th align='$DAlign' width='40%' height=40>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Username')\">Username</a>
		</th>
		
		<th align='$DAlign' width='30%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=ResellerAccounts')\">Reseller Accounts</a>
		</th>

		<th width='30%'>
		
		</span>
		</th>

		</tr>
		
		</THEAD>

		";
			
		$Table="User";$Field="UserID>=1";
		$DefaultSortBy="Username";
		$DefaultDirection="ASC";
		include "include/sql.php";
		
		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
			$UserID=$Row['UserID'];
			$Email=$Row['Email'];
		
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
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Email']}' class='$TDColor'>

			<TD>{$Row['Username']}</TD>

			<TD>{$Row['ResellerAccounts']}</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&UserID={$Row['UserID']}&Username={$Row['Username']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&UserID={$Row['UserID']}&Username={$Row['Username']}')\" class=Action>Delete</a>&nbsp;

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

		<th align='$DAlign' colspan=2>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=2>
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
		
		
		
	}

	
?>