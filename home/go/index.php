<?php
session_start();

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);
// error_reporting(-1);

$UserID=$_REQUEST['UserID'];$Open=$_REQUEST['Open'];$HTMLFileName=$_REQUEST['HTMLFileName'];
$Username=$_REQUEST['Username'];$OperatorImage=$_REQUEST['OperatorImage'];$Admin=$_REQUEST['Admin'];$DisableWelcomeMsg=$_REQUEST['DisableWelcomeMsg'];$DeleteCookiesPassword=$_REQUEST['DeleteCookiesPassword'];$Logout=$_REQUEST['Logout'];$Action=$_REQUEST['Action'];
$CookiesLoginOption=$_REQUEST['CookiesLoginOption'];$MainPage=$_REQUEST['MainPage'];$Ext=$_REQUEST['Ext'];
$FrameTop=$_REQUEST['FrameTop'];$FrameMain=$_REQUEST['FrameMain'];$FrameLeft=$_REQUEST['FrameLeft'];$FrameTop=$_REQUEST['FrameTop'];$FrameLeft=$_REQUEST['FrameLeft'];$FrameMain=$_REQUEST['FrameMain'];$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];
$Password=$_REQUEST['Password'];
$View=$_REQUEST['View'];

$FormService=$_REQUEST['FormService'];$Service=$_REQUEST['Service'];

$ModuleName=$_REQUEST['ModuleName'];
$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];

$CookiesPassword=$_COOKIE['CookiesPassword'];
$CookiesUsername=$_COOKIE['CookiesUsername'];

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);

try {$PDO=new PDO("sqlite:/var/lib/sqlite/config.db");$PDO->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);} catch (Exception $E) 
{
	if (stristr($E->getMessage(),"open_basedir"))
	{
	header("Location: https://go.$Domain");
	}
	else
	{
	echo $E->getMessage();
	}

	exit;
}

include("include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");


if ($DBName=="")
{

	if ($_SERVER['HTTPS']=="on")
	{
	header("Location: http://{$_SERVER['HTTP_HOST']}:2020");
	}
	else
	{
	echo Error("No database selected.");
	}
	
exit;
}


// if Table AdminVariable doesn't exist
include "setup.php";

// include "authenticate.php";

$Result = SQL("select * from Config");
foreach ($Result as $Row)
{
	$JSVersion=$Row['Version'];
	$Version=Version($Row['Version']);
	$ControlScrolling=$Row['ControlScrolling'];
	$GMT=$Row['GMT'];
	
	$CR=$Row['CR'];
	$SSHPassword=$Row['SSHPassword'];
	
	$AdminHomePage=$Row['AdminHomePage'];
	
	if ($AdminHomePage=="")
	{
		$AdminHomePage="home.php?SecretCode=[SecretCode]&Theme=$Theme";
	}
	
	$AdminEmail=$Row['AdminEmail'];
	
	$IPv4=$Row['IPv4'];
	$Hostname=$Row['Hostname'];
}

if ($Theme=="") {$Theme="dark";}

$Lng=$_SESSION['SessionLng'];
if ($Lng=="") {$Lng="en";}

$Date=date ("Y-m-d");
$Time=date ("G:i A");

if ($ControlScrolling=="")
{
	$ControlScrolling="no";
}

