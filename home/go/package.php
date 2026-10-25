<?php

include "navigator.php";
$Buttons="";
include "title.php";

$Edit=$_REQUEST['Edit'];
$PackageID=$_REQUEST['PackageID'];

$Name=trim($_REQUEST['Name']);
$DiskSpace=intval($_REQUEST['DiskSpace'])*1048576;
$Bandwidth=intval($_REQUEST['Bandwidth'])*1048576;
$Inode=intval($_REQUEST['Inode']);
$FTPNo=intval($_REQUEST['FTPNo']);
$EmailNo=intval($_REQUEST['EmailNo']);
$DatabaseNo=intval($_REQUEST['DatabaseNo']);
$SubDomainNo=intval($_REQUEST['SubDomainNo']);
$AliasNo=intval($_REQUEST['AliasNo']);
$AddonNo=intval($_REQUEST['AddonNo']);

if (is_array($_REQUEST['ControlFile']))
{
$ControlFile=implode("|",$_REQUEST['ControlFile']);
}

If ($Delete==1 and $Step==1)
{
	echo Error("Delete Package \"{$Name}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&PackageID=$PackageID&Name=$Name&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{

	SQL("DELETE from Package where PackageID='$PackageID'");
	echo Error("Package $Name has been deleted.");
	

}
elseif ($Name!="" and $Action!="Edit")
{
	if ($Edit==1)
	{
	
	
		SQL("UPDATE Package SET Name='$Name',DiskSpace='$DiskSpace',Bandwidth='$Bandwidth',Inode='$Inode',FTPNo='$FTPNo',EmailNo='$EmailNo',DatabaseNo='$DatabaseNo',SubDomainNo='$SubDomainNo',AliasNo='$AliasNo',AddonNo='$AddonNo',Shell='$Shell',SSLCertificate='$SSLCertificate',ControlFile='$ControlFile' where PackageID='$PackageID'");
		echo Error("Package $Name updated successfully.");
	
		$Edit="";
	}
	else
	{
		$TimeStamp=time();
	    SQL("INSERT INTO Package (Name,DiskSpace,Bandwidth,Inode,FTPNo,EmailNo,DatabaseNo,SubDomainNo,AliasNo,AddonNo,Shell,SSLCertificate,ControlFile,TimeStamp,UserID) VALUES ('$Name','$DiskSpace','$Bandwidth','$Inode','$FTPNo','$EmailNo','$DatabaseNo','$SubDomainNo','$AliasNo','$AddonNo','$Shell','$SSLCertificate','$ControlFile','$TimeStamp','{$_SESSION['SessionUserID']}')");
		echo Error("Package $Name created successfully.");
		
	}
}

	$Name="";
	$DiskSpace="";
	$Bandwidth="";
	$Inode="";
	$FTPNo="";
	$EmailNo="";
	$DatabaseNo="";
	$SubDomainNo="";
	$AliasNo="0";
	$AddonNo="0";
	$Shell="";
	$SSLCertificate="";
	$ControlFile="";

	if ($Edit==1)
	{
		$Sql = "select * from Package where PackageID='$PackageID'";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{ 
	
			$Name=$Row['Name'];
			$DiskSpace=intval($Row['DiskSpace'])/1048576;
			$Bandwidth=intval($Row['Bandwidth'])/1048576;
			$Inode=$Row['Inode'];
			$FTPNo=$Row['FTPNo'];
			$EmailNo=$Row['EmailNo'];
			$DatabaseNo=$Row['DatabaseNo'];
			$SubDomainNo=$Row['SubDomainNo'];
			$AliasNo=$Row['AliasNo'];
			$AddonNo=$Row['AddonNo'];
			$Shell=$Row['Shell'];
			$SSLCertificate=$Row['SSLCertificate'];
			$ControlFile=$Row['ControlFile'];

		}
				
	}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=PackageID value='$PackageID'>
	<input type=hidden name=Edit value='$Edit'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['PackageName']}<br>
	<input type='text' name='Name' value='$Name' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['DiskSpace']}<br>
	<input type='text' name='DiskSpace' value='$DiskSpace' placeholder='Unlimited' maxlength=100 class=InputText> MB
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MonthlyBandwidth']}<br>
	<input type='text' name='Bandwidth' value='$Bandwidth' placeholder='Unlimited' maxlength=100 class=InputText> MB
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['InodeLimit']}<br>
	<input type='text' name='Inode' value='$Inode' placeholder='Unlimited' maxlength=10 class=InputText> Files
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxFTPAccounts']}<br>
	<input type='text' name='FTPNo' value='$FTPNo' placeholder='Unlimited' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxEmailAccounts']}<br>
	<input type='text' name='EmailNo' value='$EmailNo' placeholder='Unlimited' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxDatabases']}<br>
	<input type='text' name='DatabaseNo' value='$DatabaseNo' placeholder='Unlimited' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxSubDomains']}<br>
	<input type='text' name='SubDomainNo' value='$SubDomainNo' placeholder='Unlimited' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxParkedDomains']}<br>
	<input type='text' name='AliasNo' value='$AliasNo' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['MaxAddonDomains']}<br>
	<input type='text' name='AddonNo' value='$AddonNo' maxlength=100 class=InputText>
	</div>
	";

	$X=0;
	$Result = SQL("select * from Control where Service>=3 order by Priority,Sort");
	foreach ($Result as $Row)
	{
		$X++;
		$Control=$LNG[$Row['Control']];
		$ControlMenu=$LNG[$Row['ControlMenu']];

		$ControlUrl=$Row['ControlUrl'];
		$ControlUrlArray=explode("?",$ControlUrl);
	

		if ($ControlMenu!=$LastControlMenu)
		{
		echo "
		<div class='DivInput {$Dir}DivInput'>$ControlMenu:</div>
		";
		}

		if ($Edit==1)
		{
			if (stristr("|$ControlFile|","|{$ControlUrlArray[0]}|"))
			{
			$ControlFileChecked="checked";
			}
			else
			{
			$ControlFileChecked="";
			}

		}
		else
		{
		$ControlFileChecked="checked";
		}

		echo "
		<div class=DivCheckbox>
		
			<label class=LabelCheckbox>$Control
				<input type='checkbox' name='ControlFile[]' value='{$ControlUrlArray[0]}' $ControlFileChecked>
				<span class='Checkbox'></span>
			</label>
		
		</div>
		";

		$LastControlMenu=$ControlMenu;

	}


	echo "
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

		Echo "
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
	
		<th width='2%' height=40>

		</th>
		
		<th align='$DAlign' width='38%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=Name')\">Name</a>
		</th>
		
		<th align='$DAlign' width='30%'>
		<a href=\"javascript:Load('$CurrentFileName?&SortBy=DiskSpace')\">Disk Space</a>
		</th>

		<th width='30%'>
		
		</span>
		</th>

		</tr>
		
		</THEAD>
		";

		$X=0;
		$Result = SQL("SELECT * FROM Package WHERE UserID='{$_SESSION['SessionUserID']}' ORDER BY Name");
		foreach ($Result as $Row)
		{
			
			$PackageID=$Row['PackageID'];
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
			
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Email']}' class='$TDColor'>

			<TD align='middle'>
			{$Row['PackageID']}
			</TD>

			<TD>{$Row['Name']}</TD>

			<TD>{$Row['DiskSpace']}</TD>
			
			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&Action=Edit&PackageID={$Row['PackageID']}&Name={$Row['Name']}')\" class=Action>Edit</a>&nbsp;
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&PackageID={$Row['PackageID']}&Name={$Row['Name']}')\" class=Action>Delete</a>&nbsp;

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
				
		// include "pages.php";

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