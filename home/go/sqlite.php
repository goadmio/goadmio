<?php

include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$phpLiteAdmin=$_REQUEST['phpLiteAdmin'];
$Name=strtolower($_REQUEST['Name']);
$Domain=strtolower($_REQUEST['Domain']);
$SQLiteID=$_REQUEST['SQLiteID'];

if ($phpLiteAdmin==1)
{
	
	$Result = SQL("select * from SQLite where SQLiteID='$SQLiteID'");
	foreach ($Result as $Row)
	{
		$_SESSION['SessionSQLiteDirectory']="/home/{$Row['Domain']}/sqlite";
		
		header("Location: phpliteadmin/index.php");
	}
	
	exit;
}

If ($Delete==1 and $Step==1)
{
	
	echo Error("Delete Access \"$Name\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&&ServiceControl=$ServiceControl&Step=2&Domain=$Domain&Name=$Name')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo /go/sqlite $Domain $Name delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");	
	
	exit;
	
}

if ($_REQUEST['Domain']!="")
{
	include "access.php";
	$Domain=ValidateDomain($_REQUEST['Domain']);
	$Domain=strtolower($Domain);
	
	$Error=SSH ("/usr/bin/sudo /go/sqlite $Domain $Name add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
}

Echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
<input type=hidden name=Edit value='$Edit'><input type=hidden name=ServiceControl value='$ServiceControl'>
<input type=hidden name=SQLiteID value='$SQLiteID'>

<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}
<br>
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
<select name='Domain' id='Domain' class=Select>
";

foreach ($Domains as $Domain) 
{
	echo "
	<option value='$Domain'>$Domain</option>
	";
}

echo "
</select>

</div>

<div class='DivInput {$Dir}DivInput'>{$LNG['Name']}
<br>

<input type='Text' name='Name' id='Name' value='$Name' maxlength=255 class=InputText30>
</div> 

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

echo "
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

	<th align='$DAlign' width='2%' height=40>

	</th>

	<th align='$DAlign' width='25%'>
	{$LNG['SQLiteDirectory']}
	</th>

	<th align='$DAlign' width='25%'>
	{$LNG['Domain']}
	</th>

	<th align='$DAlign' width='25%'>
	{$LNG['CreatedDate']}
	</th>

	<th width='23%'>

	</th>

	</tr>

	</THEAD>

	";

	$Table="SQLite";$Field="SQLiteID>=1";
	$DefaultSortBy="Username";
	$DefaultDirection="ASC";
	include "include/sql.php";

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

		$SerialNo=(($Page-1)*$PageNo)+($X+1);

		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

		echo "
		<tr name=R$i id=R$i divid=Find find='{$Row['Domain']}-{$Row['Directory']}' class='$TDColor'>


		<TD align='middle' height=40>
		$SerialNo
		</span>
		</TD>


		<TD><a  href='$CurrentFileName?SQLiteID={$Row['SQLiteID']}&phpLiteAdmin=1&ServiceControl=$ServiceControl' target='_blank'>{$Row['Name']}</a></TD>

		<TD>{$Row['Domain']}</TD>

		<TD>$CreatedDate</TD>

		<TD align='$OAlign'>

		<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Name={$Row['Name']}&Domain={$Row['Domain']}')\" class=Action>Delete</a>

		<a href=\"$CurrentFileName?SQLiteID={$Row['SQLiteID']}&phpLiteAdmin=1&ServiceControl=$ServiceControl\" target='_blank' class=Action>phpLiteAdmin</a>

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

	<tr class=TdDown>

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
	</form>
	";
}
?>