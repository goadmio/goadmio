<?php

include "navigator.php";

$MainMenu.="
<div class='DropdownButton'>

	<button onclick=\"DropdownButton('MainMenu', event)\" class='DropButton'>Spam Filters</button>
  
	<div id='MainMenu' class='DropdownButtonContent'>
		<a href=\"javascript:Load('junk.php')\">{$LNG['IPSpamFilter']}</a>				
	</div>
  
</div>
";

include "title.php";

$Edit=intval($_REQUEST['Edit']);
$FilterID=intval($_REQUEST['FilterID']);

$Action=trim($_REQUEST['Action']);
$Type=trim($_REQUEST['Type']);
$Keyword=trim($_REQUEST['Keyword']);

if ($Action=="Delete")
{
	include "access.php";
	
	SQL("DELETE FROM Filter WHERE FilterID='$FilterID'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}
elseif ($_REQUEST['Keyword']!="")
{
	include "access.php";
	
	if ($Edit==1)
	{

		$Result = SQL("select * from Filter where Type='$Type' and Keyword='$Keyword' AND FilterID!='$FilterID'");
		foreach ($Result as $Row)
		{
			echo Error("Keyword \"$Keyword\" already exists.");
			echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
			exit;
		}
	
		SQL ("UPDATE Filter SET Type='$Type',Keyword='$Keyword' WHERE FilterID=$FilterID");	
		echo Error("Filter keyword \"$Keyword\" edited successfully");
	}
	else
	{

		$Result = SQL("select * from Filter where Type='$Type' and Keyword='$Keyword'");
		foreach ($Result as $Row)
		{
			echo Error("Keyword \"$Keyword\" already exists.");
			echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
			exit;
		}

		SQL ("INSERT OR IGNORE INTO Filter (Type,Keyword) VALUES ('$Type','$Keyword')");
		echo Error("Filter keyword \"$Keyword\" added successfully");
	}
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	$Edot=0;
	$Type="";
	$Keyword="";
}
	
	


	if ($Edit==1)
	{
		$Result = SQL("select * from Filter where FilterID='$FilterID'");
		foreach ($Result as $Row)
		{
			$Type=$Row['Type'];
			$Keyword=$Row['Keyword'];
			
			if ($Type=="Header")
			{
			$HeaderSelected="selected";
			}
			else
			{
			$BodySelected="selected";
			}
			
			
			
			
		}
		
	}

	echo "

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=FilterID value='$FilterID'>
	
	<div class='DivInput {$Dir}DivInput'>Type:<br>

	<select name='Type' id='Type' class=Select>
	<option value='Header' $HeaderSelected>Header</option>
	<option value='Body' $BodySelected>Body</option>
	</select>
		
	</div>

	<div class='DivInput {$Dir}DivInput'>Keyword:<br>
	<input type='text' name='Keyword' value='$Keyword' required maxlength=255 class=InputText>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	
	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='Add Filter' class=InputButton>";
	}

	Echo "
	</div>

</form>

	";
	

	include "search.php";
	
	echo "
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
	<th align='$DAlign' width='20%'>
	Type
	</th>
	
	<th align='$DAlign' width='70%'>
	Keyword
	</th>


	<th align='$OAlign' width='10%'>

	</th>

	</tr>
	
	</THEAD>
	
	";

	$Table="Filter";$Field="FilterID>=1";
	$DefaultSortBy="Keyword";
	$DefaultDirection="DESC";
	include "include/sql.php";

	$X=0;
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	
		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}

		Echo "
		<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['IP']}-{$Row['Domain']}-{$Row['Country']}'>

		<TD>{$Row['Type']}</TD>
		<TD>{$Row['Keyword']}</TD>

		<TD align='$OAlign'>
		
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&FilterID={$Row['FilterID']}&Type={$Row['Type']}&Keyword={$Row['Keyword']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Action=Delete&FilterID={$Row['FilterID']}&Type={$Row['Type']}&Keyword={$Row['Keyword']}')\" class=Action>Delete</a>

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
	</form>

	";




?>