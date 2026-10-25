<?php
include "navigator.php";
$Buttons="<a href=\"javascript:Load('history.php','0')\" class='ButtonB {$Dir}ButtonB'>Refresh</a>";
include "title.php";

$SiteID=$_REQUEST['SiteID'];
$Restore=$_REQUEST['Restore'];
$Remove=$_REQUEST['Remove'];
$Action=$_REQUEST['Action'];
$CheckList=$_REQUEST['CheckList'];


	$DisableSearch=1;
	include "search.php";

	
    Echo "
	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>

	
    <TH align='$DAlign' width='40%'>
    File
    </TH>

    <TH align='$DAlign' width='25%'>
    Date Modified
    </TH>

    <TH align='$DAlign' width='20%'>
    Size
    </TH>

    <TH width='15%'>

    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	$SortDir="ASC";

    if ($SortBy=="")
    {
    $SortBy="Domain";
    }

    if ($Page=="")
    {
    $Page=1;
    }


	$X=0;
	$Files= dir("/usr/local/goadmio/backup");
	While ($FileName = $Files->read())
	{
	
		if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
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

			$FileDate=date("D j M Y g:i a", filemtime("/usr/local/goadmio/backup/$FileName"));

			ECHO "
			<tr name=R$i id=R$i divid=Find find='$FileName-$FileDate' class='$TDColor'>

			<TD>
			$FileName
			</td>

			<TD>
			$FileDate
			</td>
			
			<TD>
			".FormatFilesize("/usr/local/goadmio/backup/$FileName")."
			</td>

			<TD align='right'>
			<a href=\"http://$IPv4/backup/$FileName\" class=Action>Download</a>
			</td>
			
			</tr>
			
			";
			
			$X++;
		
		}
		elseif (stristr($FileName,"-{$_SESSION['SessionUsername']}-"))
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

			$FileDate=date("D j M Y g:i a", filemtime("/usr/local/goadmio/backup/$FileName"));

			ECHO "
			<tr name=R$i id=R$i divid=Find find='$FileName-$FileDate' class='$TDColor'>

			<TD>
			$FileName
			</td>

			<TD>
			$FileDate
			</td>
			
			<TD>
			".FormatFilesize("/usr/local/goadmio/backup/$FileName")."
			</td>

			<TD align='right'>
			<a href=\"http://{$_SESSION['SessionUsername']}/panel-backup/$FileName\" class=Action>Download</a>
			</td>
			
			</tr>
			
			";
			
			$X++;
		}
	}
	
	
	if ($X!=0)
	{
	echo "</TBODY>";
	}

	echo "
	<TFOOT>

    <tr>

    <th align='$DAlign' colspan=5>
    Files : $i
    </th>
	
    </tr>

	</TFOOT>
	</TABLE>
	</div>
	</form>

	";


?>