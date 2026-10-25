<?php
include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$AuthUser=$_REQUEST['AuthUser'];
$AuthSecret=$_REQUEST['AuthSecret'];
$Code=$_REQUEST['Code'];

require "vendor/autoload.php";
use Sonata\GoogleAuthenticator\GoogleAuthenticator;
use Sonata\GoogleAuthenticator\GoogleQrUrl;
$ga = new GoogleAuthenticator();

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);

if ($Code=="Delete")
{
		echo Error("Two-Factor Authentication has been Disabled.");
		SQL("DELETE from Auth where AuthUser='$AuthUser'");
        SSH ("/usr/bin/sudo /go/ssh",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		
}
elseif ($AuthUser!="" and $AuthSecret!="" and $Code!="")
{

	$ga = new GoogleAuthenticator();

	if ($ga->checkCode($AuthSecret, $Code))
	{
		echo Error("Verification Successful.");
		SQL("DELETE from Auth where AuthUser='$AuthUser'");
		SQL("INSERT INTO Auth (AuthUser,AuthSecret) VALUES ('$AuthUser','$AuthSecret')");
		
		$ClientIP=ClientIP();
		SSH ("/usr/bin/sudo /go/ssh $ClientIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	} 
	else 
	{
		echo Error("Invalid code. Please try again.");
	}

}


	if ($_SESSION['SessionType'] == "Root")
	{
	$AuthUser="root";
	}
	else
	{
	$AuthUser=$_SESSION['SessionUsername'];
	}

	$AuthEnable=0;
	$Sql = "select * from Auth where AuthUser='$AuthUser'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$AuthEnable=1;
	$AuthUser=$Row['AuthUser'];
	}


	if ($AuthEnable==0)
	{
		if (!isset($_SESSION['SessionAuthSecret']))
		{
		$_SESSION['SessionAuthSecret']=$ga->generateSecret();
		}
	
		$qrCodeUrl = GoogleQrUrl::generate("GoAdmio ($Domain | $AuthUser)",$_SESSION['SessionAuthSecret']);
		
		echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
				
		<div class='DivInput {$Dir}DivInput'>
		Scan this QR code with Google Authenticator
		<br>
		<img src='{$qrCodeUrl}'>
		<input type='hidden' name=AuthUser id=AuthUser value='$AuthUser'>
		<input type='hidden' name=AuthSecret id=AuthSecret value='{$_SESSION['SessionAuthSecret']}'>

		</div>

		<div class='DivInput {$Dir}DivInput'>
		{$LNG['Code']}
		<br>
		<input type='Code' name='Code' id='Code' pattern='\d{6}' required title='Please enter exactly 6 digits' class=InputText>
		</div>

		<div id=DivSubmit class=DivSubmit>
		<input type=submit value='Enable 2FA' Class=InputButton>
		</div>

		</form>
		";
	}
	else
	{
		echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
		<input type='hidden' name='AuthUser' id='AuthUser' value='$AuthUser'>
		<input type='hidden' name='AuthSecret' id='AuthSecret' value='Delete'>
		<input type='hidden' name='Code' id='Code' value='Delete'>
		
	
		<div id=DivSubmit class=DivSubmit>
		<input type=submit value='Disable 2FA' Class=InputButton>
		</div>

		</form>
		";	
		
	
	}

?>