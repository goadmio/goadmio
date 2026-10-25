<?php
session_start();

include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

include "../language/en.php";
if ($_COOKIE['CookiesLng']!="en")
{
include "../language/{$_COOKIE['CookiesLng']}.php";
}


$CustomerID=intval($_REQUEST['CustomerID']);
$Amount=trim($_REQUEST['Amount']);

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



	if ($Amount>-1000 and $Amount!=0)
	{
		if ($Amount>0)
		{
		$Service="Add Funds";
		}
		else
		{
		$Service="Refubd";
		}
		
		$Subject="Admin Area";
		$Success=Invoice ($CustomerID,$Service,$Amount,$Subject);
	
		if ($Success==1)
		{
		echo Error ("Balance $Amount added successfully.");
		}
		else
		{
		echo Error ("Failed.");
		}
		
		exit;
	}


$Sql = "select * from Customer where CustomerID='$CustomerID'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{ 
	$CustomerID=$Row['CustomerID'];
	$Email=$Row['Email'];
	$Balance=$Row['Balance'];
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

	<div class='DivInput {$Dir}DivInput'>{$LNG['CustomerID']}<br>
	<input type='text' name='CustomerID' value='$CustomerID' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	<input type='text' name='Email' value='$Email' readonly maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['CurrentBalance']}<br>
	<input type='text' name='Current' value='$Balance' readonly maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['Amount']}<br>
	<input type='number' name='Amount' value='$Amount' step='0.01' min='-1000' max='1000' class=InputText>
 	</div>
	
	<div id=DivSubmit class=DivSubmit>
	
		<input type='submit' id='Submit' value='{$LNG['AddFunds']}' Class=InputButton>
	
	</div>

	</form>

</body>

</html>

";
	
?>