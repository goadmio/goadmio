<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
$CurrentFileName=basename ($_SERVER['PHP_SELF']);
include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

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

		header("Location: phpmyadmin/");
		
	}
	else
	{
	
		$RowsNo=RowCount("SELECT * FROM Mysql where Domain='{$_SESSION['SessionDomain']}'");
	
		if ($RowsNo>=1)
		{			
			SSH ("/usr/bin/sudo /go/phpmyadmin {$_SESSION['SessionDomain']}",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],86400);
		
			setcookie ("CookiesMySQLUsername",$_SESSION['SessionDomain'],0,"/","");
			setcookie ("CookiesMySQLPassword",$_SESSION['SessionSalt'],0,"/","");

			setcookie ("CookiesMySQLUsername",$_SESSION['SessionDomain'],0,"/","",true);
			setcookie ("CookiesMySQLPassword",$_SESSION['SessionSalt'],0,"/","",true);

			header("Location: phpmyadmin/");

		
		}
		else
		{
			echo Error("There are no databases associated with your account.");
		}
		
	}

?>