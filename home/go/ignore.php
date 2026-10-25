<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);

if ($_SESSION['SessionSSHUsername']!="root")
{	
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	
}

if ($Action!="")
{
include "access.php";

	if ($Action=="Enable")
	{
		SQL("UPDATE Site set APIIgnore='1' where Domain='$Domain'");

		echo Error("API Ignored for domain $Domain");
	}
	else
	{
		SQL("UPDATE Site set APIIgnore='0' where Domain='$Domain'");
		echo Error("API Applied to domain $Domain");
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
	
    <TH align='$DAlign' width='95%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain&Direction=DESC')\">{$LNG['Domain']}</a>
    </TH>

    <TH width='5%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=APIIgnore')\">Ignore</a>
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Site";$Field="Trash=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SiteID=$Row['SiteID'];
	
	$Domain=$Row['Domain'];
	
	$APIIgnore=$Row['APIIgnore'];
		
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
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    <a href=\"https://{$Row['Domain']}\" target='_blank'>{$Row['Domain']}</a>
    </td>

	<TD>
	";
	
	if ($APIIgnore==1)
	{	
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
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

	<th align='$DAlign' colspan=6>
	Showing $X of $RowsNo records.
	</th>

	</tr>

	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
	
	include "pages.php";


	
?>