<?php
include "navigator.php";
$Buttons="";
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature is supported only on physical server hardware and will not function on VPS (Virtual Private Server) or cloud-based environments</div>";

$Edit=$_REQUEST['Edit'];
$PlanID=$_REQUEST['PlanID'];

$PlanName=trim($_REQUEST['PlanName']);
$Location=trim($_REQUEST['Location']);
$DiskType=trim($_REQUEST['DiskType']);
$DiskSpace=intval($_REQUEST['DiskSpace']);
$Cores=intval($_REQUEST['Cores']);
$Memory=intval($_REQUEST['Memory']);
$Price=trim($_REQUEST['Price']);

If ($Delete==1 and $Step==1)
{
	echo Error("Delete Plan \"{$PlanName}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&PlanID=$PlanID&Name=$PlanName&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	SQL("DELETE from Plan where PlanID='$PlanID'");
	echo Error("Plan $PlanName has been deleted.");
	

}
elseif ($PlanName!="" and $Action!="Edit")
{

	if ($Edit==1)
	{
	
		SQL("UPDATE Plan SET PlanName='$PlanName',Location='$Location',DiskType='$DiskType',DiskSpace='$DiskSpace',Cores='$Cores',Memory='$Memory',Price='$Price' where PlanID='$PlanID'");
		echo Error("Plan $PlanName updated successfully.");
		
	
	$Edit="";
	}
	else
	{
		$TimeStamp=time();
		SQL("INSERT INTO Plan (PlanName,Location,DiskType,DiskSpace,Cores,Memory,Price) VALUES ('$PlanName','$Location','$DiskType','$DiskSpace','$Cores','$Memory','$Price')");
		echo Error("Plan $PlanName created successfully.");
		
	}
}

	$PlanName="";
	$Location="";
	$DiskType="";
	$DiskSpace="";
	$Cores="";
	$Memory="";
	$Price="";
	if ($Edit==1)
	{
		$Sql = "select * from Plan where PlanID='$PlanID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
	
			$PlanName=$Row['PlanName'];
			$Location=$Row['Location'];
			$DiskType=$Row['DiskType'];
			$DiskSpace=$Row['DiskSpace'];
			$Cores=$Row['Cores'];
			$Memory=$Row['Memory'];
			$Price=$Row['Price'];

		}
				
	}


	if ($_REQUEST['Action']=="InStock")
	{

		if ($_REQUEST['InStock']=="1")
		{
			SQL("update Plan set InStock=0 where PlanID='$PlanID'");	
		}
		else
		{
			SQL("update Plan set InStock=1 where PlanID='$PlanID'");
		}

	}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=PlanID value='$PlanID'>
	<input type=hidden name=Edit value='$Edit'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['PlanName']}<br>
	<input type='text' name='PlanName' value='$PlanName' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Location']}<br>
	<input type='text' name='Location' value='$Location' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['HardDiskType']}<br>
	
		<input type='text' name='DiskType' list='DiskType' value='$DiskType' required maxlength=100 class=InputText>
	
		<datalist id='DiskType'>
		<option label='SATA HDD' value='SATA HDD'>
		<option label='SSD' value='SSD'>
		<option label='NVMe SSD' value='NVMe SSD'>
		</datalist>
			
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['DiskSpace']}<br>
	<input type='number' name='DiskSpace' value='$DiskSpace' min=1 max=64000 class=InputText> GB
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Cores']}<br>
	<input type='number' name='Cores' value='$Cores' min=1 max=64 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Memory']}<br>
	<input type='number' name='Memory' value='$Memory' min=1 max=256 class=InputText> GB
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Price']}<br>
	<input type='number' name='Price' value='$Price' min=1 max=10000 step='.01' class=InputText>
	</div>
		
	<div id=DivSubmit class=DivSubmit>
	
	";

	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['Add']}' Class=InputButton>";
	}


	Echo "
	</div>

</form>


";


	if($Edit!=1)
	{
	
		include "search.php";

		Echo "
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='20%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=PlanName')\">Plan Name</a>
		</th>
		
		<th align='$DAlign' width='15%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=DiskSpace')\">Disk Space</a>
		</th>

		<th align='$DAlign' width='15%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Cores')\">Cores</a>
		</th>

		<th align='$DAlign' width='15%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Memory')\">Memory</a>
		</th>

		<th align='$DAlign' width='15%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Price')\">Price</a>
		</th>

		<th align='$DAlign' width='15%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=InStock')\">In Stock</a>
		</th>

		<th width='20%'>
		
		</th>

		</tr>
		
		</THEAD>

		";

		$Table="Plan";$Field="PlanID>=1";
		$DefaultSortBy="PlanName";
		$DefaultDirection="ASC";
		include "include/sql.php";  

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
			$PlanID=$Row['PlanID'];
			$Email=$Row['Email'];
		
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
			
			
			if ($Row['InStock']==1)
			{
			$InStockCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=InStock&InStock={$Row['InStock']}&PlanID={$Row['PlanID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$InStockCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=InStock&InStock={$Row['InStock']}&PlanID={$Row['PlanID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['PlanName']}' class='$TDColor'>

			<TD>{$Row['PlanName']}</TD>

			<TD>{$Row['DiskSpace']}</TD>
			
			<TD>{$Row['Cores']}</TD>
			
			<TD>{$Row['Memory']}</TD>
			
			<TD>{$Row['Price']}</TD>
			
			<TD>$InStockCode</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Action=Edit&PlanID={$Row['PlanID']}&PlanName={$Row['PlanName']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&PlanID={$Row['PlanID']}&PlanName={$Row['PlanName']}')\" class=Action>Delete</a>&nbsp;

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

		<th align='$DAlign' colspan=2>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=2>
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
		
		
		
	}


echo "
</div>
";

	
?>