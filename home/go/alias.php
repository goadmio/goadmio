<?php



include "navigator.php";
$Buttons="";
include "title.php";

$AliasID=$_REQUEST['AliasID'];
$RedirectUrl=trim($_REQUEST['RedirectUrl']);
$Directory=ValidateDirectory($_REQUEST['Directory']);

$AliasDomain=ValidateDomain($_REQUEST['AliasDomain']);
$AliasDomain=strtolower($AliasDomain);

$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);

If ($Delete==1 and $Step==1)
{

	echo Error("Delete \"$AliasDomain\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&AliasDomain={$_REQUEST['AliasDomain']}&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");

	exit;
	
}

if ($Delete==1 and $Step==2)
{

	$Error=SSH ("/usr/bin/sudo /go/alias $AliasDomain AnyDomain delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
}

if ($_REQUEST['AliasDomain']!="")
{

	$Result = SQL("select AliasNo from Site where Domain='$Domain'");
	foreach ($Result as $Row)
	{
		if ($Row['AliasNo']==-1)
		{
		echo "<div class='UnderTitle'>This feature has been disabled by your administrator.</div>";
		exit;
		}
	
	}
		
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/alias $AliasDomain $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("The alias domain $AliasDomain is currently being created for the primary domain $Domain.");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}


	echo "
	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'><input type=hidden name=ServiceControl value='$ServiceControl'>
	<input type=hidden name=AliasID value='$AliasID'>

	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['DomainAliasName']}<br>
	<input type='text' name='AliasDomain' maxlength=100 class=InputText size=40>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	<select name='Domain' class=Select>
	";
	
	$Sql = "select * from Site where Trash=0 $SearchSql order by Domain";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	echo "
	<option value='{$Row['Domain']}'>{$Row['Domain']}</option>
	";
	}
	
	echo "
	
	</select>
	
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
		
		<th width='2%'>

		</th>
		
		<th align='$DAlign' width='25%'>
		{$LNG['DomainAliasName']}
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
		
		

		$Table="Alias";$Field="Trash=0";
		$DefaultSortBy="AliasDomain";
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
			
			$SerialNo=(($Page-1)*$PageNo)+$x;
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			echo "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['AliasDomain']}'>

			<TD align='center'>
			$SerialNo
			</TD>
			
			<TD><a href='http://{$Row['AliasDomain']}' target='_blank'>{$Row['AliasDomain']}</a></TD>

			<TD>{$Row['Domain']}</TD>
			
			<TD>$CreatedDate</TD>
			
			<TD align='$OAlign'>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&AliasDomain={$Row['AliasDomain']}')\" class=Action>Delete</a>
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