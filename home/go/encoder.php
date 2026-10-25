<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Password']!="")
{
$Domain=ValidateUsername($_REQUEST['Domain']);
$Type=ValidateUsername($_REQUEST['Type']);
$Password=ValidatePassword($_REQUEST['Password']);

include "access.php";


	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/encoder $Domain $Password'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Website $Domain Successfully Encrypted.");
	
	$_SESSION['SessionPassword']=md5($Password);

}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>
	Website
	<br>
	";

		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Account['Domain'][]=$Row['Domain'];
		$Account['Username'][]=$Row['Username'];
		}
		
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);

		echo "<select name='Domain' id='Domain' class=Select>";
		
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			echo "<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]}</option>";
			}
			else
			{
			echo "<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]}</option>";
			}
		}

		echo "</select>";
		
		
	echo "
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['EncryptionKey']}
	<br>
	<input type='text' name='Password' id='Password' pattern='^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$' title='Must contain at least one number, one uppercase letter, one lowercase letter, and be at least 8 characters long' autocomplete='new-password' required maxlength=100 class=InputText>
	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['EnctreptPHPCode']}' Class=InputButton>
	</div>

	
</form>

	";


?>