<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);



if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	if ($_SESSION['SessionResellerUsername']=="")
	{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";

	exit;
	}
}



if ($Action!="")
{
include "access.php";


	$Error=SSH ("/usr/bin/sudo /go/permission $Domain $Action",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
}



    
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
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=FTPStatus')\">{$LNG['Status']}</a>
    </TH>
	
    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=FTPUpload')\">{$LNG['Upload']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=FTPDownload')\">{$LNG['Download']}</a>
    </TH>

    <TH align='$DAlign' width='20%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=FTPDelete')\">{$LNG['Delete']}</a>
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
	
	$Domain=$Row['Domain'];
	
	$FTPStatus=$Row['FTPStatus'];
	$FTPUpload=$Row['FTPUpload'];
	$FTPDownload=$Row['FTPDownload'];
	$FTPDelete=$Row['FTPDelete'];
		
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


		if ($FTPStatus==1)
		{
		$FTPStatusCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableFTP&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$FTPStatusCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableFTP&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
		}
		
		if ($FTPUpload==1)
		{
		$FTPUploadCode= "
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableUpload&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$FTPUploadCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableUpload&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
		}


		if ($FTPDownload==1)
		{
		$FTPDownloadCode= "
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableDownload&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$FTPDownloadCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableDownload&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
		}


		if ($FTPDelete==1)
		{
		$FTPDeleteCode= "
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=DisableDelete&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>	
		";
		}
		else
		{
		$FTPDeleteCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=EnableDelete&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>	
		";
		}



    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    <a href=\"#\">{$Row['Domain']}</a>
    </td>

	<TD>
    $FTPStatusCode
    </td>
	
	<TD>
    $FTPUploadCode
    </td>
	
	<TD>
    $FTPDownloadCode
    </td>
	
	<TD>
    $FTPDeleteCode
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