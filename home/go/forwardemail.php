<?php

include "navigator.php";
$Buttons="";
include "title.php";

			$Result = SQL("select * from Config");
			foreach ($Result as $Row)
			{
				$ForwardEmailAPIToken=$Row['ForwardEmailAPIToken'];
			}
			
echo "			
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>Forward Email API Token:<br>
<input type='text' value='$ForwardEmailAPIToken' id='ForwardEmailAPIToken' onchange=\"Config('ForwardEmailAPIToken',encodeURI(document.getElementById('ForwardEmailAPIToken').value))\" class=InputText> <a href='https://forwardemail.net/en/my-account/security' target='_blank'>API Token</a>
</div>

</form>
";

?>