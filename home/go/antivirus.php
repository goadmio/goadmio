<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

	Echo "
	<div class='NavigatorInfo'>
	<span class=Tab>{$LNG['ClamAVTitle']}</span>
	</div>
	";




	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type='hidden' name='MemberID' value='$MemberID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	";
	
		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
		
		sort($Domains);
		
		echo "
		<select name='Domain' id='Domain' class=Select>
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
	
	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['Scan']}' Class=InputButton>
	</div>

	<div id=DivScan class=NavigatorInfo></div>


</form>


	";
	

?>