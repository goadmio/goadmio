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
$CustomerID=intval($_REQUEST['CustomerID']);
$Price=trim($_REQUEST['Price']);
$IP=trim($_REQUEST['IP']);
$PlanName=trim($_REQUEST['PlanName']);
$ExpiresOn=trim($_REQUEST['ExpiresOn']);

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

	if ($CustomerID>=1 and $VPSID>=1)
	{
		// Create Invoice and Charge Amount from Customer
		$Amount=$Price*-1;
		$Success=Invoice ($CustomerID,"$PlanName ($IP)",$Amount,"Entry for 1 month");
	
		if ($Success==1)
		{
		$ExpiresOn = date("Y-m-d", strtotime("+1 month",strtotime("$ExpiresOn")));
		
		SQL("UPDATE VPS set ExpiresOn='$ExpiresOn' where VPSID='$VPSID'");
		
		echo Error ("$IP renew down ($ExpiresOn), Customer ID: $CustomerID");
		}
		else
		{
		echo Error("Sorry, Balance is not enough.");
		}
		
		exit;
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



	$Result = SQL("SELECT * FROM VPS where VPSID='$VPSID'");
	foreach ($Result as $Row)
	{
	$ExpiresOn=$Row['ExpiresOn'];
	$CustomerID=$Row['CustomerID'];
	$IP=$Row['IP'];
	$PlanName=$Row['PlanName'];
	$Price=$Row['Price'];
	}
	
	

echo "


<body>

	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type='hidden' name='VPSID' value='$VPSID' readonly class=InputText>
	<input type='hidden' name='CustomerID' value='$CustomerID' readonly class=InputText>
	<input type='hidden' name='ExpiresOn' value='$ExpiresOn' readonly class=InputText>

	<div class='DivInput {$Dir}DivInput'>{$LNG['ContainerIP']}<br>
	<input type='test' name='IP' value='$IP' readonly class=InputText>
	</div>
		
	<div class='DivInput {$Dir}DivInput'>{$LNG['PlanName']}<br>
	<input type='test' name='PlanName' value='$PlanName' readonly class=InputText>
	</div>
		
	<div class='DivInput {$Dir}DivInput'>{$LNG['Price']}<br>
	<input type='number' name='Price' value='$Price' min=1 max=10000 step='.01' class=InputText>
	</div>
		
	<div id=DivSubmit class=DivSubmit>
		<input type='submit' id='Submit' value='Renew Now' Class=InputButton>
	</div>

	</form>

</body>

</html>

";
	
?>