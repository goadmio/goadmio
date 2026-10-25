</TD><?php
include "navigator.php";
$Buttons="
<a href=\"phpmyadmin.php\" target='_blank' class='ButtonB {$Dir}ButtonB'>phpMyAdmin</a>
";
include "title.php";

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}


$Edit=$_REQUEST['Edit'];

$Name=$_REQUEST['Name'];
$TableName=$_REQUEST['TableName'];
$Columns=$_REQUEST['Columns'];
$ApiKey=$_REQUEST['ApiKey'];
$Domain=ValidateDomain($_REQUEST['Domain']);
$MobileApiID=$_REQUEST['MobileApiID'];

If ($Delete==1 and $Step==1)
{
	echo Error("Delete \"{$Name}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&MobileApiID=$MobileApiID&Name=$Name&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	$Sql = "DELETE from MobileApi where MobileApiID='$MobileApiID'";
	$Result = SQL($Sql);
	If ($Result)
	{
		echo Error("API $Name ($MobileApiID) has been deleted.");
	}

}
elseif ($_REQUEST['TableName']!="")
{

	if ($Edit==1)
	{
	
		$Sql = "UPDATE MobileApi SET Name='$Name',TableName='$TableName',Columns='$Columns',ApiKey='$ApiKey',Domain='$Domain' where MobileApiID='$MobileApiID'";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("API $Name ($MobileApiID) updated successfully.");
		}
	
	$Edit="";
	}
	else
	{
		$TimeStamp=time();
		$Sql = "INSERT INTO MobileApi (Name,TableName,Columns,ApiKey,Domain,TimeStamp) VALUES ('$Name','$TableName','$Columns','$ApiKey','$Domain','$TimeStamp')";
		$Result = SQL($Sql);
		If ($Result)
		{
		echo Error("API $Name created successfully.");
		}
	}
}

	$Name="";
	$TableName="";
	$Columns="";
	$ApiKey="";
	$Domain="";
	if ($Edit==1)
	{
		$Sql = "select * from MobileApi where MobileApiID='$MobileApiID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
	
			$Name=$Row['Name'];
			$TableName=$Row['TableName'];
			$Columns=$Row['Columns'];
			$ApiKey=$Row['ApiKey'];
			$Domain=$Row['Domain'];

		}
				
	}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=MobileApiID value='$MobileApiID'>

	<div class='DivInput {$Dir}DivInput'>Domain<br>

		<select name='Domain' class=Select>
		";
		
		$Sql = "select * from Site where Trash=0 $SearchSql order by Domain";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			if ($Row['Domain']==$Domain)
			{
			echo "<option value='{$Row['Domain']}' selected>{$Row['Domain']}</option>";
			}
			else
			{
			echo "<option value='{$Row['Domain']}'>{$Row['Domain']}</option>";
			}
		}
		
		echo "
		</select>
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>Database Name<br>

		<select name='Name' class=Select>
		";
		
		$Sql = "select * from Mysql where MysqlID>=1 $SearchSql order by Name";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			if ($Row['Name']==$Name)
			{
			echo "<option value='{$Row['Name']}' selected>{$Row['Name']}</option>";
			}
			else
			{
			echo "<option value='{$Row['Name']}'>{$Row['Name']}</option>";
			}
		}
		
		echo "
		</select>
	
	</div>

	<div class='DivInput {$Dir}DivInput'>Table Name<br>
	<input type='Text' name='TableName' value='$TableName' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Columns<br>
	<input type='Text' name='Columns' value='$Columns' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>API Key<br>
	<input type='Text' name='ApiKey' value='$ApiKey' maxlength=100 class=InputText>
	</div>
	
	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
			echo "<input type=submit value='Save Changes' Class=InputButton>";
		}
		else
		{
			echo "<input type=submit value='Create' Class=InputButton>";
		
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
		
		<th width='2%'>

		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=Name')\">Name</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=Domain')\">Domain</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=TableName')\">TableName</a>
		</th>
		
		<th align='$DAlign' width='17%'>
		<a href=\"javascript:Load('$CurrentFileName?SortBy=TimeStamp')\">Created Date</a>
		</th>
		
		<th width='30%'>
	
		</th>

		</tr>
		
		</THEAD>

		";
		

		$Table="MobileApi";$Field="MobileApiID>=1";
		$DefaultSortBy="Name";
		$DefaultDirection="ASC";
		include "include/sql.php";
		
		

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			$MobileApiID=$Row['MobileApiID'];
			
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
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			echo "
			
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Name']}-{$Row['TableName']}-{$Row['Columns']}-{$Row['Domain']}'>

			<TD align='middle'>
			$SerialNo
			</TD>

			<TD align='$DAlign'><a  href='$CurrentFileName?MobileApiID={$Row['MobileApiID']}&PHPMyAdmin=1&ServiceControl=$ServiceControl' target='_blank'>{$Row['Name']}</a></TD>

			<TD align='$DAlign'>{$Row['Domain']}</TD>
			
			<TD align='$DAlign'>{$Row['TableName']}</TD>
						
			<TD align='$DAlign'>$CreatedDate</TD>

			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&MobileApiID={$Row['MobileApiID']}&Name={$Row['Name']}&Domain={$Row['Domain']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Edit</a>
			
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&MobileApiID={$Row['MobileApiID']}&Step=1&Name={$Row['Name']}&Domain={$Row['Domain']}&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Delete</a>
			<a href=\"https://go.{$Row['Domain']}/json.php?MobileApiID={$Row['MobileApiID']}&ApiKey={$Row['ApiKey']}&OrderBy=&DESC=0&Start=&Limit=\" target='_blank' class=Action>JSON</a>

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