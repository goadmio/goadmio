<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$MTime=intval($_REQUEST['MTime']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$Action=$_REQUEST['Action'];

if ($Action=="Purge" and $Domain!="")
{
	include "access.php";

	if ($MTime==1)
	{
		SSH ("/usr/bin/sudo screen -d -m bash -c 'find /var/cache/$Domain -type f -mtime 0 -delete'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Purge last 24 hours cache in progress ($Domain). This operation is running in the background.");
	}
	elseif ($MTime==7)
	{
		SSH ("/usr/bin/sudo screen -d -m bash -c 'find /var/cache/$Domain -type f -mtime -7 -delete'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Purge last 7 days cache in progress ($Domain). This operation is running in the background.");
	}
	else
	{
		SSH ("/usr/bin/sudo screen -d -m bash -c 'find /var/cache/$Domain -type f -delete'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Purge all cache in progress ($Domain). This operation is running in the background.");
	}
	

}



	$Date=date ("Y-m-d",mktime (date("G"),date("i")+$GMT,date("s"),date("m"),date("d"),date("Y")));
    
	include "search.php";
	
	Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=CacheTTL')\">Cache TTL</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=CacheLength')\">Length</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=CacheExclude')\">URL Exclude</a>
    </TH>

    <TH align='$DAlign' width='10%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=CacheActive')\">Active</a>
    </TH>
	
    <TH align='$DAlign' width='10%'>
    Purge Cache
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
		$ID=$Row['SiteID'];
		
		$SiteID=$Row['SiteID'];
		$Domain=$Row['Domain'];

		$CacheTTL=$Row['CacheTTL'];
		$CacheLength=$Row['CacheLength'];
		$CacheExclude=$Row['CacheExclude'];
		
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
	
		if ($Row['CacheActive']==1)
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('CacheActive','$SiteID',encodeURI(document.getElementById('CacheActive{$SiteID}').checked),'CacheActive{$SiteID}')\">
		<input type='checkbox' id='CacheActive{$SiteID}' value='1' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$ActiveCode="
		<label class='CheckboxToggle' onclick=\"Setting('CacheActive','$SiteID',encodeURI(document.getElementById('CacheActive{$SiteID}').checked),'CacheActive{$SiteID}')\">
		<input type='checkbox' id='CacheActive{$SiteID}' value='1'>
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
	<input type='text' id='CacheTTL{$SiteID}' value='$CacheTTL' onchange=\"Setting('CacheTTL','$SiteID',encodeURI(document.getElementById('CacheTTL{$SiteID}').value),'CacheTTL{$SiteID}')\" class=InputZ>
    </td>
	
	<TD> 
	<input type='text' id='CacheLength{$SiteID}' value='$CacheLength' onchange=\"Setting('CacheLength','$SiteID',encodeURI(document.getElementById('CacheLength{$SiteID}').value),'CacheLength{$SiteID}')\" class=InputZ>
    </td>

	<TD>
	<input type='text' id='CacheExclude{$SiteID}' value='$CacheExclude' onchange=\"Setting('CacheExclude','$SiteID',encodeURI(document.getElementById('CacheExclude{$SiteID}').value),'CacheExclude{$SiteID}')\" class=InputZ>
    </td>
	
	<TD>
	$ActiveCode
    </td>

	<TD>
	";

echo <<<HTML
<div class='DropdownButton'>
    <button type="button" onclick="DropdownButton('Purge{$ID}', event)" class='DropButton'>Purge Cache</button>
    <div id='Purge{$ID}' class='DropdownButtonContent'>
        <a href="javascript:Load('{$CurrentFileName}?Action=Purge&SiteID={$SiteID}&Domain={$Domain}&MTime=1&SortBy={$SortBy}&Page={$Page}')">Last 24 hours</a>
        <a href="javascript:Load('{$CurrentFileName}?Action=Purge&SiteID={$SiteID}&Domain={$Domain}&MTime=7&SortBy={$SortBy}&Page={$Page}')">Last 7 days</a>
        <a href="javascript:Load('{$CurrentFileName}?Action=Purge&SiteID={$SiteID}&Domain={$Domain}&MTime=0&SortBy={$SortBy}&Page={$Page}')">All</a>
    </div>
</div>
HTML;

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

	<th align='$DAlign' colspan=3>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=3>
	";
			
	include "pages.php";

	echo "
	</th>

	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
		
?>