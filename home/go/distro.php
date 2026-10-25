<?php
include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Restore&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature is supported only on physical server hardware and will not function on VPS (Virtual Private Server) or cloud-based environments</div>";

$File=trim($_REQUEST['File']);
$Name=trim($_REQUEST['Name']);
$DistroID=$_REQUEST['DistroID'];

if ($Action=="Restore")
{
	include "update/distro.php";
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;

}


if ($Action=="Enable")
{
	SQL("UPDATE Distro set Active=1 where DistroID='$DistroID'");
}

if ($Action=="Disable")
{
	SQL("UPDATE Distro set Active=0 where DistroID='$DistroID'");
}

if ($Name!="" and $File!="")
{

	if ($Edit==1)
	{
	SQL("UPDATE Distro set Name='$Name',File='$File' where DistroID='$DistroID'");
	}
	else
	{
	SQL("INSERT INTO Distro (Name,File) VALUES ('$Name','$File')");
	}
	
	$Edit=0;
	$Name="";
	$File="";



}

If ($Delete==1 and $Step==1)
{
	echo Error("Delete \"{$Name}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&DistroID=$DistroID&Name=$Name&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName')\" class=Action>No</a>");
	
	exit;
}

if ($Delete==1 and $Step==2)
{
	SQL("Delete FROM Distro where DistroID='$DistroID'");
}


	if ($Edit==1)
	{
		$Result = SQL("select * from Distro where DistroID='$DistroID'");
		foreach ($Result as $Row)
		{

			$File=$Row['File'];
			$Name=$Row['Name'];

		}
	}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=DistroID value='$DistroID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['DistroName']}<br>	
	<input type='Text' name='Name' value='$Name' maxlength=255 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['FileName']}<br>
	<input type='text' name='File' value='$File' maxlength=100 class=InputText>
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


	Echo "
	</div>

</form>
";



		include "search.php";

		echo "

		<div class=DivXTable>
		<table cellPadding='8' cellSpacing=0 width='100%' class=Table>
		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='25%'>
		{$LNG['DistroName']}
		</th>
		
		<th align='$DAlign' width='25%'>
		{$LNG['DistroFile']}
		</th>
		
		<th align='$DAlign' width='25%'>
		{$LNG['Active']}
		</span>
		</th>
		
		<th align='$OAlign' width='25%'>

		</th>
		
		</tr>
		
		</THEAD>

		";

		$Table="Distro";$Field="DistroID>=1";
		$DefaultSortBy="Name";
		$DefaultDirection="ASC";
		include "include/sql.php";
		
		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		$Name=$Row['Name'];
		$File=$Row['File'];


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
			
			


			if ($Row['Active']==1)
			{
			$ActiveCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Disable&DistroID={$Row['DistroID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$ActiveCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Enable&DistroID={$Row['DistroID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}
			
			
			echo "
			
			<tr name=R$i id=R$i divid=Find find='{$Row['Name']}-{$Row['File']}' class='$TDColor'>

			<TD>{$Row['Name']}</TD>
			
			<TD>{$Row['File']}</TD>
			
			<TD>$ActiveCode</TD>
			
			<TD align='$OAlign'>  
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&DistroID={$Row['DistroID']}')\" class=Action>Edit</a>

			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&DistroID={$Row['DistroID']}&Name={$Row['Name']}')\" class=Action>Delete</a>

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

		<tr class=TdDown>

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=4>
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