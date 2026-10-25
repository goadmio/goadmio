<?php
include "navigator.php";
$Buttons="";
include "title.php";

$ID=intval($_REQUEST['ID']);
$Name=Trim($_REQUEST['Name']);

if ($Action!="")
{
	include "access.php";

	if ($Action=="Enable")
	{
		SQL("UPDATE Bot set Block='1' where ID='$ID'");
	}
	else
	{
		SQL("UPDATE Bot set Block='0' where ID='$ID'");
	}
	
	$Error=SSH ("/usr/bin/sudo /go/conf --schedule",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo Error("Update in progress. It may take up to 5 minutes for bot protection changes to impact your live site.");
	
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
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Name')\">{$LNG['Name']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Block')\">{$LNG['Blocked']}</a>
    </TH>
	
    <TH width='20%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Block')\">{$LNG['Action']}</a>
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Bot";$Field="ID>=1";
	$DefaultSortBy="Name";
	$DefaultDirection="ASC";
	include "include/sql.php";    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$ID=$Row['ID'];
	$Name=$Row['Name'];
	$Block=$Row['Block'];
		
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


		if ($Block==1)
		{
		$BotStatusCode="✔";
		}
		else
		{
		$BotStatusCode="✖";
		}
	

    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Name']}-{$Row['Email']}'>

    <TD>
    $Name
    </td>

	<TD>
    $BotStatusCode
    </td>
	
	<TD align='center'>
	";
	
	if (! preg_match('/google|adsbot/i', $Name)) 
	{
		
		if ($Block==1)
		{	
		echo "
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&Name=$Name&ID=$ID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>
		";
		}
		else
		{
		echo "
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&Name=$Name&ID=$ID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>
		";
		}
		
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