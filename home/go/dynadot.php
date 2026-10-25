<?php

include "navigator.php";
$Buttons="";
include "title.php";


		$Result = SQL("select * from Config where ConfigID=1");
		foreach ($Result as $Row)
		{
		$DynadotIP=$Row['DynadotIP'];
		$DynadotAPIKey=$Row['DynadotAPIKey'];
		}

		echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

		<div class='DivInput {$Dir}DivInput'>Whitelist IP<br>
		
		<input type='text' value='$DynadotIP' id='DynadotIP' onchange=\"Config('DynadotIP',encodeURI(document.getElementById('DynadotIP').value))\" class=InputText>
		
		</div>
	
		<div class='DivInput {$Dir}DivInput'>API Key<br>
		<input type='text' value='$DynadotAPIKey' id='DynadotAPIKey' onchange=\"Config('DynadotAPIKey',encodeURI(document.getElementById('DynadotAPIKey').value))\" class=InputText>
		</div>

		</form>

";

?>