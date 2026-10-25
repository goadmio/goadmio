<?php
include "navigator.php";
$Buttons="";
include "title.php";

$ID=intval($_REQUEST['ID']);
$Name=Trim($_REQUEST['Name']);

if ($Action!="")
{
include "access.php";


	if ($Action=="Enable")
	{
		SQL("UPDATE Country set Whitelist='1' where ID='$ID'");
	}
	else
	{
		SQL("UPDATE Country set Whitelist='0' where ID='$ID'");
	}
	
}



    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='90%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Name')\">{$LNG['Name']}</a>
    </TH>

    <TH align='$OAlign' width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?SortBy=Whitelist&Direction=DESC')\">{$LNG['Whitelist']}</a>
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Country";$Field="ID>=1";
	$DefaultSortBy="Name";
	$DefaultDirection="ASC";
	include "include/sql.php";    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$ID=$Row['ID'];
	$Name=$Row['Name'];
	$Whitelist=$Row['Whitelist'];
		
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
	

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Name']}-{$Row['Code']}'>

    <TD>
    $Name
    </td>
	
	<TD align='$OAlign'>
	";
	
	if ($Whitelist==1)
	{	
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&Name=$Name&ID=$ID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&Name=$Name&ID=$ID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>
	";
	}
		
	echo "
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

	<tr class=TdDown>

	<th align='$DAlign' colspan=2>
	Showing $X of $RowsNo records.
	</th>

	</tr>

	</TFOOT>

	</TABLE>
	</div>
	</form>
	";

	
?>