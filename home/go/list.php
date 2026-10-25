<?php

include "navigator.php";
$Buttons="
<a href=\"javascript:Load('site.php')\" class='ButtonB {$Dir}ButtonB'>{$LNG['CreateNewAccount']}</a>
";
include "title.php";

$Notes=$_REQUEST['Notes'];
$Domain=ValidateDomain($_REQUEST['Domain']);
$Username=ValidateUsername($_REQUEST['Username']);
$SiteID=$_REQUEST['SiteID'];
$UserID=$_REQUEST['UserID'];
$CompanyNotes=$_REQUEST['CompanyNotes'];
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
	<div class='DivInput {$Dir}DivInput'>Select a New Owner ($Domain):<BR>
	";

		$Result = SQL("select * from User where UserID>=1");
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






	$FilterSql = str_replace("|Apostrophe|", "'", $FilterSql);
	$FilterSql = str_replace("|Space|", " ", $FilterSql);

	$SearchFor = str_replace("|Apostrophe|", "'", $SearchFor);
	$SearchFor = str_replace("|Space|", " ", $SearchFor);


	include "search.php";

	Echo "	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align=$DAlign width='20%' height=40>
	<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>

    <TH align=$DAlign width='15%'>
    <a href=\"javascript:Load('$CurrentFileName?Service=$Service&ControlID=$ControlID&ServiceControl=$ServiceControl&SortBy=SpaceUsed')\">{$LNG['DiskUsage']}</a>
	</TH>
	
    <TH align=$DAlign width='15%'>
	<a href=\"javascript:Load('$CurrentFileName?Service=$Service&ControlID=$ControlID&ServiceControl=$ServiceControl&SortBy=BandwidthUsed')\">{$LNG['BandwidthUsage']}</a>
    </TH>


    <TH align=$DAlign width='7%'>
    {$LNG['Emails']}
    </TH>
	
    <TH align=$DAlign width='10%'>
    {$LNG['Databases']}
    </TH>
	
    <TH align=$DAlign width='10%'>
    {$LNG['SubDomains']}
    </TH>
	
    <TH align=$DAlign width='7%'>
    {$LNG['Aliases']}
    </TH>
	
    <TH align=$DAlign width='11%'>
    {$LNG['AddonDomains']}
    </TH>

    <TH align=$DAlign width='5%'>
	{$LNG['Owner']}
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


	$Table="Site";$Field="SiteID>=1";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";



	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$UserID=$Row['UserID'];
	
	$SiteID=$Row['SiteID'];
	$ID=$Row['SiteID'];

	
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

		if ($Row['Suspend']==1)
		{
		$TDColor="TdEr";
		}
		
		if ($Row['Trash']==1)
		{
		$TDColor="TdInfo";
		}

    ECHO "
	
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>
	";

	$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

    Echo "
	<TD title='Created Date: $CreatedDate'>
	{$Row['Domain']}
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

	$Emails=RowCount("SELECT * FROM Mail where Username='{$Row['Username']}'");

	echo "
	<TD>
    
	$Emails / {$Row['EmailNo']}
    </td>
	";

	$Databases=RowCount("SELECT * FROM Mysql where Username='{$Row['Username']}'");

	echo "
	<TD>
    
	$Databases / {$Row['DatabaseNo']}
    </td>
	";
    
	
	$Subdomains=RowCount("SELECT * FROM Subdomain where Username='{$Row['Username']}'");

	echo "
	<TD>
    
	$Subdomains / {$Row['SubDomainNo']}
    </td>
	";
	
	$Aliases=RowCount("SELECT * FROM Alias where Domain='{$Row['Domain']}'");

	echo "
	<TD>
	
	$Aliases / {$Row['AliasNo']}
    </td>
	";
	
	$Addon=RowCount("SELECT * FROM Site where Domain='{$Row['Domain']}' and Owner!=''");

	echo "
	<TD>
    
	$Addon / {$Row['AddonNo']}
    </td>

	<TD>
	";
	
		if ($_SESSION['SessionType']=="Root")
		{
		echo "
		<div class='DropdownButton'>
		
			<button onclick=\"DropdownButton('Owner{$ID}', event)\" class='DropButton'>{$Owner[$UserID]}</button>	
		  
			<div id='Owner{$ID}' class='DropdownButtonContent'>
						
				<a href=\"javascript:Load('$CurrentFileName?Action=ListOwner&Domain={$Row['Domain']}&UserID=$UserID')\">Change Owner</a>

			</div>
		  
		</div>
		";
		}
		else
		{
			//  Reseller
			echo $_SESSION['SessionUsername'];
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

   <tr>

	<th align='$DAlign' colspan=9>
	Showing $X of $RowsNo records.
	</th>


	</tr>

	</TFOOT>


	
   </TABLE>
   </div>
  
	
	";

	include "pages.php";

?>