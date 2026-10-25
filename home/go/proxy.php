<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);

if ($Action!="")
{
include "access.php";

	if ($Action=="Enable")
	{
		$Error=SSH ("/usr/bin/sudo /go/proxy $Domain 1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	else
	{
		$Error=SSH ("/usr/bin/sudo /go/proxy $Domain 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
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
	
    <TH align='$DAlign' width='60%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Proxy')\">{$LNG['ProxyStatus']}</a>
    </TH>
	
    <TH width='20%'>
 
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
	
	$Proxy=$Row['Proxy'];
		
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


		if ($Proxy==1)
		{
		$ProxyStatusCode="✔";
		}
		else
		{
		$ProxyStatusCode="✖";
		}
	

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    <a href=\"https://{$Row['Domain']}\" target='_blank'>{$Row['Domain']}</a>
    </td>

	<TD>
    $ProxyStatusCode
    </td>
	
	<TD align='$OAlign'>
	";
	
	if ($Proxy==1)
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