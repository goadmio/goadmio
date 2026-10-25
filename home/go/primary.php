<?php
include "navigator.php";
$Buttons="";
include "title.php";

$AddonID=intval($_REQUEST['AddonID']);
$CheckList=$_REQUEST['CheckList'];

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


If ($Action=="Convert")
{
	$Domain=ValidateDomain($_REQUEST['Domain']);

	include "access.php";
		
	$Error=SSH ("/usr/bin/sudo /go/primary $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	Echo Error($Error);
	
	exit;
	
}


If ($Action=="BulkConvert")
{
	$CountCheckList=count($CheckList);

	for ($i=0 ;$i<$CountCheckList ; $i++)
	{
	
		$Result = SQL("select * from Site where AddonID='{$CheckList[$i]}'");
		foreach ($Result as $Row)
		{

			$Domain=$Row['Domain'];
			$Owner=$Row['Owner'];
			
			$Error=SSH ("/usr/bin/sudo /go/addon $AddonDomain $Domain AnyPassword BulkConvert",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			Echo Error($Error);
		}
	}

	$Error=SSH ("/usr/bin/sudo /go/web",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	Echo Error($Error);

}
    
	echo "
	
	<form name=CheckForm id=CheckForm action='$CurrentFileName'></form>
	<input type=hidden name=Action id=Action>
	

	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
		
    <TH align=$DAlign width='30%'>
    {$LNG['Domain']}
    </TH>

    <TH align=$DAlign width='25%'>
    {$LNG['Owner']}
    </TH>
	

    <TH align=$DAlign width='25%'>
    {$LNG['CreatedDate']}
    </TH>

    <TH align={$LNG['OAlign']} width='20%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	";
	
	

	$Table="Site";$Field="Owner!=''";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$AddonID=$Row['AddonID'];
	$Domain=$Row['Domain'];
	$Owner=$Row['Owner'];
		
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
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Domain']}'>

    <TD>
    {$Row['Domain']}
    </TD>

	<TD>
    {$Row['Owner']}
    </TD>

	<TD>
    $CreatedDate
    </TD>

	<TD align='$OAlign'>

	<a href=\"javascript:Load('$CurrentFileName?Action=Convert&Domain=$Domain&Owner=$Owner')\" class=Action>{$LNG['ConvertNow']}</a>

    </TD>
    
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

    <tr>

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=3>
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