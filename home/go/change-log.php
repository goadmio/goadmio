<?php
include "navigator.php";
$Buttons="
<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['Refresh']}</a>
<a href='$CurrentFileName?Action=Export&Service=$Service&ControlID=$ControlID&CTabNo=$CTabNo' target='_blank' class='ButtonB {$Dir}ButtonB'>{$LNG['ExportExcel']}</a>
";
include "title.php";


	$DisableSearch=1;
	include "search.php";

	Echo "
	
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th width=80% align='$DAlign' nowrap>
		{$LNG['Update']}
		</th>

		<th width=20% align='$DAlign' nowrap>
		{$LNG['Date']}
		</th>
		
		</THEAD>
		
		";


		$Lines = file("/go/change-log.txt");


		foreach ($Lines as $X => $Line)
		{
		
			$LogArray=explode("|",$Line);
		
			if ($X%2==0)
			{
			$TDColor="TdB";
			}
			else
			{
			$TDColor="Td";
			}
			
			//if (stristr($Row['Status'],"failed"))
			//{
			//$TDColor="TdEr";
			//}
			//elseif (stristr($Row['Status'],"exited"))
			//{
			//$TDColor="TdInfo";
			//}
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$LogArray[0]}-{$LogArray[1]}' class='$TDColor'>

			<TD>{$LogArray[0]}</TD>
			<TD>{$LogArray[1]}</TD>

			</TD>
			";
			
		
		}
		
		echo "
	
		</TABLE>
		
		</div>
		";
		
	
	
?>