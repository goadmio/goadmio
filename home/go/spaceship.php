<?php

include "navigator.php";
$Buttons="";
include "title.php";


$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
$SpaceshipAPIKey=$Row['SpaceshipAPIKey'];
$SpaceshipAPISecret=$Row['SpaceshipAPISecret'];		
}

echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>API Key<br>
<input type='text' value='$SpaceshipAPIKey' id='SpaceshipAPIKey' onchange=\"Config('SpaceshipAPIKey',encodeURI(document.getElementById('SpaceshipAPIKey').value),'SpaceshipAPIKey')\" class=InputText> <a href='https://www.spaceship.com/application/api-manager/'>API Key</a>
</div>

<div class='DivInput {$Dir}DivInput'>API Secret<br>
<input type='text' value='$SpaceshipAPISecret' id='SpaceshipAPISecret' onchange=\"Config('SpaceshipAPISecret',encodeURI(document.getElementById('SpaceshipAPISecret').value),'SpaceshipAPISecret')\" class=InputText>
</div>

</form>
";

?>