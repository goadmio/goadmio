<?php



include "navigator.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Password']!="")
{
$Domain=ValidateUsername($_REQUEST['Domain']);
$Password=ValidatePassword($_REQUEST['Password']);
	
include "access.php";

	if (file_exists("/home/$Domain/www/wp-config.php"))
	{
	
		function wp_hash_password($password)
		{
			global $wp_hasher,$Domain;

			if (empty($wp_hasher)) 
			{
			require_once "/home/$Domain/www/wp-includes/class-phpass.php";
			
			$wp_hasher = new PasswordHash( 8, true );
			}

			return $wp_hasher->HashPassword( trim( $password ) );

		}

		$Password=wp_hash_password($Password);
		$Password=str_replace('$','[DollarSign]',$Password);

		
	$Error=SSH ("/usr/bin/sudo /go/wordpress-password $Domain $Password",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	}
	else
	{
	echo Error("WordPress not installed.");
	}

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
		

		<select name='Domain' id='Domain' class=Select>
		";
		
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

		echo "
		</select>
			

		</div>


		<div class='DivInput {$Dir}DivInput'>
		{$LNG['NewPassword']}
		<br>
		<input type='password' name='Password' id='Password' pattern='^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$' title='Must contain at least one number, one uppercase letter, one lowercase letter, and be at least 8 characters long' autocomplete='new-password' required maxlength=100 class=InputText>  <span onclick=\"GeneratePassword('Password')\" style='cursor:pointer'>Generate Password</span>
		</div>

		
		<div class='DivInput {$Dir}DivInput'>
		{$LNG['VerifyNewPassword']}
		<br>
		<input type='password' name='VerifyPassword' id='VerifyPassword' class=InputText maxlength=100>
		</div>

		<div id=DivSubmit class=DivSubmit>
		<input type=submit value='{$LNG['ChangePassword']}' Class=InputButton>
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