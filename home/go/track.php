<?php

include "navigator.php";
$Buttons="";
include "title.php";

$TrackID=intval($_REQUEST['TrackID']);
$CheckList=$_REQUEST['CheckList'];

$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/spam track'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>
	
    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=EmailFrom')\">{$LNG['From']}</a>
    </TH>

    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=EmailTo')\">{$LNG['To']}</a>
    </TH>

    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=EmailTo')\">{$LNG['Subject']}</a>
    </TH>

    <TH align='$DAlign' width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Status')\">{$LNG['Status']}</a>
    </TH>

    <TH align='$DAlign' width='5%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Folder')\">{$LNG['Folder']}</a>
    </TH>

    <TH width='20%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=TimeStamp')\">{$LNG['Date']}</a>
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Track";$Field="TrackID>=1";
	$DefaultSortBy="TimeStamp";
	$DefaultDirection="DESC";
	include "include/sql.php";
	

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
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
		

	$Date=date("D j M Y g:i a", $Row['TimeStamp']);

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['IP']}-{$Row['Country']}'>

    <TD>
    <a href=\"javascript:Load('httplog.php?SearchFor={$Row['Domain']}')\">{$Row['Domain']}</a>
    </td>

	<TD title=\"{$Row['EmailFrom']}\">
    <div style='max-width:125px;overflow: hidden;'>{$Row['EmailFrom']}</div>
    </td>
	
	<TD title=\"{$Row['EmailTo']}\">
    <div style='max-width:125px;overflow: hidden;'>{$Row['EmailTo']}</div>
    </td>

	<TD title=\"{$Row['Subject']}\">
    <div style='max-width:125px;overflow: hidden;'>{$Row['Subject']}</div>
    </td>

	<TD>
    {$Row['Status']}
    </td>
	
	<TD>
    {$Row['Folder']}
    </td>
	
	<TD align='$OAlign'>
	$Date
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

	<th align='$DAlign' colspan=2>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=4>
	";
			
	include "pages.php";

	echo "
	</th>



	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
	



	
?>