<?php
include "navigator.php";
$Buttons="";
include "title.php";

$NotifyID=intval($_REQUEST['NotifyID']);
$Keyword=$_REQUEST['Keyword'];

if ($_SESSION['SessionType']!="Root")
{

	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	
}



if ($Action!="")
{
	include "access.php";

	if ($Action=="EnableEmail")
	{
		SQL("UPDATE Notify set Email='1' where NotifyID='$NotifyID'");
	}
	elseif ($Action=="DisableEmail")
	{
		SQL("UPDATE Notify set Email='0' where NotifyID='$NotifyID'");
	}
	

	if ($Action=="EnableWhatsapp")
	{
		SQL("UPDATE Notify set Whatsapp='1' where NotifyID='$NotifyID'");
	}
	elseif ($Action=="DisableWhatsapp")
	{
		SQL("UPDATE Notify set Whatsapp='0' where NotifyID='$NotifyID'");
	}
	
	if ($Action=="EnableMissed")
	{
		SQL("UPDATE Notify set Missed='1' where NotifyID='$NotifyID'");
	}
	elseif ($Action=="DisableMissed")
	{
		SQL("UPDATE Notify set Missed='0' where NotifyID='$NotifyID'");
	}
	
	if ($Keyword=="SSH Login")
	{
	SSH ("/usr/bin/sudo /go/basic",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}

	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>
	<THEAD>
	
	<tr>
	
    <TH width='60%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Type&Direction=ASC')\">{$LNG['Type']}</a>
	</TH>
	
    <TH width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Alert&Direction=DESC')\">{$LNG['Alerts']}</a>
	</TH>
	
    <TH align='center' width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Email&Direction=DESC')\">{$LNG['Email']}</a>
    </TH>

    <TH align='center' width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Whatsapp&Direction=DESC')\">{$LNG['Whatsapp']}</a> 
    </TH>
	
    <TH align='center' width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?&SortBy=Missed&Direction=DESC')\">{$LNG['MissedCall']}</a>
    </TH>

	</tr>
	
	</THEAD>
	";
		
	$Table="Notify";$Field="NotifyID>0";
	$DefaultSortBy="Alert";
	$DefaultDirection="DESC";
	include "include/sql.php";    

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$ID=$Row['NotifyID'];
		
		$NotifyID=$Row['NotifyID'];
		
		$Alert=$Row['Alert'];
	
		$Type=$Row['Type'];
		$Keyword=$Row['Keyword'];
		
		$Email=$Row['Email'];
		$Whatsapp=$Row['Whatsapp'];
		$Missed=$Row['Missed'];
	
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


    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Keyword']}-{$Row['Type']}-{$Row['Description']}'>

    <TD>
    $Type
	<br>
    {$Row['Description']}
    </td>

    <TD>
    {$Row['Alert']}
    </td>

	<TD align='center'>
	";
	
	if ($Email==1)
	{	
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableEmail&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableEmail&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>
	";
	}
	
	echo "
	</td>
    
	<TD align='center'>
	";
	
	if ($Whatsapp==1)
	{	
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableWhatsapp&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableWhatsapp&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>
	";
	}
	
	echo "
	</td>

	<TD align='center'>
	";
	
	if ($Missed==1)
	{	
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableMissed&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox' checked>
	<span></span>
	</label>
	";
	}
	else
	{
	echo "
	<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableMissed&NotifyID=$NotifyID&Keyword=$Keyword&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
	<input type='checkbox'>
	<span></span>
	</label>
	";
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