<?php

include "navigator.php";
$Buttons="";
include "title.php";

$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
$CloudflareAccountID=$Row['CloudflareAccountID'];
$CloudflareAPIToken=$Row['CloudflareAPIToken'];		
}

echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>Account ID<br>
<input type='text' value='$CloudflareAccountID' id='CloudflareAccountID' onchange=\"Config('CloudflareAccountID',encodeURI(document.getElementById('CloudflareAccountID').value),'CloudflareAccountID')\" class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>API Token<br>
<input type='text' value='$CloudflareAPIToken' id='CloudflareAPIToken' onchange=\"Config('CloudflareAPIToken',encodeURI(document.getElementById('CloudflareAPIToken').value),'CloudflareAPIToken')\" class=InputText> <a href='https://dash.cloudflare.com/profile/api-tokens'>API Token</a>
</div>

</form>
";


?>