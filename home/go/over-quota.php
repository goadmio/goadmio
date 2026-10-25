<?php
include "navigator.php";
$Buttons="";
include "title.php";


if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$Notes=$_REQUEST['Notes'];
$Username=ValidateUsername($_REQUEST['Username']);
$SiteID=$_REQUEST['SiteID'];
$CompanyNotes=$_REQUEST['CompanyNotes'];
$Action=$_REQUEST['Action'];
$CheckList=$_REQUEST['CheckList'];


    $UserNo=RowCount("select * from Site where SiteID>=1");
    
    if ($UpdateBackupDate==1)
    {
        $Sql = "UPDATE Site Set BackupDate='$Date' where SiteID='$SiteID'";
        $Result = SQL($Sql);
        If ($Result)
        {
        echo Error("Backup date has been updated.");
        }

    exit;
    }
	
If ($Action=="Unlimited")
{
	$CountCheckList=count($CheckList);

	for ($i=0 ;$i<$CountCheckList ; $i++)
	{

		$Sql = "UPDATE Site SET DiskSpace='0' where SiteID='$CheckList[$i]'";
		$Result = SQL($Sql);
		
	}

	echo Error("Site(s) quota has been updated.");


}



	include "search.php";

	Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH width='30%' height=45>
    {$LNG['Domain']}
    </TH>

    <TH width='15%'>
    {$LNG['DiskUsage']}
    </TH>
	
    <TH width='15%'>
    {$LNG['BandwidthUsage']}
    </TH>

    <TH width='15%'>
    {$LNG['CreatedDate']}
    </TH>

    <TH width='20%'>
    {$LNG['Action']}
    </TH>
	
	</tr>
	
	</THEAD>
	";

	$Table="Site";$Field="SpaceUsed>DiskSpace and DiskSpace!=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";


	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		
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

		$SpaceUsed=FormatSize($Row['SpaceUsed']);
		if ($Row['DiskSpace']==0) 
		{
		$DiskSpace="Unlimited";
		}
		else
		{
		$DiskSpace=FormatSize($Row['DiskSpace']);
		}
		
		$BandwidthUsed=FormatSize($Row['BandwidthUsed']);
		if ($Row['Bandwidth']==0) 
		{
		$Bandwidth="Unlimited";
		}
		else
		{
		$Bandwidth=FormatSize($Row['Bandwidth']);
		}
		
		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    {$Row['Domain']}
    </td>

	<TD>
    
    $SpaceUsed / $DiskSpace
    </td>

	<TD>
    
    $BandwidthUsed / $Bandwidth
    </td>

	<TD>
    
    $CreatedDate
    </td>

	<TD>

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