if ($_SERVER['REQUEST_METHOD']=="POST" or ($_SESSION['SessionUserGroup']>=1) and $Theme!="")
{

	if ($_SERVER['REQUEST_METHOD']=="POST")
	{
	$Username=ValidateUsername($_REQUEST['Username']);
	$SessionPassword=ValidatePassword($_REQUEST['SessionPassword']);
	}
	
	if (stristr($Username,"'") or stristr($Username," and ")  or stristr($Username," or ") or stristr($Password,"'") or stristr($Password," and ")  or stristr($Password," or "))
	{
		echo "<link href=\"theme/$Theme/$Lng.css\" type=\"text/css\" rel=\"stylesheet\">";
		echo "<link href=\"theme/$Theme/home.css\" type=\"text/css\" rel=\"stylesheet\">";
		include "style/$Theme.php";
		
		echo "
		<table  cellPadding=0 cellSpacing=0 bgcolor=$BorderBG>
		<td width=5 align=middle background='media/image/admin/$Theme/tab-big-l-$Dir.gif' style='cursor:pointer' class=Tab height=17></td>
		<td align=middle background='media/image/admin/$Theme/tab-big-bg-on.gif' class=TabOn height=17>&nbsp; Access denied  &nbsp;</td>
		<td width=5 align=middle background='media/image/admin/$Theme/tab-big-r-$Dir.gif'  height=17></td>
		</table>
		";
		
		Echo "<table  cellPadding=0 cellSpacing=9 bgcolor=$BGColor[4] width='100%'><TD align='$DAlign' width='100%'>";
		
		echo Error("Access denied. <a href='index.php?DeleteCookiesPassword=1'>Try again</a>.");
		exit;
	}


	$Sql = "select Username from Site where Username='{$_SESSION['SessionUsername']}'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$SiteExists=1;
	}

	if ($_SESSION['SessionType']=="Root" or $_SESSION['SessionSwitchUsername']=="root" or $_SESSION['SessionSwitchUsername']=="admin" or $_SESSION['SessionSwitchUsername']=="go")
	{
		$Result = SQL("select * from User where UserID=1");
		foreach ($Result as $Row)
		{
			$Success=1;

			$_SESSION['SessionSSHUsername']=$SSHUsername;
			$_SESSION['SessionSSHPassword']=$SSHPassword;

		}
		
	}
	elseif ($_SESSION['SessionType']=="Website")
	{
	
		if ($View=="") {$View="User";}
	
		// Site Access
		$Result = SQL("select * from Site where Username='{$_SESSION['SessionUsername']}' and Password='{$_SESSION['SessionPassword']}'");
		foreach ($Result as $Row)
		{
			$Success=1;
			
			$_SESSION['SessionUsername']=$Row['Username'];
			$_SESSION['SessionDomain']=$Row['Domain'];
			$_SESSION['SessionFullName']=$Row['FullName'];
						
			$_SESSION['SessionUserGroup']=1;
	
			$_SESSION['SessionSSHUsername']=$SSHUsername;
			$_SESSION['SessionSSHPassword']=$SSHPassword;

		}
		
	}
	else
	{
		
		if (StartsWith(getcwd(),"/usr/local/goadmio"))
		{
		// Reseller
	
			$Result = SQL("select * from User where Username='{$_SESSION['SessionUsername']}' and Password='{$_SESSION['SessionPassword']}'");
			foreach ($Result as $Row)
			{
				$Success=1;
				
				$_SESSION['SessionSSHUsername']=$SSHUsername;
				$_SESSION['SessionSSHPassword']=$SSHPassword;
				
			}
			
		}
		
	}
	
	If ($Success!=1)
	{
		echo Error("Invalid username or password...");

		session_unset();
		session_destroy();
		unset($_SESSION['SessionUsername'],$_SESSION['SessionUserID'],$_SESSION['SessionPassword'],$_SESSION['SessionUserGroup'],$_SESSION['SessionFullName'],$_SESSION['SessionGender'],$_SESSION['SessionBirthDate'],$_SESSION['SessionAge'],$_SESSION['SessionRegisterDate'],$_SESSION['SessionLastVisitDate'],$_SESSION['SessionLastVisitTime'],$_SESSION['SessionUserType'],$_SESSION['SessionCountryID']);

		setcookie ("CookiesUserID","",time() -3600);
		setcookie ("CookiesUserGroup","",time() -3600);
		setcookie ("CookiesUsername","",time() -3600);
		setcookie ("CookiesPassword","",time() -3600);
		setcookie ("CookiesUserType","",time() -3600);

		Echo "<META HTTP-EQUIV='Refresh' Content='3;URL=index.php'>";


		exit;
		
	}
	
	echo "<!DOCTYPE html>";
	
	$_SESSION['SessionView']=$View;
	
	include "language/en.php";
	if ($_SESSION['SessionLng']!="en")
	{
	include "language/{$_SESSION['SessionLng']}.php";
	}
		
		echo "<html>
