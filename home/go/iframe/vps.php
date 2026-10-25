<?php
session_start();

include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

include "../language/en.php";
if ($_COOKIE['CookiesLng']!="en")
{
include "../language/{$_COOKIE['CookiesLng']}.php";
}

$VPSID=intval($_REQUEST['VPSID']);
$IP=trim($_REQUEST['IP']);
$File=trim($_REQUEST['File']);

echo "
<!DOCTYPE html>

<head>
<link href=\"../theme/{$_SESSION['SessionTheme']}/css/en.css?$JSVersion\" type=\"text/css\" rel=\"stylesheet\">

<script>

	function Save()
	{
		document.getElementById('Submit').disabled=true;
		document.getElementById('Form').submit();
	}

</script>

</head>
";


if ($_SESSION['SessionSSHUsername']!="root" and $_SESSION['SessionSSHUsername']!=$SSHUsername)
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

	if ($File!="")
	{
		SQL("UPDATE VPS set File='$File'");
		echo Error ("Reload OS $File.");
		
		$Password=RandomPassword(16);
		
		$Error=SSH ("sudo screen -d -m bash -c '/go/vps reinstall $IP $Password'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		echo Error("Password: $Password");
		
		exit;
	}

$Sql = "select * from VPS where VPSID='$VPSID'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{ 
	$CustomerID=$Row['CustomerID'];
	$IP=$Row['IP'];
	$File=$Row['File'];
}


$Sql = "select * from Customer where CustomerID='$CustomerID'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{ 
	$Email=$Row['Email'];
}


if (stristr("|ar|fa|ps|sd|ug|ur|yi|","|{$_SESSION['SessionLng']}|"))
{
echo "<html dir=rtl>";
$DAlign="right";
$OAlign="left";

$Dir="RTL";

echo "
<link href=\"../css/rtl.css?$JSVersion\" type=\"text/css\" rel=\"stylesheet\">
";

}
else
{
echo "<html>";
$DAlign="left";
$OAlign="right";

$Dir="LTR";
}

	$Result = SQL("SELECT * FROM Distro where DistroID>=1");
	foreach ($Result as $Row)
	{
	$OS['Name'][]=$Row['Name'];
	$OS['File'][]=$Row['File'];
	}



echo "


<body>

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type='hidden' name='VPSID' value='$VPSID'>

	<div class='DivInput {$Dir}DivInput'>{$LNG['CustomerID']}<br>
	<input type='text' name='CustomerID' value='$CustomerID' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	<input type='text' name='Email' value='$Email' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['ContainerIP']}<br>
	<input type='text' name='IP' value='$IP' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['OS']}
	<br>
	";

	echo "<select name='File' id='File' class=Select>";
	echo "<option value='' selected>Select OS</option>";
	
	for ($E=0;$E<count($OS['File']);$E++)
	{
		if ($OS['File'][$E]==$File)
		{
		echo "<option value='{$OS['File'][$E]}' selected>{$OS['Name'][$E]}</option>";
		}
		else
		{
		echo "<option value='{$OS['File'][$E]}'>{$OS['Name'][$E]}</option>";
		}
	}

	echo "

	</select>
		
	</div>

	
	<div id=DivSubmit class=DivSubmit>
	
		<input type='submit' id='Submit' value='Reinstall OS' Class=InputButton>
	
	</div>

	</form>

</body>

</html>

";
	
?>