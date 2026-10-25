<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$CheckList=$_REQUEST['CheckList'];



if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	if ($_SESSION['SessionResellerUsername']=="")
	{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	}
}

if ($_REQUEST['Action']=="GetZoneID")
{

	
	// $Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cloudflare all getzoneid'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);


}

$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='30%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='70%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=OpenBasedir')\">{$LNG['OpenBasedirValue']}</a>
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

	$OpenBasedir=$Row['OpenBasedir'];
		
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
    <a href='http://{$Row['Domain']}' target='_blank'>{$Row['Domain']}</a>
    </td>

	<TD>
	<input type='text' id='Site{$SiteID}' value='$OpenBasedir' onchange=\"Setting('OpenBasedir','$SiteID',encodeURI(document.getElementById('Site{$SiteID}').value),'Site{$SiteID}')\" class=InputZ>
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
	
	<th align='$OAlign' colspan=3>
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