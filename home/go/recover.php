<?php
include "nav.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Restore=intval($_REQUEST['Restore']);
$Remove=intval($_REQUEST['Remove']);
$Action=$_REQUEST['Action'];
$CheckList=$_REQUEST['CheckList'];

$Username=ValidateUsername($_REQUEST['Username']);
$Domain=ValidateDomain($_REQUEST['Domain']);

If ($Action=="Restore" and $Domain!="")
{

	$Error=SSH ("sudo screen -d -m bash -c '/go/snapshot $Domain restore latest > /var/log/go/recover/$Domain.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Recover $Domain in progress. It may take a few minutes.");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;

}

If ($Action=="Delete" and $Domain!="")
{
	$Error=SSH ("sudo screen -d -m bash -c '/go/snapshot $Domain delete > /var/log/go/recover/$Domain.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Deleting $Domain snapshot. This may take a few minutes.");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}


include "search.php";

Echo "
<form name=CheckForm id=CheckForm action='$CurrentFileName'>
<input type=hidden name=Action id=Action>

<div class=DivXTable>
<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

<THEAD>

<tr>

<TH align='$DAlign' width='30%'>
{$LNG['Domain']}
</TH>
	
<TH width='70%'>

</TH>

</tr>

</THEAD>
	
";
	
	
	$List=SSH ("/usr/bin/sudo /go/snapshot list",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	$ListArray=explode("\n",$List);
	
	$X=0;
	foreach ($ListArray as $Domain)
	{
		$Exists=0;
		$Sql = "select Domain from Site where Domain='$Domain'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		$Exists=1;
		}
		
		if ($Exists==0 and stristr($Domain,"."))
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
			

			if (file_exists("/var/log/go/recover/$Domain.log")) 
			{
				if (filemtime("/var/log/go/recover/$Domain.log") > time() - 300) 
				{
				$InProgress=1;
				} 

			}

			
			ECHO "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='$Domain'>
			
			<TD>
			$Domain
			</td>
			
			<TD align='$OAlign'>
			";
				if ($InProgress==1 or $Domain==$_REQUEST['Domain'])
				{
				echo "In Progress...";
				}
				else
				{
				echo "<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Action=Restore&Step=1&Domain=$Domain&Type=Latest&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore</a>";
				
				echo "<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Action=Delete&Domain=$Domain&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Delete Forever</a>";
				}
			
			echo "
			</td>
			
			</tr>
			";
			
			$X++;
		}
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
	
?>