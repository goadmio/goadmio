<?php

if ($_REQUEST['Action']=="Export")
{
session_start();
include "/usr/local/goadmio/include/config/config.php";

$FileName="undelivered.csv";
	
header("Content-Disposition: attachment; filename=$FileName");
header("Pragma: no-cache");
header("Expires: 0");

	echo "Invalid Email\n";



	if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{
		$Sql = "select * from Undelivered where UndeliveredID>=1 $EmailToSQL group by Email order by Email";
	}
	else
	{
		$Sql = "select * from Undelivered where Domain='{$_SESSION['SessionUsername']}' $EmailToSQL order by Email";
	}
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	echo "{$Row['Email']}\n";
	}


exit;
}

include "navigator.php";

$Buttons="
<a href=\"javascript:Load('$CurrentFileName?Action=Delete&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class='ButtonB {$Dir}ButtonB'>Delete undeliverable emails</a>
<a href='$CurrentFileName?Action=Export' target='_blank' class='ButtonB {$Dir}ButtonB'>Export as CSV</a>
";

include "title.php";

$UndeliveredID=$_REQUEST['UndeliveredID'];
$EmailTo=$_REQUEST['EmailTo'];
$CheckList=$_REQUEST['CheckList'];




$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));


if ($Action=="Delete")
{
	// $Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/undelivered {$_SESSION['SessionDomain']}'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if (stristr($_SESSION['SessionDomain'],"."))
	{
	$Error="Deleting undeliverable emails for {$_SESSION['SessionDomain']}";
	}
	else
	{
	$Error="Deleting all undeliverable emails.";
	}
	
	echo Error("$Error");
	
}

if ($Delete==1)
{

	
	$Result = SQL("DELETE from Undelivered where UndeliveredID='$UndeliveredID'");

}

if ($_SESSION['UndeliveredLock']!=1)
{
// $Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/undelivered'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}

$_SESSION['UndeliveredLock']=1;
	



	
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	

	
	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>

    <TH align='$DAlign' width='30%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>


    <TH align='$DAlign' width='40%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Email')\">{$LNG['InvalidEmail']}</a>
    </TH>
	

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Email')\">{$LNG['CreatedDate']}</a>
    </TH>

    <TH width='10%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";

	$Table="Undelivered";$Field="UndeliveredID>=1";
	$DefaultSortBy="UndeliveredID";
	$DefaultDirection="DESC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$UndeliveredID=$Row['UndeliveredID'];
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
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Name']}-{$Row['Email']}'>

	<TD title=\"To: {$Row['EmailTo']}\">
    
    {$Row['Domain']}
    </td>

	<TD>
    {$Row['Email']}
    </td>

	<TD>
    {$Row['Date']}
    </td>
	
	<TD align='$OAlign'>
	<a href=\"javascript:Load('$CurrentFileName?Delete=1&UndeliveredID=$UndeliveredID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Delete</a>
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