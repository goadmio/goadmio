<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
$CurrentFileName=basename ($_SERVER['PHP_SELF']);
include("include/function/function.php");
include "/usr/local/goadmio/include/config/config.php";

$Name=$_REQUEST['Name'];
$Username=ValidateUsername($_REQUEST['Username']);
$Password=ValidatePassword($_REQUEST['Password']);
$PHPMyAdmin=$_REQUEST['PHPMyAdmin'];

$MysqlID=trim($_REQUEST['MysqlID']);

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);

	if ($_SESSION['SessionType'] == "Root")
	{
		setcookie ("CookiesMySQLUsername","root",0,"/","");
		setcookie ("CookiesMySQLPassword",$DBPass,0,"/","");

		setcookie ("CookiesMySQLUsername","root",0,"/","",true);
		setcookie ("CookiesMySQLPassword",$DBPass,0,"/","",true);

		header("Location: adminer/");
		
	}
	else
	{
		$RowsNo=RowCount("SELECT * FROM Mysql where Username='{$_SESSION['SessionUsername']}'");
	
		if ($RowsNo>=1)
		{			
			setcookie ("CookiesMySQLUsername",$_SESSION['SessionUsername'],0,"/","");
			setcookie ("CookiesMySQLPassword",$_SESSION['SessionSalt'],0,"/","");

			setcookie ("CookiesMySQLUsername",$_SESSION['SessionUsername'],0,"/","",true);
			setcookie ("CookiesMySQLPassword",$_SESSION['SessionSalt'],0,"/","",true);

			header("Location: adminer/");
		
		}
		else
		{
			echo Error("There are no databases associated with your account.");
		}
		
	}

?>