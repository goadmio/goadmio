<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

if ($Action=="Export")
{
header("Content-Disposition: attachment; filename=parked-domain.txt");
header("Pragma: no-cache");
header("Expires: 0");

	$Result = SQL("select * from Block where BlockID>=1 order by Block ASC");
	foreach ($Result as $Row)
	{
	echo "{$Row['Block']}\n";
	}


exit;
}

$IP=trim($_REQUEST['IP']);
$Domain=ValidateDomain($_REQUEST['Domain']);

if ($Action=="Delete")
{
	include "access.php";
	
	SQL("DELETE FROM Block WHERE IP='$IP'");

	$Error=SSH ("sudo screen -d -m bash -c '/go/unblock $IP > /var/log/go/block/unblock-$IP-go-$Domain.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("The following IP address is now able to access your site: $IP");

}
elseif ($_REQUEST['IP']!="")
{
	include "access.php";

	$Error=SSH ("sudo screen -d -m bash -c '/go/block $IP go $Domain > /var/log/go/block/block-$IP-go-$Domain.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Users from the IP address(es) $IP will not be able to access your site. <a href=\"javascript:Load('$CurrentFileName?Action=Delete&IP=$IP&Domain=$Domain&Username=$Username')\" class=Action>Undo</a>");


	
}
	
	echo "

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=BlockID value='$BlockID'>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	";

		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Account['Domain'][]=$Row['Domain'];
		$Account['Username'][]=$Row['Username'];
		}
		
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);

		echo "<select name='Domain' id='Username' class=Select>";
		
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			echo "<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]}</option>";
			}
			else
			{
			echo "<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]}</option>";
			}
		}

		echo "</select>";
	
	echo "
	</div>

	
	<div class='DivInput {$Dir}DivInput'>{$LNG['IP']}<br>
	
	<input type='text' name='IP' pattern=\"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$\" title=\"Enter a valid IPv4 address (e.g., 192.168.1.1)\" required maxlength=100 class=InputText size=40>
	
	</div>
	

	<div id=DivSubmit class=DivSubmit>
	";
	
	if ($Edit==1)
	{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		Echo "<input type=submit value='{$LNG['Block']}' Class=InputButton>";
	}

	Echo "
	</div>

</form>


	<div <div class='TitleB {$Dir}TitleB'>
	{$LNG['CurrentlBlockedIPAddresses']}
	</div>
	";
	

	include "search.php";
	
	echo "
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
	<th align='$DAlign' width='30%'>
	{$LNG['IP']}
	</th>
	
	<th align='$DAlign' width='15%'>
	{$LNG['Domain']}
	</th>
	
	<th align='$DAlign' width='10%'>
	{$LNG['Country']}
	</th>

	<th align='$DAlign' width='20%'>
	{$LNG['CreatedDate']}
	</th>

	<th align='$OAlign' width='15%'>

	</th>

	</tr>
	
	</THEAD>
	
	";



	$Table="Block";$Field="BlockID>=1";
	$DefaultSortBy="BlockID";
	$DefaultDirection="DESC";
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

		$SerialNo=(($Page-1)*$PageNo)+$x;
		
		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

		Echo "
		<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['IP']}-{$Row['Domain']}-{$Row['Country']}'>

		<TD><a href='http://{$Row['IP']}' target='_blank'>{$Row['IP']}</a></TD>

		<TD> {$Row['Domain']} </TD>
		<TD> {$Row['Country']} </TD>
		
		<TD> $CreatedDate </TD>

		<TD align='$OAlign'>
		
		<a href=\"javascript:Load('$CurrentFileName?Action=Delete&IP={$Row['IP']}&Domain={$Row['Domain']}&Username={$Row['Username']}')\" class=Action>Delete</a>

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
	
	<th align='$OAlign' colspan=4>
	";
			
	include "pages.php";

	echo "
	</th>

    </tr>

	</TFOOT>
	

	
    </TABLE>
	</form>

	";




?>