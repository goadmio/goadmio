<?php

include "navigator.php";
$Buttons="";
include "title.php";

$ScriptID=$_REQUEST['ScriptID'];



if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}



	$FilterSql = str_replace("|Apostrophe|", "'", $FilterSql);
	$FilterSql = str_replace("|Space|", " ", $FilterSql);

	$SearchFor = str_replace("|Apostrophe|", "'", $SearchFor);
	$SearchFor = str_replace("|Space|", " ", $SearchFor);


	include "search.php";

	Echo "	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align=$DAlign width='30%' height=40>
	<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID&SortBy=ScriptName')\">{$LNG['ScriptName']}</a>
    </TH>
	

    <TH align=$DAlign width='20%'>
    <a href='$CurrentFileName?Service=$Service&ControlID=$ControlID&ServiceControl=$ServiceControl&SortBy=Category'>{$LNG['Category']}</a>
    </TH>
	
    <TH align=$DAlign width='20%'>
    <a href='$CurrentFileName?Service=$Service&ControlID=$ControlID&ServiceControl=$ServiceControl&SortBy=ScriptVersion'>{$LNG['Version']}</a>
    </TH>


    <TH align=$DAlign width='20%'>
    <a href='$CurrentFileName?Service=$Service&ControlID=$ControlID&ServiceControl=$ServiceControl&SortBy=ScriptLanguage'>{$LNG['Language']}</a>
    </TH>
	

    <TH align=$DAlign width='10%'>
	
    </TH>

	</tr>
	
	</THEAD>
	";

	$Table="Script";$Field="ScriptID>=1";
	$DefaultSortBy="ScriptName";
	$DefaultDirection="ASC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$ScriptID=$Row['ScriptID'];
		
		$ScriptControlID=-1;
		$ResultQ = SQL("SELECT ControlID from Control where ControlUrl like '%&ScriptFile={$Row['ScriptFile']}'");
		foreach ($ResultQ as $RowQ)
		{
		$ScriptControlID=$RowQ['ControlID'];
		}

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

		if ($Row['Suspend']==1)
		{
		$TDColor="TdEr";
		}
		
		if ($Row['Trash']==1)
		{
		$TDColor="TdInfo";
		}
		
		$NavigatorTitle=urlencode($Row['ScriptName']);

    ECHO "
	
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['ScriptName']}-{$Row['ScriptFile']}'>
	";

    Echo "
	<TD title='Created Date: $CreatedDate'>
	<a href=\"javascript:Load('script.php?ScriptFile={$Row['ScriptFile']}&ControlID=$ScriptControlID&NavigatorTitle=$NavigatorTitle&ScriptID=$ScriptID')\">{$Row['ScriptName']}</a>
    </td>
	
	<TD>
    {$Row['Category']}
    </td>
	

	<TD>
    {$Row['ScriptVersion']}
    </td>
	
	<TD>
	{$Row['ScriptLanguage']}
    </td>

	<TD>
	<a  href=\"javascript:Load('script.php?ScriptFile={$Row['ScriptFile']}&ControlID=$ScriptControlID&NavigatorTitle=$NavigatorTitle&ScriptID=$ScriptID')\" class=Action>{$LNG['Install']}</a>
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

   <tr>

	<th align='$DAlign' colspan=9>
	Showing $X of $RowsNo records.
	</th>


	</tr>

	</TFOOT>


	
   </TABLE>
   </div>
  
	
	";

	include "pages.php";

?>