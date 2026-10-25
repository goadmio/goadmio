<?php

include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=DiskUsage&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>Update Disk Usage</a>";
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature is supported only on physical server hardware and will not function on VPS (Virtual Private Server) or cloud-based environments</div>";

$Edit=$_REQUEST['Edit'];
$ServerID=$_REQUEST['ServerID'];

$ServerName=trim($_REQUEST['ServerName']);
$ServerIP=trim($_REQUEST['ServerIP']);
$Subnet=trim($_REQUEST['Subnet']);
$CIDR=trim($_REQUEST['CIDR']);
$Location=trim($_REQUEST['Location']);
$DiskType=trim($_REQUEST['DiskType']);
$DiskSpace=intval($_REQUEST['DiskSpace']);
$AvailablePlan=trim($_REQUEST['AvailablePlan']);



If ($Delete==1 and $Step==1)
{
	echo Error("Delete Server \"{$ServerName}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&ServerIP=$ServerIP&ServerName=$ServerName&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{
	SQL("DELETE from Server where ServerIP='$ServerIP'");
	SQL("DELETE from VPS where ServerIP='$ServerIP'");
	echo Error("Server $ServerName has been deleted.");
}
elseif ($ServerName!="" and $Action!="Edit")
{

	if ($Edit==1)
	{
		SQL("UPDATE VPS SET Location='$Location',AvailablePlan='$AvailablePlan',DiskType='$DiskType' where ServerIP='$ServerIP'");
	
		SQL("UPDATE Server SET ServerName='$ServerName',ServerIP='$ServerIP',Subnet='$Subnet',CIDR='$CIDR',Location='$Location',AvailablePlan='$AvailablePlan',DiskType='$DiskType',DiskSpace='$DiskSpace' where ServerID='$ServerID'");
		echo Error("Server $ServerName updated successfully.");
	
		$Edit="";
	}
	else
	{
		$TimeStamp=time();
	    SQL("INSERT INTO Server (ServerName,ServerIP,Subnet,CIDR,Location,AvailablePlan,DiskType,DiskSpace) VALUES ('$ServerName','$ServerIP','$Subnet','$CIDR','$Location','$AvailablePlan','$DiskType','$DiskSpace')");
		echo Error("Server $ServerName created successfully.");
		
		if ($Subnet!="" and $CIDR!="" and $ServerIP!="")
		{
			echo Subnet($Subnet,$CIDR,$ServerIP);
		}

		
		
	}
}

	$ServerName="";
	$ServerIP="";
	$Subnet="";
	$CIDR="";

	if ($Edit==1)
	{
		$Sql = "select * from Server where ServerID='$ServerID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
			$ServerName=$Row['ServerName'];
			$ServerIP=$Row['ServerIP'];
			$Subnet=$Row['Subnet'];
			$CIDR=$Row['CIDR'];
			$Location=$Row['Location'];
			$DiskType=$Row['DiskType'];
			$DiskSpace=$Row['DiskSpace'];
			
			if ($DiskType=="SATA HDD")
			{
			$SelectedSATA="selected";
			}
			
			if ($DiskType=="SSD")
			{
			$SelectedSSD="selected";
			}

			if ($DiskType=="NVMe SSD")
			{
			$SelectedNVMeSSD="selected";
			}
			
			$AvailablePlan=$Row['AvailablePlan'];
			
		}
				
	}

	if ($Action=="DiskUsage")
	{
	$Error=SSH ("/usr/bin/sudo /go/vps diskusage",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo  Error($Error);
	}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=ServerID value='$ServerID'>
	<input type=hidden name=Edit value='$Edit'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['ServerName']}<br>
	<input type='text' name='ServerName' value='$ServerName' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['ServerIP']}<br>
	<input type='text' name='ServerIP' value='$ServerIP' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Subnet<br>
	<input type='text' name='Subnet' value='$Subnet' maxlength=15 style='width:150px' class=InputText> / <input type='text' name='CIDR' value='$CIDR' maxlength=2 placeholder='CIDR' style='width:50px' class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Location']}<br>
	<input type='text' name='Location' value='$Location' maxlength=50 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['HardDiskType']}<br>
	
		<select name='DiskType' id='DiskType' class=Select>
		<option value='' selected>Select Harddisk Type</option>
		<option value='SATA HDD' $SelectedSATA>SATA HDD</option>
		<option value='SSD' $SelectedSSD>SSD</option>
		<option value='NVMe SSD' $SelectedNVMeSSD>NVMe SSD</option>
		</select>
			
	
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['AvailablePlans']}<br>
	";
		if ($DiskType=="")
		{
		$Sql = "select * from Plan where PlanID>=1";
		}
		else
		{
		$Sql = "select * from Plan where DiskType='$DiskType'";
		}
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			if (stristr($AvailablePlan,"|{$Row['PlanName']}|"))
			{
			echo "<label><input type='checkbox' name='AvailablePlan' id='AvailablePlan' value='{$Row['PlanName']}' checked> {$Row['PlanName']}</label><br>";
			}
			else
			{
			echo "<label><input type='checkbox' name='AvailablePlan' id='AvailablePlan' value='{$Row['PlanName']}'> {$Row['PlanName']}</label><br>";
			}
		}
	
	echo "
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['DiskSpace']}<br>
	<input type='number' name='DiskSpace' value='$DiskSpace' min=1 max=1000000 class=InputText> GB
	</div>

	<div id=DivSubmit class=DivSubmit>
	
	";

	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['AddServer']}' Class=InputButton>";
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

		
		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=ServerName')\">{$LNG['ServerName']}</a>
		</th>
		
		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=ServerIP')\">{$LNG['ServerIP']}</a>
		</th>

		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=DiskType')\">{$LNG['HardDiskType']}</a>
		</th>


		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=DiskUsage')\">{$LNG['DiskUsage']}</a>
		</th>


		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=MemoryUsage')\">{$LNG['MemoryUsage']}</a>
		</th>


		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=MemoryUsage')\">Assigned VPS</a>
		</th>


		<th width='30%'>
		
		</th>

		</tr>
		
		</THEAD>

		";

		$Table="Server";$Field="ServerID>=1";
		$DefaultSortBy="ServerName";
		$DefaultDirection="ASC";
		include "include/sql.php";  

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
			$ServerID=$Row['ServerID'];
			$ServerIP=$Row['ServerIP'];
			
		
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
			
			
			$AssignedVPS=RowCount("SELECT count(VPSID) FROM VPS where ServerIP='$ServerIP' and CustomerID>=1");

			
			// $CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['ServerIP']}' class='$TDColor'>

			<TD>{$Row['ServerName']}</TD>

			<TD>{$Row['ServerIP']}</TD>

			<TD>{$Row['DiskType']}</TD>

			<TD>{$Row['DiskUsage']}%</TD>
			
			<TD>{$Row['MemoryUsage']}%</TD>
			
			<TD>$AssignedVPS</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Action=Edit&ServerID={$Row['ServerID']}&ServerName={$Row['ServerName']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&ServerIP={$Row['ServerIP']}&ServerName={$Row['ServerName']}')\" class=Action>Delete</a>&nbsp;
			<a href=\"iframe/subnet.php?ServerIP={$Row['ServerIP']}\" data-fancybox data-type='iframe' class=Action>Add Additional Subnets</a>&nbsp;
			<a href=\"iframe/dhcpd.php?ServerIP={$Row['ServerIP']}\" target='_blank' class=Action>Download dhcpd.conf</a>&nbsp;

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