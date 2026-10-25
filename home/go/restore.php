<?php
include "navigator.php";
$Buttons="";
include "title.php";

$SiteID=$_REQUEST['SiteID'];
$Restore=$_REQUEST['Restore'];
$Remove=$_REQUEST['Remove'];
$Action=$_REQUEST['Action'];
$CheckList=$_REQUEST['CheckList'];

	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";

	exit;
	}

$Domain=ValidateDomain($_REQUEST['Domain']);
$File=$_REQUEST['File'];

If ($Restore==1)
{
include "access.php";

	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/restore $File'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Restoreing $File");
	

}
	
	

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
	$Files= dir("/backup");
	While ($FileName = $Files->read())
	{
		if (EndsWith($FileName,".tar.gz"))
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

			$FileDate=date("D j M Y g:i a", filemtime("/backup/$FileName"));

			ECHO "
			<tr name=R$i id=R$i divid=Find find='$FileName-$FileDate' class='$TDColor'>

			<TD>
			$FileName
			</td>

			<TD>
			$FileDate
			</td>
			
			<TD>
			".FormatFilesize("/backup/$FileName")."
			</td>

			<TD align='right'>
			<a href=\"javascript:Load('$CurrentFileName?Restore=1&File=$FileName&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['Restore']}</a>
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