<?php

include "navigator.php";
$Buttons="";
include "title.php";



$SiteID=intval($_REQUEST['SiteID']);
$CheckList=$_REQUEST['CheckList'];



$Domain=ValidateDomain($_REQUEST['Domain']);
$Username=ValidateUsername($_REQUEST['Username']);
$SiteID=$_REQUEST['SiteID'];
$UserID=$_REQUEST['UserID'];
$Action=$_REQUEST['Action'];
$ChangeOwner=$_REQUEST['ChangeOwner'];
$CheckList=$_REQUEST['CheckList'];

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}




If ($Action=="ListOwner")
{
	echo "
	<div class='DivInput {$Dir}DivInput'>
	
		<div style='margin-bottom:10px'>Select a New Owner ($Domain):</div>
		";

		$Result=SQL("select * from User where UserID>=1");
		foreach ($Result as $Row)
		{


			if ($UserID==$Row['UserID'])
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				{$Row['Username']}
				</span>
			</label>
			";
			}
			else
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick='Load(\"$CurrentFileName?ChangeOwner=1&Domain=$Domain&UserID={$Row['UserID']}&Page=$Page\")'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				{$Row['Username']}
				</span>
			</label>
			";
			}
		
		}


		
		echo "

	</div>

	";
	
}
	
if ($ChangeOwner==1)
{

	SQL("UPDATE Site set UserID='$UserID' where Domain='$Domain'");

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
	
    <TH align='$DAlign' width='35%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=SpaceUsed')\">{$LNG['DiskUsage']}</a>
    </TH>
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=BandwidthUsed')\">{$LNG['BandwidthUsage']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=UserID')\">{$LNG['Owner']}</a>
    </TH>

    <TH width='5%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
    $Result = SQL("select * from User where UserID>=1");
    foreach ($Result as $Row)
    {
	$UserID=$Row['UserID'];
	$Owner[$UserID]=$Row['Username'];
	}
	
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
	$UserID=$Row['UserID'];
		
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
	";
	
	$SpaceUsed=FormatSize($Row['SpaceUsed']);
	
	if ($Row['DiskSpace']==0) 
	{
	$DiskSpace=$LNG['Unlimited'];
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
	<TD>
    {$Owner[$UserID]}
    </td>
	
	<TD align='$OAlign'>
	
	<a href='javascript:Load(\"$CurrentFileName?Action=ListOwner&Domain={$Row['Domain']}&UserID=$UserID\")' class=Action>{$LNG['ChangeOwner']}</a>
	
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