<?php
session_start();

include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

include "../language/en.php";
if ($_COOKIE['CookiesLng']!="en")
{
include "../language/{$_COOKIE['CookiesLng']}.php";
}

$SubnetIP=trim($_REQUEST['SubnetIP']);
$CIDR=trim($_REQUEST['CIDR']);
$ServerIP=trim($_REQUEST['ServerIP']);

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

	if ($SubnetIP!="" and $CIDR!="" and $ServerIP!="")
	{
		echo Subnet($SubnetIP,$CIDR,$ServerIP);
		exit;
	}


$Sql = "select * from Server where ServerIP='$ServerIP'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{ 
	$ServerName=$Row['ServerName'];
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




echo "


<body>

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>Server Name<br>
	<input type='text' name='ServerName' value='$ServerName' readonly class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Server IP<br>
	<input type='text' name='ServerIP' value='$ServerIP' readonly maxlength=15 style='width:150px' class=InputText>
	</div>
	

	<div class='DivInput {$Dir}DivInput'>Subnet IP<br>
	<input type='text' name='SubnetIP' value='$SubnetIP' maxlength=15 style='width:150px' class=InputText> / <input type='text' name='CIDR' value='$CIDR' maxlength=2 placeholder='CIDR' style='width:50px' class=InputText>
	</div>
	
	<div id=DivSubmit class=DivSubmit>
	
		<input type='submit' id='Submit' value='Add VPS(s)' Class=InputButton>
	
	</div>

	</form>

</body>

</html>

";
	
?>