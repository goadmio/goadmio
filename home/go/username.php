<?php

include "navigator.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Username']!="" and $_REQUEST['Domain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
include "access.php";
$Username=ValidateUsername($_REQUEST['Username']);

	$Error=SSH ("/usr/bin/sudo /go/username $Domain $Username",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
}

	$Result = SQL("SELECT * FROM Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
	$Account['Domain'][]=$Row['Domain'];
	$Account['Username'][]=$Row['Username'];
	}
	
	if (is_array($Account['Domain']))
	{
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);

		Echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

		<div class='DivInput {$Dir}DivInput'>
		Website
		<br>
		";

		echo "<select name='Domain' id='Domain' onchange='GetUsername()' class=Select>";
		
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			echo "<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]} ({$Account['Username'][$E]})</option>";
			}
			else
			{
			echo "<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]} ({$Account['Username'][$E]})</option>";
			}
		}

		echo "</select>";
			
			
		echo "
		</div>


		<div class='DivInput {$Dir}DivInput'>
		{$LNG['Username']}
		<br>
		<input type='text' name='Username' id='Username' pattern='^[a-z0-9_][a-z0-9_.-]*[$]?$' required maxlength=32 class=InputText>
		</div>


		<div id=DivSubmit class=DivSubmit>
		<input type=submit value='{$LNG['ChangeUsername']}' Class=InputButton>
		</div>

		
		</form>

		";
		
	}
	else
	{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}


?>