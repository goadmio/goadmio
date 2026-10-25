<?php
include "navigator.php";
$Buttons="<a href='javascript:Load(\"$CurrentFileName?Action=Renew&Page=$Page\")' class='ButtonB {$Dir}ButtonB'>Renew Expired VPS(s)</a>";
$Buttons.="<a href='javascript:Load(\"$CurrentFileName?Action=MAC&Page=$Page\")' class='ButtonB {$Dir}ButtonB'>Generate MAC</a>";
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature is supported only on physical server hardware and will not function on VPS (Virtual Private Server) or cloud-based environments</div>";

$Edit=$_REQUEST['Edit'];
$ID=intval($_REQUEST['ID']);
$VPSID=intval($_REQUEST['VPSID']);

$ServerIP=trim($_REQUEST['ServerIP']);
$IP=trim($_REQUEST['IP']);
$CIDR=trim($_REQUEST['CIDR']);
$Gateway=trim($_REQUEST['Gateway']);
$MAC=trim($_REQUEST['MAC']);
$Hostname=trim($_REQUEST['Hostname']);
$CustomerID=intval($_REQUEST['CustomerID']);
$File=trim($_REQUEST['File']);
$DiskType=trim($_REQUEST['DiskType']);
$DiskSpace=intval($_REQUEST['DiskSpace']);
$Cores=intval($_REQUEST['Cores']);
$Memory=intval($_REQUEST['Memory']);
$Hostname=trim($_REQUEST['Hostname']);
$VPSName=trim($_REQUEST['VPSName']);
$PlanName=trim($_REQUEST['PlanName']);
$Price=trim($_REQUEST['Price']);
$ExpiresOn=substr($_REQUEST['ExpiresOn'],6,4)."-".substr($_REQUEST['ExpiresOn'],3,2)."-".substr($_REQUEST['ExpiresOn'],0,2);

If ($Action=="Renew")
{
	RenewVPS();
	exit;
}


If ($Action=="MAC")
{
	MAC();
	exit;
}

