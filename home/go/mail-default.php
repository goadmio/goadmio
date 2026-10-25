<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";
	
Echo "
<div class=NavigatorInfo>
<img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>Catch any email that is sent to an invalid email address for your domain.
</div>
";

if ($_REQUEST['Domain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Email=ValidateEmail($_REQUEST['Email']);

include "access.php";


	if ($Email=="" AND $Domain!="")
	{
	// Discard the email
	$Email="-";
	
	$Error=SSH ("/usr/bin/sudo /go/mail $Email - $Domain default",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	}
	elseif ($Email!="" AND $Domain!="")
	{
	$Error=SSH ("/usr/bin/sudo /go/mail $Email - $Domain default",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	}
	
}


	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	";
	
	if (stristr($_SESSION['SessionDomain'],"."))
	{

		$Result = SQL("select Email from Mail where DefaultAddress=1 and Domain='{$_SESSION['SessionDomain']}'");
		foreach ($Result as $Row)
		{
		$Email=$Row['Email'];
		}
		

		
	}
	else
	{
		if (filter_var($Domain,FILTER_VALIDATE_IP)) 
		{
			$IPValidate=1;
		}
		else
		{

			$Result = SQL("select Email from Mail where DefaultAddress=1 and Domain='$Domain'");
			foreach ($Result as $Row)
			{
			$Email=$Row['Email'];
			}

		}		
	}
	
	echo "
	<div <div class='TitleB {$Dir}TitleB'>
	
	Send all unrouted email for the following domain:	
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>

	";


		$Result = SQL("select Domain from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
				
		if (is_array($Domains))
		{
			
			sort($Domains);
			
			echo "
			<select name='Domain' id='Domain' onchange='DefaultEmail()' class=Select>
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

			echo "</select>";
			
		}
		else
		{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
		}
		
	echo "
	</div>


	<div class='DivInput {$Dir}DivInput'>{$LNG['ForwardToEmailAddress']}<br>
	<input type='text' name='Email' id='Email' value='$Email' class=InputText maxlength=100>
	</div>

	<Div id=DivSubmit Class=DivSubmit>
	<input type=submit value='{$LNG['Save']}' Class=InputButton>
	</div>

	

</form>

";

?>