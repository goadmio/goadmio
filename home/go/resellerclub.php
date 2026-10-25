<?php

include "navigator.php";
$Buttons="";
include "title.php";


		$Result = SQL("select * from Config where ConfigID=1");
		foreach ($Result as $Row)
		{
		$ResellerclubIP=$Row['ResellerclubIP'];
		$ResellerclubUserID=$Row['ResellerclubUserID'];
		$ResellerclubAPIKey=$Row['ResellerclubAPIKey'];
		}


		echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

		<div class='DivInput {$Dir}DivInput'>Whitelist IP<br>
		
		<input type='text' value='$ResellerclubIP' id='ResellerclubIP' onchange=\"Config('ResellerclubIP',encodeURI(document.getElementById('ResellerclubIP').value))\" class=InputText>
		
		</div>
	

		<div class='DivInput {$Dir}DivInput'>User ID<br>
		<input type='text' value='$ResellerclubUserID' id='ResellerclubUserID' onchange=\"Config('ResellerclubUserID',encodeURI(document.getElementById('ResellerclubUserID').value))\" class=InputText>
		</div>

		<div class='DivInput {$Dir}DivInput'>API Key<br>
		<input type='text' value='$ResellerclubAPIKey' id='ResellerclubAPIKey' onchange=\"Config('ResellerclubAPIKey',encodeURI(document.getElementById('ResellerclubAPIKey').value))\" class=InputText>
		</div>

		</form>

";


?>