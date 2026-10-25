<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$Delete=$_REQUEST['Delete'];
$Step=$_REQUEST['Step'];
$RedirectUrl=trim($_REQUEST['RedirectUrl']);

$SubdomainID=$_REQUEST['SubdomainID'];
$RedirectUrl=$_REQUEST['RedirectUrl'];
$Directory=ValidateDirectory($_REQUEST['Directory']);

$DocumentRoot=ValidateDirectory($_REQUEST['DocumentRoot']);

$DocumentRoot=trim($DocumentRoot,"/");

$Domain=ValidateDomain($_REQUEST['Domain']);

$Subdomain=strtolower("$Directory.$Domain");

If ($Delete==1 and $Step==1)
{

	echo Error("Delete \"{$_REQUEST['Subdomain']}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Subdomain={$_REQUEST['Subdomain']}&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
	$Subdomain=$_REQUEST['Subdomain'];
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/subdomain $Subdomain delete'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo Error("Subdomain \"$Subdomain\" has been deleted.");
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
}

if ($_REQUEST['Directory']!="")
{
	$Domain=ValidateDomain($_REQUEST['Domain']);
	$Domain=strtolower($Domain);

	$Sql = "select SubDomainNo,Username from Site where Domain='$Domain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{

		$Username=$Row['Username'];

		if ($Row['SubDomainNo']==-1)
		{
		echo "<div class='UnderTitle'>This feature has been disabled by your administrator.</div>";
		exit;
		}
	
	}
	
	include "access.php";

	if ($Edit==1)
	{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/subdomain --subdomain $Subdomain --documentroot $DocumentRoot --redirecturl $RedirectUrl --action edit'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Subdomain \"$Subdomain\" Edited Successfully.");
	}
	else
	{
		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/subdomain --subdomain $Subdomain --documentroot $DocumentRoot --redirecturl $RedirectUrl'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Subdomain \"$Subdomain\" Created Successfully.");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}


	if ($Edit==1)
	{

		$Result = SQL("select * from Subdomain where SubdomainID='$SubdomainID'");
		foreach ($Result as $Row)
		{
		$Username=$Row['Username'];
		$Subdomain=$Row['Subdomain'];
		
		$SubdomainArray=explode(".",$Subdomain);
		$Directory=$SubdomainArray[0];
		
		$DocumentRoot=$Row['DocumentRoot'];
		$RedirectUrl=$Row['RedirectUrl'];
		}
		
	}

	unset($Domains);
	$Sql = "select * from Site where Trash=0 $SearchSql";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$Domains[]=$Row['Domain'];
	}
	
	if (is_array($Domains))
	{
		sort($Domains);
	}
	else
	{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=SubdomainID value='$SubdomainID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Subdomain']}<br>
	";
	
		if ($Edit==1)
		{
		echo "
		<input type='hidden' name='Directory' value='$Directory'>
		<input type='hidden' name='Domain' value='$Domain'>
		
		<input type='text' value='$Subdomain' readonly class=InputText>
		";
		}
		else
		{
		

			
			$RedirectUrl="http://";
			
			echo "
			<input type='Text' name='Directory' id='Directory' onkeyup=\"document.getElementById('DocumentRoot').value=document.getElementById('Directory').value;\" maxlength=100 required pattern='[a-z0-9\-]+' title='Only lowercase letters, numbers, and hyphens are allowed' class=InputText style='width:24%'>.

			<select name='Domain' id='Domain' class=Select style='width:24%'>
			";
			
			foreach ($Domains as $Domain) 
			{
				if ($Domain==$_REQUEST['Domain'])
				{
				echo "<option value='$Domain' selected>$Domain</option>";
				}
				else
				{
				echo "<option value='$Domain'>$Domain</option>";
				}
			}

			echo "	
			</select>
			";
		}
		
		echo "
		
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['DocumentRoot']}<br>
	<span style='padding-bottom:5px;border-bottom:1px solid var(--text-primary)'>/www/</span><input type='text' name='DocumentRoot' id='DocumentRoot' value='$DocumentRoot' maxlength=100 required pattern='[a-z0-9\-]+' title='Only lowercase letters, numbers, and hyphens are allowed' class=InputText style='width:45%'>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['RedirectUrlOptional']}<br>
	<input type='text' name='RedirectUrl' value='$RedirectUrl' maxlength=100 class=InputText>
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

		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='25%'>
		{$LNG['Subdomain']}
		</th>
		
		<th align='$DAlign' width='25%'>
		{$LNG['Owner']}
		</th>
		
		<th align='$DAlign' width='25%'>
		{$LNG['CreatedDate']}
		</th>

		<th align='$OAlign' width='25%'>

		</th>

 		</THEAD>
		";
		
		$Table="Subdomain";$Field="SubdomainID>=1";
		$DefaultSortBy="Subdomain";
		$DefaultDirection="ASC";
		include "include/sql.php";

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
		
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

			echo "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

			<TD><a href='http://{$Row['Subdomain']}' target='_blank'>{$Row['Subdomain']}</a></TD>

			<TD>{$Row['Username']}</TD>
			
			<TD>$CreatedDate</TD>

			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&SubdomainID={$Row['SubdomainID']}&Subdomain={$Row['Subdomain']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&Subdomain={$Row['Subdomain']}')\" class=Action>Delete</a>

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
		";
		
?>