<?php

include "navigator.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Domain']!="" and $_REQUEST['NewDomain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$NewDomain=ValidateDomain($_REQUEST['NewDomain']);
include "access.php";

	$ProgressFile="$Domain.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/domain $Domain $NewDomain --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Changing primary domain from $Domain to $NewDomain in the background. You can close this page.");
	echo Progress("Changing primary domain from $Domain to $NewDomain",$ProgressFile);
	
	exit;
	
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

		echo "
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
		New Primary Domain
		<br>
		<input type='text' name='NewDomain' id='NewDomain' pattern='^[a-z0-9][a-z0-9-]*(\.[a-z0-9][a-z0-9-]*)+$' required maxlength='253' class='InputText' placeholder='example.com'>
		</div>


		<div id=DivSubmit class=DivSubmit>
		<input type=submit value='Change Primary Domain' Class=InputButton>
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