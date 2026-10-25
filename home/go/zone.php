<?php



include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Reset&Domain={$_REQUEST['Domain']}&ControlID=$ControlID','$ControlID')\" class='ButtonB {$Dir}ButtonB'>Reset</a>";
include "title.php";

$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);

$ZoneID=trim($_REQUEST['ZoneID']);

$Name=trim($_REQUEST['Name']);
$Type=$_REQUEST['Type'];

$Value=$_REQUEST['Value'];
$Value=str_replace('"','',$Value);

$TTL=$_REQUEST['TTL'];
$Priority=$_REQUEST['Priority'];

$ZoneID=$_REQUEST['ZoneID'];

If ($Delete==1)
{
	include "access.php";

	SQL("DELETE from Zone where ZoneID='$ZoneID' and Domain='$Domain'");
	
	$Error=SSH ("/usr/bin/sudo /go/zone $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
	echo Error("deleted..");
	
}
elseIf ($Action=="Reset")
{
	include "access.php";

	$Error=SSH ("/usr/bin/sudo /go/zone $Domain reset",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if (stristr($Error,"setup") or stristr($Error,"set up"))
	{
	echo Error("Failed! Please Setup a Nameserver. <a href=\"javascript:Load('nameservers.php')\" class=Action>Setup Nameservers</a>");
	}
	else
	{
	echo Error("$Error");
	}
	
}
elseif ($_REQUEST['Name']!="")
{
include "access.php";

	if ($Edit==1)
	{
		SQL("UPDATE Zone set Name='$Name',Type='$Type',Value='$Value',TTL='$TTL',Priority='$Priority' where ZoneID='$ZoneID'");
		
		$Edit=0;
		$Value="";
		
	}
	else
	{

		$Result = SQL("INSERT INTO Zone (Domain,Name,Type,Value,TTL,Priority,Custom) VALUES ('$Domain','$Name','$Type','$Value','$TTL','$Priority','1')");
		If ($Result)
		{
			// echo Error("done..");
		}
	}
	
	$Error=SSH ("/usr/bin/sudo /go/zone $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	if (stristr($Error,"setup") or stristr($Error,"set up"))
	{
	echo Error("Failed! Please Setup a Nameserver. <a href=\"javascript:Load('nameservers.php')\" class=Action>Setup Nameservers</a>");
	}
}



		include "search.php";

		if ($TTL=="")
		{
		$TTL="14400";
		}

		if ($Edit==1)
		{
			
			$Result = $SQL("select * from Zone where ZoneID='$ZoneID'");
			foreach ($Result as $Row)
			{
			$Domain=$Row['Domain'];
			$Name=$Row['Name'];
			$Type=$Row['Type'];
			$Value=$Row['Value'];
			$TTL=$Row['TTL'];
			$Priority=$Row['Priority'];
			
			
				if ($Type=="A") {$ASelected="selected";	}
				if ($Type=="CNAME") {$CNAMESelected="selected";}
				if ($Type=="MX") {$MXSelected="selected";}
				if ($Type=="NS") {$NSSelected="selected";}
				if ($Type=="TXT") {$TXTSelected="selected";}
				
			}

		}

		Echo "
		
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
		<input type=hidden name=ControlID value='$ControlID'>
		<input type=hidden name=Edit value='$Edit'>
		<input type=hidden name=Domain value='$Domain'>
		<input type=hidden name=ZoneID value='$ZoneID'>
	
		<div class=DivTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
				
		<th align='$DAlign' width='20%'>
		{$LNG['Name']}
		</th>
		
		<th align='$DAlign' width='10%'>
		{$LNG['TLS']}
		</th>
		
		<th align='$DAlign' width='10%'>
		{$LNG['Class']}
		</th>
		
		<th align='$DAlign' width='20%'>
		{$LNG['Type']}
		</th>
		
		<th align='$DAlign' width='20%'>
		{$LNG['Value']}
		</th>

		<th width='20%'>
		
	
		</th>
		
		</tr>
		

		<TBODY>
		
		<tr class='TdB'>
		
			<TD><input type='text' name='Name' value='$Name' maxlength=100 class=InputText></TD>
			
			<TD><input type='text' name='TTL' value='$TTL' maxlength=100 class=InputText></TD>
			<TD>{$LNG['IN']}</TD>

			<TD>
				<select name='Type' class=Select>
				<option value='A' $ASelected>A</option>
				<option value='CNAME' $CNAMESelected>CNAME</option>
				<option value='MX' $MXSelected>MX</option>
				<option value='NS' $NSSelected>NS</option>
				<option value='TXT' $TXTSelected>TXT</option>
				</select>
			</TD>
			
			<TD><input type='text' name='Value' value='$Value' maxlength=100 class=InputText></TD>
			
			<TD align='$OAlign'>
			<div id=DivSubmit>
			";
			
			if ($Edit==1)
			{
				echo "<input type=submit value='{$LNG['SaveChanges']}' class=Action>";
			}
			else
			{
				echo "<input type=submit value='{$LNG['AddRecord']}' class=Action>";
			}
			
			echo "
			</div>
			</TD>
		
		</tr>

		
		";


	$Table="Zone";$Field="Domain='$Domain'";
	$DefaultSortBy="Type,Name,Value";
	$DefaultDirection="ASC";
	include "include/sql.php";
		
		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			echo "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['AliasDomain']}'>

			<TD>{$Row['Name']}</TD>
			
			<TD>{$Row['TTL']}</TD>
			<TD>{$LNG['IN']}</TD>

			<TD>{$Row['Type']}</TD>
			
			<TD><input type='text' value='{$Row['Value']}' class=InputZ></TD>
			
			<TD align='$OAlign'>
			<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID&Edit=1&ZoneID={$Row['ZoneID']}&Domain={$Row['Domain']}')\" class=Action>{$LNG['Edit']}</a>
			<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID&Delete=1&ZoneID={$Row['ZoneID']}&Domain={$Row['Domain']}')\" class=Action>{$LNG['Delete']}</a>
			</TD>
			";
			
		$X++;
		}
		

		echo "
		</TBODY>
		
		
		<TFOOT>

		<tr>

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=3>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		</form>
		";
		
?>