<head>
		
	
		<title>GoAdmio: $Domain Administration Area.</title>

		<meta charset=\"utf-8\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0\"/>
		
		<link rel=\"shortcut icon\" href=\"image/favicon.png\" type=\"image/x-icon\"/>
		<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"image/apple-touch-icon-180x180.png\"/>

		<link href=\"theme/{$_SESSION['SessionTheme']}/css/home.css?$JSVersion\" type=\"text/css\" rel=\"stylesheet\">
		<link href=\"theme/{$_SESSION['SessionTheme']}/css/folder.css\" type=\"text/css\" rel=\"stylesheet\">

		";

		if (stristr("|ar|fa|ps|sd|ug|ur|yi|","|{$_SESSION['SessionLng']}|"))
		{
		echo "<html dir=rtl>";
		$DAlign="right";
		$OAlign="left";
		
		$Dir="RTL";
		
		echo "
		<link href=\"css/rtl.css?$JSVersion\" type=\"text/css\" rel=\"stylesheet\">
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
		<link href=\"theme/{$_SESSION['SessionTheme']}/css/progress-circle.css\" type=\"text/css\" rel=\"stylesheet\">
				
		<script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js'></script>
		<link rel='stylesheet' href='include/js/jquery-ui/jquery-ui.css' />
		
		<script src='include/js/jquery-ui/jquery-ui.js'></script>
			
		<script type='text/javascript' src=\"include/js/function.js?$JSVersion\"></script>
		<script type='text/javascript' type='text/javascript' src='include/js/ajax.js'></script>

		</head>

		<body>
		";
		

		if ($View=="Mobile")
		{
			
		}
		elseif ($View=="User")
		{
			$ControlFile="info.php";
			require "layout.php";
		}
		else
		{
		
		$ControlFile="control.php";
		require "layout.php";
		
		}
		
	echo "</body>";
	echo "</html>";
}
else
{
echo "<!DOCTYPE html>
<html>
<head>
<title>GoAdmio: $Domain Administration Area. </title>

	<meta charset=\"utf-8\">
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0\"/>

	<link rel=\"shortcut icon\" href=\"image/favicon.png\" type=\"image/x-icon\"/>
	<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"image/apple-touch-icon-180x180.png\"/>


</head>

<BODY leftMargin=0 RightMargin=0 topMargin=0 marginheight=0 marginwidth=0>	


";

	if ($Theme!="dark" and $Theme!="light")
	{
	$Theme="dark";
	}

	if ($Logout==1)
	{
		unset($_SESSION['SessionUsername']);
		unset($_SESSION['SessionPassword']);

		include "style/$Theme.php";

		if (stristr("|ar|fa|ps|sd|ug|ur|yi|",$Lng))
		{
		echo "<html dir=rtl>";
		$DAlign="right";
		$OAlign="left";
		$Dir="RTL";
		}
		else
		{
		echo "<html>";
		$DAlign="left";
		$OAlign="right";
		$Dir="LTR";
		}
	
		echo "
		<table  cellPadding=0 cellSpacing=0 bgcolor=$BorderBG>
		<td width=5 align=middle background='media/image/admin/$Theme/tab-big-l-$Dir.gif' style='cursor:pointer' class=Tab height=17></td>
		<td align=middle background='media/image/admin/$Theme/tab-big-bg-on.gif' class=TabOn height=17>&nbsp; Logout  &nbsp;</td>
		<td width=5 align=middle background='media/image/admin/$Theme/tab-big-r-$Dir.gif' height=17></td>
		</table>
		";
		
		
		
		Echo "<table  cellPadding=0 cellSpacing=9 bgcolor=$BGColor[4] width='100%'><TD align='$DAlign' width='100%'>";
		
		echo Error("Going to Control Panel .");
		Echo "<META HTTP-EQUIV='Refresh' Content='2;URL=index.php'>";
		
	
		exit;
	}
	
	echo "
	<script type='text/javascript' src=\"include/js/function.js?$JSVersion\"></script>
	<script type='text/javascript' type='text/javascript' src='include/js/ajax.js'></script>
	";

	if (stristr("|ar|fa|ps|sd|ug|ur|yi|","|{$_COOKIE['CookiesLng']}|"))
	{
	echo "<html dir=rtl>";
	$DAlign="right";
	$OAlign="left";
	$Dir="RTL";
	}
	else
	{
	echo "<html>";
	$DAlign="left";
	$OAlign="right";
	$Dir="LTR";
	}


	include "language/en.php";
	if ($_COOKIE['CookiesLng']!="en")
	{
	include "language/{$_COOKIE['CookiesLng']}.php";
	}
	
	if ($SessionPassword!="")
	{

		// Logout
		session_unregister("SessionUsername");
		session_unregister("SessionPassword");
		session_destroy();

	}

	require "/usr/local/goadmio/home/go/login.php";

echo "
</body>
</html>

";
}

?>