if ($_REQUEST['Action']=="Suspend")
{

	if ($_REQUEST['Suspend']=="1")
	{
		SSH ("sudo screen -d -m bash -c '/go/vps unsuspend $IP'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	else
	{
		SSH ("sudo screen -d -m bash -c '/go/vps suspend $IP'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

}


If ($Delete==1 and $Step==1)
{
	echo Error("Delete VPS IP \"{$IP}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&VPSID=$VPSID&IP=$IP&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	SQL("DELETE from VPS where VPSID='$VPSID'");
	echo Error("VPS IP $IP has been deleted.");
	

}
elseif ($ServerIP!="")
{

	$Result = SQL("select * from Server where ServerIP='$ServerIP'");
	foreach ($Result as $Row)
	{ 
		$Location=$Row['Location'];
		$AvailablePlan=$Row['AvailablePlan'];
	}


	if ($Edit==1)
	{
	

		$HostnameExists=0;
		$Result = SQL("select Hostname from VPS where Hostname='$Hostname' and VPSID!='$VPSID'");
		foreach ($Result as $Row)
		{ 
			$HostnameExists=1;
		}

		$IPExists=0;
		$Result = SQL("select Hostname from VPS where IP='$IP' and VPSID!='$VPSID'");
		foreach ($Result as $Row)
		{ 
			$IPExists=1;
		}
		
		$IDExists=0;
		$Result = SQL("select ID from VPS where ServerIP='$ServerIP' and ID='$ID' and VPSID!='$VPSID'");
		foreach ($Result as $Row)
		{ 
			$IDExists=1;
		}

		$MACExists=0;
		$Result = SQL("select MAC from VPS where MAC='$MAC' and MAC!='' and VPSID!='$VPSID'");
		foreach ($Result as $Row)
		{ 
			$MACExists=1;
		}

		if ($IDExists==0)
		{

			if ($IPExists==0)
			{

				if ($MACExists==0)
				{

					if ($HostnameExists==0)
					{

						SQL("UPDATE VPS SET ID='$ID',ServerIP='$ServerIP',IP='$IP',CIDR='$CIDR',Gateway='$Gateway',MAC='$MAC',CustomerID='$CustomerID',File='$File',DiskType='$DiskType',DiskSpace='$DiskSpace',Cores='$Cores',Memory='$Memory',Hostname='$Hostname',VPSName='$VPSName',PlanName='$PlanName',Price='$Price',ExpiresOn='$ExpiresOn',Location='$Location',AvailablePlan='$AvailablePlan' where VPSID='$VPSID'");
						echo Error("VPS IP $IP updated successfully.");
					
						$Edit="";
									
						$CustomerID="";
						$ServerIP="";
						$ID="";
						$IP="";
						$CIDR="";
						$Gateway="";
						$MAC="";
						$Hostname="";
						$VPSName="";
						$PlanName="";
						$DiskType="";
						$DiskSpace="";
						$Cores="";
						$Memory="";
						$Price="";
						$ExpiresOn="";
					
					}
					else
					{
					echo Error("Sorry, Hostname $Hostname already exists.");
					}
				}
				else
				{
				echo Error("Sorry, MAC $MAC already exists.");
				}
				
			}
			else
			{
			echo Error("Sorry, IP $IP already exists.");
			}
		
		}
		else
		{
		echo Error("Sorry, Container ID $ID already exists.");
		}
		
	}
	else
	{
		
		$HostnameExists=0;
		$Result = SQL("select Hostname from VPS where Hostname='$Hostname'");
		foreach ($Result as $Row)
		{ 
			$HostnameExists=1;
		}

		$IPExists=0;
		$Result = SQL("select Hostname from VPS where IP='$IP'");
		foreach ($Result as $Row)
		{ 
			$IPExists=1;
		}
		
		$IDExists=0;
		$Result = SQL("select ID from VPS where ServerIP='$ServerIP' and ID='$ID'");
		foreach ($Result as $Row)
		{ 
			$IDExists=1;
		}

		$MACExists=0;
		$Result = SQL("select MAC from VPS where MAC='$MAC' and MAC!=''");
		foreach ($Result as $Row)
		{ 
			$MACExists=1;
		}

		if ($IDExists==0)
		{

			if ($IPExists==0)
			{

				if ($MACExists==0)
				{

					if ($HostnameExists==0)
					{
						
						if ($CustomerID==0)
						{
						$Success=1;
						}
						else
						{
						// Create Invoice and Charge Amount from Customer
						$Amount=$Price*-1;
						$Success=Invoice ($CustomerID,"$PlsnName ($IP)",$Amount,"Entry for 1 month");
						}
						
						if ($Success==1)
						{
						$TimeStamp=time();
						SQL("INSERT INTO VPS (ID,ServerIP,IP,CIDR,Gateway,MAC,CustomerID,File,DiskType,DiskSpace,Cores,Memory,Hostname,VPSName,PlanName,Price,ExpiresOn,Location,AvailablePlan,TimeStamp) VALUES ('$ID','$ServerIP','$IP','$CIDR','$Gateway','$MAC','$CustomerID','$File','$DiskType','$DiskSpace','$Cores','$Memory','$Hostname','$VPSName','$PlanName','$Price','$ExpiresOn','$Location','$AvailablePlan','$TimeStamp')");
						echo Error("VPS IP $IP added successfully.");
							
						$CustomerID="";
						$ServerIP="";
						$ID="";
						$IP="";
						$CIDR="";
						$Gateway="";
						$MAC="";
						$Hostname="";
						$VPSName="";
						$PlanName="";
						$DiskType="";
						$DiskSpace="";
						$Cores="";
						$Memory="";
						$Price="";
						$ExpiresOn="";
						}
						else
						{
						echo Error("Sorry, Balance is not enough.");
						}
						
					}
					else
					{
					echo Error("Sorry, Hostname $Hostname already exists.");
					}
				}
				else
				{
				echo Error("Sorry, MAC $MAC already exists.");
				}
				
			}
			else
			{
			echo Error("Sorry, IP $IP already exists.");
			}
		
		}
		else
		{
		echo Error("Sorry, Container ID $ID already exists.");
		}
		
	}
}


	$NextMonth=date('Y-m-d', strtotime(' +1 month'));
	$ExpiresOn=substr($NextMonth,8,2)."/".substr($NextMonth,5,2)."/".substr($NextMonth,0,4);

	if ($Edit==1)
	{
		$Result = SQL("select * from VPS where VPSID='$VPSID'");
		foreach ($Result as $Row)
		{
	
			$ID=$Row['ID'];
			$ServerIP=$Row['ServerIP'];
			$IP=$Row['IP'];
			$MAC=$Row['MAC'];
			$CIDR=$Row['CIDR'];
			$Gateway=$Row['Gateway'];
			$CustomerID=$Row['CustomerID'];
			$File=$Row['File'];
			$DiskType=$Row['DiskType'];
			$DiskSpace=$Row['DiskSpace'];
			$Cores=$Row['Cores'];
			$Memory=$Row['Memory'];
			$Hostname=$Row['Hostname'];
			$VPSName=$Row['VPSName'];
			$PlanName=$Row['PlanName'];
			$Price=$Row['Price'];
			
			$ExpiresOn=substr($Row['ExpiresOn'],8,2)."/".substr($Row['ExpiresOn'],5,2)."/".substr($Row['ExpiresOn'],0,4);

		}
				
	}
	else
	{
		$Result = SQL("select VPSID from VPS ORDER BY VPSID DESC LIMIT 1");
		foreach ($Result as $Row)
		{
		$Hostname="vps".($Row['VPSID']+1).".{$_SERVER['HTTP_HOST']}";
		}
	
	}
	
	$Result = SQL("SELECT * FROM Customer where CustomerID>=1 order by CustomerID");
	foreach ($Result as $Row)
	{
	$Customer['CustomerID'][]=$Row['CustomerID'];
	$Customer['Email'][]=$Row['Email'];
	}
	
	$Result = SQL("SELECT * FROM Server where ServerID>=1");
	foreach ($Result as $Row)
	{
	$Server['ServerName'][]=$Row['ServerName'];
	$Server['ServerIP'][]=$Row['ServerIP'];
	}

	$Result = SQL("SELECT * FROM Distro where DistroID>=1");
	foreach ($Result as $Row)
	{
	$OS['Name'][]=$Row['Name'];
	$OS['File'][]=$Row['File'];
	}

	if ($DiskType=="")
	{
	$Result = SQL("SELECT * FROM Plan where PlanID>=1 order by DiskType,DiskSpace");
	}
	else
	{
	$Result = SQL("SELECT * FROM Plan where DiskType='$DiskType' order by DiskType,DiskSpace");
	}
	foreach ($Result as $Row)
	{
	$Plan['PlanID'][]=$Row['PlanID'];
	$Plan['PlanName'][]=$Row['PlanName'];
	$Plan['DiskType'][]=$Row['DiskType'];
	$Plan['DiskSpace'][]=$Row['DiskSpace'];
	$Plan['Cores'][]=$Row['Cores'];
	$Plan['Memory'][]=$Row['Memory'];
	$Plan['Price'][]=$Row['Price'];
	}
	

	if (RowCount("SELECT * from Server")==0)
	{

		echo Error("There are no servers. <a href=\"javascript:Load('server.php')\" class=Action>{$LNG['AddModifyServers']}</a>");
		exit;	
	
	}

	if (RowCount("SELECT * from Plan")==0)
	{
		echo Error("There are no palns. <a href=\"javascript:Load('plan.php')\" class=Action>{$LNG['AddModifyPlans']}</a>");
		exit;	
	}

	if (is_array($Customer['CustomerID']))
	{
		array_multisort($Customer['CustomerID'], SORT_ASC, SORT_NUMERIC,$Customer['Email'], SORT_STRING, SORT_DESC);
		array_multisort($Server['ServerName'], SORT_ASC, SORT_STRING,$Server['ServerIP'], SORT_NUMERIC, SORT_DESC);

		Echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
		<input type=hidden name=VPSID value='$VPSID'>
		<input type=hidden name=Edit value='$Edit'>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['CustomerID']}
		<br>

		<select name='CustomerID' id='CustomerID' class=Select>
		<option value='0' selected>Not Assigned</option>
		";
		
		for ($E=0;$E<count($Customer['CustomerID']);$E++)
		{
			if ($Customer['CustomerID'][$E]==$CustomerID)
			{
			echo "<option value='{$Customer['CustomerID'][$E]}' selected>{$Customer['CustomerID'][$E]} | {$Customer['Email'][$E]}</option>";
			}
			else
			{
			echo "<option value='{$Customer['CustomerID'][$E]}'>{$Customer['CustomerID'][$E]} | {$Customer['Email'][$E]}</option>";
			}
		}

		echo "
		</select>
			
		</div>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['ServerIP']}
		<br>
		";
			
			if ($Edit==1)
			{
			echo "
			<input type='text' name='ServerIP' id='ServerIP' value='$ServerIP' readonly maxlength=50 class=InputText>
			";
			}
			else
			{
			echo "
			<select name='ServerIP' id='ServerIP' onchange='Container()' class=Select>
			<option value='' selected>Select Server IP</option>
			";
			
			for ($E=0;$E<count($Server['ServerName']);$E++)
			{
				if ($Server['ServerIP'][$E]==$ServerIP)
				{
				echo "<option value='{$Server['ServerIP'][$E]}' selected>{$Server['ServerName'][$E]} | {$Server['ServerIP'][$E]}</option>";
				}
				else
				{
				echo "<option value='{$Server['ServerIP'][$E]}'>{$Server['ServerName'][$E]} | {$Server['ServerIP'][$E]}</option>";
				}
			}

			echo "
			</select>
			";
			}
			
		echo "
		</div>
		
		<div class='DivInput {$Dir}DivInput'>{$LNG['ContainerID']}<br>
		<input type='text' name='ID' id='ID' value='$ID' maxlength=7 class=InputText>
		</div>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['OS']}
		<br>
		";

		echo "<select name='File' id='File' class=Select>";
		echo "<option value='' selected>Select OS</option>";
		
		for ($E=0;$E<count($OS['File']);$E++)
		{
			if ($OS['File'][$E]==$File)
			{
			echo "<option value='{$OS['File'][$E]}' selected>{$OS['Name'][$E]}</option>";
			}
			else
			{
			echo "<option value='{$OS['File'][$E]}'>{$OS['Name'][$E]}</option>";
			}
		}

		echo "

		</select>
			
		</div>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['ContainerIP']}<br>
		<input type='text' name='IP' value='$IP' maxlength=15 style='width:150px' class=InputText> / <input type='text' name='CIDR' value='$CIDR' maxlength=2 placeholder='CIDR' style='width:50px' class=InputText>
		</div>
		
		<div class='DivInput {$Dir}DivInput'>Gateway<br>
		<input type='text' name='Gateway' value='$Gateway' maxlength=15 style='width:150px' class=InputText>
		</div>
		
		<div class='DivInput {$Dir}DivInput'>{$LNG['MACAddress']}<br>
		<input type='text' name='MAC' value='$MAC' maxlength=100 class=InputText>
		</div>
		
		<div class='DivInput {$Dir}DivInput'>{$LNG['Hostname']}<br>
		<input type='text' name='Hostname' value='$Hostname' maxlength=100 class=InputText required>
		</div>
		
		<div class='DivInput {$Dir}DivInput'>{$LNG['VPSName']}<br>
		<input type='text' name='VPSName' value='$VPSName' maxlength=100 class=InputText>
		</div>

		<div class='DivInput {$Dir}DivInput'>{$LNG['ExpiresOn']}<br>
		<input type='text' name='ExpiresOn' id='ExpiresOn' value='$ExpiresOn' maxlength=100 class=InputText required>
		</div>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['PlanName']}
		<br>

		<input type=hidden name=PlanName value='$PlanName' id=PlanName>
			
			<span id=DivPlan>
			<select name='Plan' id='Plan' class=Select onchange='SetPlan()'>
			<option value='' selected>Select Plan</option>
			";
			
			for ($E=0;$E<count($Plan['PlanID']);$E++)
			{
				if ($Plan['PlanName'][$E]==$PlanName)
				{
				echo "<option value='{$Plan['PlanID'][$E]}|{$Plan['PlanName'][$E]}|{$Plan['DiskType'][$E]}|{$Plan['DiskSpace'][$E]}|{$Plan['Cores'][$E]}|{$Plan['Memory'][$E]}|{$Plan['Price'][$E]}' selected>{$Plan['PlanName'][$E]}</option>";
				}
				else
				{
				echo "<option value='{$Plan['PlanID'][$E]}|{$Plan['PlanName'][$E]}|{$Plan['DiskType'][$E]}|{$Plan['DiskSpace'][$E]}|{$Plan['Cores'][$E]}|{$Plan['Memory'][$E]}|{$Plan['Price'][$E]}'>{$Plan['PlanName'][$E]}</option>";
				}
			}

			echo "
			</select>
			</span>
			
		</div>
		
		<div class='DivInput {$Dir}DivInput'>{$LNG['HardDiskType']}<br>
		<input type='text' name='DiskType' value='$DiskType' class=InputText>
		</div>

		<div class='DivInput {$Dir}DivInput'>{$LNG['DiskSpace']}<br>
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
			Echo "<input type=submit value='{$LNG['AddVPS']}' Class=InputButton>";
		}

		Echo "
		</div>

		</form>

		";

	}
	else
	{
	
		echo Error("There are no customers. <a href=\"javascript:Load('customer.php')\" class=Action>{$LNG['VPSCustomers']}</a>");
		exit;
	
	}

	if($Edit!=1)
	{
	
		include "search.php";

		Echo "
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='`10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=ServerIP')\">{$LNG['ServerIP']}</a>
		</th>
		
		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=IP')\">{$LNG['ContainerIP']}</a>
		</th>

		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=MAC')\">{$LNG['MACAddress']}</a>
		</th>

		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=PlanName')\">{$LNG['PlanName']}</a>
		</th>
		
		<th align='$DAlign' width='10%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=VPSName')\">{$LNG['VPSName']}</a>
		</th>

		<th align='$DAlign' width='5%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=CustomerID')\">{$LNG['CustomerID']}</a>
		</th>
		
		<th align='$DAlign' width='5%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Suspend')\">{$LNG['Suspend']}</a>
		</th>

		<th width='40%'>
		
		</span>
		</th>

		</tr>
		
		</THEAD>

		";

		$Table="VPS";$Field="VPSID>=1";
		$DefaultSortBy="VPSID";
		$DefaultDirection="DESC";
		include "include/sql.php";  

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			
			$VPSID=$Row['VPSID'];
			$CustomerID=$Row['CustomerID'];
			if ($CustomerID==0) 
			{
			$CustomerID="<a href='iframe/assign.php?VPSID=$VPSID' data-fancybox data-type='iframe' class=Action>Assign</a>";
			}
		
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
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
			
			if ($Row['Suspend']==1)
			{
			$SuspendCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Suspend&Suspend={$Row['Suspend']}&VPSID={$Row['VPSID']}&IP={$Row['IP']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$SuspendCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Suspend&Suspend={$Row['Suspend']}&VPSID={$Row['VPSID']}&IP={$Row['IP']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['CustomerID']}' class='$TDColor'>

			<TD>{$Row['ServerIP']}</TD>

			<TD>{$Row['IP']}</TD>
			
			<TD>{$Row['MAC']}</TD>
			
			<TD>{$Row['PlanName']}</TD>
			
			<TD>{$Row['VPSName']}</TD>

			<TD><a href=\"javascript:Load('customer.php?Edit=1&Action=Edit&CustomerID=$CustomerID&Name={$Row['Name']}')\">$CustomerID</a></TD>
			
			<TD>$SuspendCode</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Action=Edit&VPSID=$VPSID&IP={$Row['IP']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&VPSID=$VPSID&IP={$Row['IP']}')\" class=Action>Delete</a>&nbsp;
			<a href='iframe/renew.php?VPSID=$VPSID' data-fancybox data-type='iframe' class=Action>Renew</a>
			<a href='iframe/vps.php?VPSID=$VPSID' data-fancybox data-type='iframe' class=Action>OS Reinstalls</a>

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