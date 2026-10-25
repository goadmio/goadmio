<?php

include "navigator.php";
// $Buttons="<a href=\"adminer.php\" target='_blank' class='ButtonB {$Dir}ButtonB'>Adminer</a>";
include "title.php";

$Name=ValidateDatabaseName($_REQUEST['Name']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$User=ValidateUsername($_REQUEST['User']);
$Pass=ValidatePassword($_REQUEST['Pass']);
$Adminer=intval($_REQUEST['Adminer']);
$PostgreID=intval($_REQUEST['PostgreID']);

if ($Adminer==1)
{

	$Result = SQL("select * from Postgre where PostgreID='$PostgreID'");
	foreach ($Result as $Row)
	{
	setcookie ("CookiesPostgreUser",$Row['User'],time() + (86400 * 30), "/");
	setcookie ("CookiesPostgrePass",$Row['Pass'],time() + (86400 * 30), "/");

	header("Location: adminer/");
	}

exit;
}

If ($Delete==1 and $Step==1)
{

	echo Error("Delete Database \"$Name\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=2&Domain={$_REQUEST['Domain']}&Name={$_REQUEST['Name']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ServiceControl=$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);

include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/postgre $Domain $Name AnyUsername AnyPassword delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}

if ($User!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);
include "access.php";

	if ($Edit==1)
	{
	$Error=SSH ("/usr/bin/sudo /go/postgre $Domain $Name $User $Pass edit",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	}
	else
	{
	$Error=SSH ("/usr/bin/sudo /go/postgre $Domain $Name $User $Pass",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");	
	}

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}


	if ($Edit==1)
	{
	$Readonly="readonly";
	
		$Result = SQL("select * from Postgre where PostgreID='$PostgreID'");
		foreach ($Result as $Row)
		{
		$Domain=$Row['Domain'];
		$Name=$Row['Name'];
		$User=$Row['User'];
		$Pass="";
		}
	}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'><input type=hidden name=ServiceControl value='$ServiceControl'>
	<input type=hidden name=PostgreID value='$PostgreID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>

		<select name='Domain' class=Select>
		";
		
		$Result = SQl("select * from Site where Trash=0 $SearchSql order by Domain");
		foreach ($Result as $Row)
		{
			if ($Row['Domain']==$Domain)
			{
			echo "<option value='{$Row['Domain']}' selected>{$Row['Domain']}</option>";
			}
			else
			{
			echo "<option value='{$Row['Domain']}'>{$Row['Domain']}</option>";
			}
		}
		
		echo "
		</select>
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['DatabaseName']}<br>
	<input type='Text' name='Name' value='$Name' maxlength=100 class=InputText $Readonly>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['DatabaseUsername']}<br>
	<input type='Text' name='User' value='$User' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Password']}<br>
	<input type='Text' name='Pass' value='$Pass' maxlength=32 class=InputText>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
			echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		else
		{
			echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
		
		}
		
	echo "
	</div>

</form>
";



	if($Edit!=1)
	{

		include "search.php";
		
		Echo "
		<div class=DivTable>
		<table cellPadding='8' cellSpacing=0 width='100%' class=Table>

		<THEAD>
		
		<tr>
		
		<th width='2%'>

		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=Name')\">{$LNG['Name']}</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=Domain')\">{$LNG['Domain']}</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=User')\">{$LNG['Username']}</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=TimeStamp')\">{$LNG['CreatedDate']}</a>
		</th>
		
		<th width='30%'>
	
		</th>

		</tr>
		
		</THEAD>

		";


		$Table="Postgre";$Field="PostgreID>=1";
		$DefaultSortBy="Name";
		$DefaultDirection="ASC";
		include "include/sql.php";
	

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			$PostgreID=$Row['PostgreID'];
			
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
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			echo "
			
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Name']}-{$Row['Username']}-{$Row['Domain']}'>

			<TD align='middle'>
			$SerialNo
			</TD>

			<TD align='$DAlign'><a  href='$CurrentFileName?PostgreID={$Row['PostgreID']}&Adminer=1&ServiceControl=$ServiceControl' target='_blank'>{$Row['Name']}</a></TD>

			<TD align='$DAlign'>{$Row['Domain']}</TD>
			
			<TD align='$DAlign'>{$Row['User']}</TD>
						
			<TD align='$DAlign'>$CreatedDate</TD>

			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&PostgreID={$Row['PostgreID']}&Name={$Row['Name']}&Domain={$Row['Domain']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Edit</a>
			
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Name={$Row['Name']}&Domain={$Row['Domain']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Delete</a>

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
		
		<th align='$OAlign' colspan=3>
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