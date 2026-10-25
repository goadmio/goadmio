<?php

include "navigator.php";
$Buttons="";
include "title.php";

$Edit=$_REQUEST['Edit'];
$Reset=$_REQUEST['Reset'];
$Name=$_REQUEST['Name'];
$APIKey=$_REQUEST['APIKey'];
$Domain=ValidateDomain($_REQUEST['Domain']);
$APIID=$_REQUEST['APIID'];
$IP=$_REQUEST['IP'];
$Command=$_REQUEST['Command'];

If ($Delete==1 and $Step==1)
{

	$EncodeName=urlencode($Name);
	echo Error("Delete \"{$Name}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&APIID=$APIID&APIKey=$APIKey&Step=2&Name={$EncodeName}','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	$Sql = "DELETE from API where APIID='$APIID'";
	$Result = SQL($Sql);
	If ($Result)
	{
		echo Error("API $APIKey \"{$Name}\" has been deleted.");
	}

}
elseif ($_REQUEST['IP']!="" or $Reset==1)
{

	if ($Reset==1)
	{
		
		if (strlen($APIKey)==16)
		{
		$APIKey=GeneratePassword(16);
		}
		else
		{
		$APIKey=GeneratePassword(50);
		}
		
		$Sql = "UPDATE API SET APIKey='$APIKey' where APIID='$APIID'";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("API $APIKey ($APIID) updated successfully.");
		}
	
	$Edit="";
	}
	elseif ($Edit==1)
	{
		$TimeStamp=time();
		
		if (strlen($APIKey)!=16 and strlen($APIKey)!=50)
		{
			if ($Command!="" and strtolower($Command)!="all")
			{
			$APIKey=GeneratePassword(16);
			}
			else
			{
			$APIKey=GeneratePassword(50);
			}
			
		}
		
		$Sql = "UPDATE API SET Name='$Name',APIKey='$APIKey',Command='$Command',IP='$IP' WHERE APIID='$APIID'";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("API $APIKey updated successfully.");
		}
		
		$Edit="";
	}
	else
	{
		if ($DemoPassword!="")
		{
		echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
		exit;
		}

		$TimeStamp=time();
		
		if (strlen($APIKey)!=16 and strlen($APIKey)!=50)
		{
			if ($Command!="" and strtolower($Command)!="all")
			{
			$APIKey=GeneratePassword(16);
			}
			else
			{
			$APIKey=GeneratePassword(50);
			}
			
		}
		
		if ($Command!="" and strtolower($Command)!="all")
		{
		$APIKey=GeneratePassword(16);
		}
		
		$Sql = "INSERT INTO API (Name,APIKey,Command,IP,TimeStamp) VALUES ('$Name','$APIKey','$Command','$IP','$TimeStamp')";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("API $APIKey created successfully.");
		}
		
	}
}

	$Name="";
	$APIKey="";
	$IP="";
	$Command="";
	if ($Edit==1)
	{
		$Sql = "select * from API where APIID='$APIID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
			$Name=$Row['Name'];
			$APIKey=$Row['APIKey'];
			$IP=$Row['IP'];
			$Command=$Row['Command'];

		}
				
	}
	else
	{
	$APIKey=GeneratePassword(50);
	}
	
	if ($IP=="")
	{
	$IP="0.0.0.0";
	}

	echo "
	
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=APIID value='$APIID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['FriendlyName']}<br>
	<input type='Text' name='Name' value='$Name' required maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>API Key<br>
	<input type='Text' name='APIKey' value='$APIKey' required maxlength=50 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>IP<br>
		
	<input type='text' name='IP' value='$IP' required maxlength='15' class='InputText' 
		   pattern='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
		   title='Please enter a valid IPv4 address (e.g., 192.168.1.1)'
		   inputmode='decimal'
		   placeholder='192.168.1.1'>
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>Command<br>
	<input type='Text' name='Command' value='$Command' maxlength=1000 class=InputText>
	</div>
	
	
	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
			echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		else
		{
			echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
		
		}
		
	echo "
	</div>

</form>
";



	if($Edit!=1)
	{

		include "search.php";
		
		Echo "
		<div class=DivTable>
		<table cellPadding='8' cellSpacing=0 width='100%' class=Table>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='20%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=Name')\">{$LNG['FriendlyName']}</a>
		</th>


		<th align='$DAlign' width='20%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=APIKey')\">{$LNG['APIKey']}</a>
		</th>

		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=IP')\">{$LNG['IP']}</a>
		</th>


		<th align='$DAlign' width='20%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=TimeStamp')\">{$LNG['CreatedDate']}</a>
		</th>
		
		<th width='30%'>
	
		</th>

		</tr>
		
		</THEAD>

		";


		$Table="API";$Field="APIID>=1";
		$DefaultSortBy="APIID";
		$DefaultDirection="DESC";
		include "include/sql.php";
		
		$X=0;

		$Result=SQL($Sql);
		foreach ($Result as $Row)
		{
		
			$APIID=$Row['APIID'];
			$ID=$Row['APIID'];
			
			$Name=$Row['Name'];
			$EncodeName=urlencode($Name);
			
			$APIKey=$Row['APIKey'];
			$IP=$Row['IP'];
			$Command=$Row['Command'];
			
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
			
			if ($Row['TimeStamp']>1)
			{
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
			}
			else
			{
			$CreatedDate="-";
			}

			echo "
			
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['APIID']}-{$Row['Name']}-{$Row['APIKey']}-{$Row['IP']}'>

			<TD align='$DAlign'>$Name</TD>
			<TD align='$DAlign'>$APIKey</TD>
			<TD align='$DAlign'>$IP</TD>

			<TD align='$DAlign'>$CreatedDate</TD>

			<TD align='$OAlign'>
			";
			
			echo "
			<div class='DropdownButton'>
			
				<button onclick=\"DropdownButton('Button{$ID}', event)\" class='DropButton'>Action</button>	
			  
				<div id='Button{$ID}' class='DropdownButtonContent'>

					<a href=\"javascript:Load('$CurrentFileName?Reset=1&APIID={$APIID}&&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">Reset API Key</a>
					<a href=\"javascript:Load('$CurrentFileName?Edit=1&APIID=$APIID&ControlID=$ControlID&Page=$Page')\">Edit</a>
					<a href=\"javascript:Load('$CurrentFileName?Delete=1&APIID=$APIID&Step=1&Name={$EncodeName}&ControlID=$ControlID&Page=$Page')\">Delete</a>
					<a href=\"http://$IPv4:2020/api/api.php?Name=$EncodeName&APIKey={$APIKey}\" target='_blank'>URL</a>
					
				</div>
			  
			</div>

			</TD>
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
		
		<th align='$OAlign' colspan=3>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		";
		
	}

?>