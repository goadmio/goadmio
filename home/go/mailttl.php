<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateUsername($_REQUEST['Domain']);



if ($Action!="")
{
	
}


	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='80%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>
	
    <TH align='center' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=MailTTL')\">Email TTL (Days)</a>
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
	
	$MailTTL=$Row['MailTTL'];
		
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

	<TD align='center'>
    <input type='text' value='$MailTTL' id='MailTTL{$SiteID}' onchange=\"Setting('MailTTL','$SiteID',encodeURI(document.getElementById('MailTTL{$SiteID}').value),'MailTTL{$SiteID}')\" class=InputText style='text-align:center'>
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