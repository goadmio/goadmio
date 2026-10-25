<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=$_REQUEST['SiteID'];
$CheckList=$_REQUEST['CheckList'];



$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	

	
	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='35%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SpaceUsed')\">{$LNG['DiskUsage']}</a>
    </TH>
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=BandwidthUsed')\">{$LNG['BandwidthUsage']}</a>
    </TH>

    <TH width='25%'>
 
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
    <a href=\"javascript:Load('zone.php?Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">{$Row['Domain']}</a>
    </td>
	";
	
	$SpaceUsed=FormatSize($Row['SpaceUsed']);
	
	if ($Row['DiskSpace']==0) 
	{
	$DiskSpace="Unlimited";
	}
	else
	{
	$DiskSpace=FormatSize($Row['DiskSpace']);
	}
	
	echo "
	<TD>
    
    $SpaceUsed / $DiskSpace
    </td>
	";

	$BandwidthUsed=FormatSize($Row['BandwidthUsed']);
	
	if ($Row['Bandwidth']==0) 
	{
	$Bandwidth=$LNG['Unlimited'];
	}
	else
	{
	$Bandwidth=FormatSize($Row['Bandwidth']);
	}

	echo "
	<TD>
    $BandwidthUsed / $Bandwidth
    </td>
	";

	$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
	
	echo "
	
	<TD align='$OAlign'>
	<a title='{$LNG['ManageDNS']}: $Domain' href=\"javascript:Load('zone.php?Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['ManageDNS']}</a>
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

	<th align='$DAlign' colspan=5>
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