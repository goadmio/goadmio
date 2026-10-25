<?php



if ($_REQUEST['Action']=="Export")
{
	session_start();
	include "/usr/local/goadmio/include/config/config.php";
	
	
	
	
	if ($_REQUEST['EmailTo']!="")
	{
		$EmailToSQL="and EmailTo='{$_REQUEST['EmailTo']}'";
		
		$FileNameArray=explode("@",$_REQUEST['EmailTo']);
		$FileName=$FileNameArray[0]."csv";
	}
	else
	{
		$FileName="Outlook.csv";
	}
	
	header("Content-Disposition: attachment; filename=$FileName");
	header("Pragma: no-cache");
	header("Expires: 0");
	
	echo "First Name,E-mail Address,Categories\n";
	
	
	
	if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{
		$Sql = "select * from Contact where ContactID>=1 $EmailToSQL group by EmailFrom order by Name";
	}
	else
	{
		$Sql = "select * from Contact where Domain='{$_SESSION['SessionUsername']}' $EmailToSQL order by Name";
	}
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		echo "{$Row['Name']},{$Row['EmailFrom']},My Contacts\n";
	}
	
	
	exit;
}

include "navigator.php";

$Buttons="
<a href='$CurrentFileName?Action=Export&EmailTo={$_REQUEST['EmailTo']}' target='_blank' class='ButtonB {$Dir}ButtonB'>Export as Outlook CSV</a>
";

include "title.php";

$ContactID=$_REQUEST['ContactID'];
$EmailTo=$_REQUEST['EmailTo'];
$CheckList=$_REQUEST['CheckList'];



$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));

if ($Delete==1)
{
	$Result = SQL("DELETE from Contact where ContactID='$ContactID'");
}
else
{
	if (stristr($_SESSION['SessionUsername'],"."))
	{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/contact {$_SESSION['SessionUsername']}'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	else
	{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/contact all'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		
	}
	
}

include "search.php";

Echo "
<form name=CheckForm id=CheckForm action='$CurrentFileName'>
<input type=hidden name=Action id=Action>

<div class=DivTable>
<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

<THEAD>

<tr>

<TH align='$DAlign' width='35%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Name')\">{$LNG['Name']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=EmailFrom')\">{$LNG['Email']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
</TH>

<TH align='$DAlign' width='20%'>
<a href=\"javascript:Load('$CurrentFileName?&SortBy=TimeStamp')\">{$LNG['CreatedDate']}</a>
</TH>

<TH width='5%'>

</TH>

</tr>

</THEAD>

";

$Table="Contact";$Field="ContactID>=1";
$DefaultSortBy="ContactID";
$DefaultDirection="ASC";
include "include/sql.php";

$X=0;
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	
	
	$ContactID=$Row['ContactID'];
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
	
	<TD>
	{$Row['Name']}
		</td>
		
		
		<TD title=\"To: {$Row['EmailTo']}\">
		
		{$Row['EmailFrom']}
			</td>
			
			<TD>
			{$Row['Domain']}
				</td>
				";
				
				$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
				
				echo "
				<TD>
				$CreatedDate
				</td>
				
				<TD align='$OAlign'>
				<a href=\"javascript:Load('$CurrentFileName?Delete=1&ContactID=$ContactID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Delete</a>
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