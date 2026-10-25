<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Domain=ValidateDomain($_REQUEST['Domain']);
$Permission=ValidateUsername($_REQUEST['Permission']);



	if ($Action=="Enable")
	{
		$Result = SQL("select * from Site where Domain='$Domain'");
		foreach ($Result as $Row)
		{
		$PHPVersion=$Row['PHPVersion'];
		}

	
		SQL("UPDATE Site set FPM='1' where Domain='$Domain'");
	
		$Error=SSH ("/usr/bin/sudo /go/apache $Domain $PHPVersion",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	elseif ($Action=="Disable")
	{
		$Result = SQL("select * from Site where Domain='$Domain'");
		foreach ($Result as $Row)
		{
		$PHPVersion=$Row['PHPVersion'];
		}

		SQL("UPDATE Site set FPM='0' where Domain='$Domain'");
	
		$Error=SSH ("/usr/bin/sudo /go/apache $Domain $PHPVersion",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	elseif ($Domain!="")		
	{
		include "access.php";

		SQL("UPDATE Site SET Permission='$Permission' where Domain='$Domain'");

		$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/fix $Domain $Permission'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("File and folder permissions for $Domain has been changed [$Permission].");

	}
    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='50%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">Domain</a>
    </TH>
	
    <TH width='10%'>
	FPM
    </TH>
	
    <TH width='40%'>
	Permissions
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$Table="Site";$Field="Trash=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SiteID=$Row['SiteID'];
	$ID=$Row['SiteID'];
	
	$FPM=$Row['FPM'];
	$Domain=$Row['Domain'];
	
		
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
		
		if ($FPM==1)
		{	
		$FPMCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>
		";
		}
		else
		{
		$FPMCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>
		";
		}


    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    {$Row['Domain']}
    </td>

	<TD>
	$FPMCode
	</td>
	
	<TD>
	";
		if ($FPM==1)
		{
		

			if ($Row['Permission']=="755")
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=755')\" checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				755 Dirs / 644 Files
				</span>
			</label>
			";
			}
			else
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=755')\">
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				755 Dirs / 644 Files
				</span>
			</label>
			";
			}
		
			if ($Row['Permission']=="777")
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=777')\" checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				777
				</span>
			</label>
			";
			}
			else
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=777')\">
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				777
				</span>
			</label>
			";
			}

			if ($Row['Permission']=="555")
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=555')\" checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				555
				</span>
			</label>
			";
			}
			else
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick=\"Load('$CurrentFileName?Domain=$Domain&Permission=555')\">
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				555
				</span>
			</label>
			";
			}
		
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