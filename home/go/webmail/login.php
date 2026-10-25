<?php
session_start();

// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR);

$UserID=$_REQUEST['UserID'];$Open=$_REQUEST['Open'];$HTMLFileName=$_REQUEST['HTMLFileName'];
$OperatorImage=$_REQUEST['OperatorImage'];$Admin=$_REQUEST['Admin'];$DisableWelcomeMsg=$_REQUEST['DisableWelcomeMsg'];$DeleteCookiesEmailPass=$_REQUEST['DeleteCookiesEmailPass'];$Logout=$_REQUEST['Logout'];$Action=$_REQUEST['Action'];$do=$_REQUEST['do'];$domainname=$_REQUEST['domainname'];$CookiesLoginOption=$_REQUEST['CookiesLoginOption'];$MainPage=$_REQUEST['MainPage'];$Ext=$_REQUEST['Ext'];
$FrameTop=$_REQUEST['FrameTop'];$FrameMain=$_REQUEST['FrameMain'];
$FrameLeft=$_REQUEST['FrameLeft'];$FrameTop=$_REQUEST['FrameTop'];
$FrameLeft=$_REQUEST['FrameLeft'];$FrameMain=$_REQUEST['FrameMain'];$FormLogin=$_REQUEST['FormLogin'];
$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];
$FastLogin=$_REQUEST['FastLogin'];
$SessionLng=$_REQUEST['SessionLng'];

$FormService=$_REQUEST['FormService'];$Service=$_REQUEST['Service'];

$MonotypeKoufi=$_REQUEST['MonotypeKoufi'];
$ModuleName=$_REQUEST['ModuleName'];
$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];
$SessionTheme=$_REQUEST['SessionTheme'];
$SessionAdminView=$_REQUEST['SessionAdminView'];

setcookie ("CookiesLng",$SessionLng,time()+31104000,"/");
setcookie ("CookiesTheme",$SessionTheme,time()+31104000,"/");
setcookie ("CookiesAdminView",$SessionAdminView,time()+31104000,"/");

if ($CookiesEmailPass=="deleted") {$CookiesEmailPass="";}



include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");


	$EmailUser=addslashes(strtolower($_REQUEST['EmailUser']));
	$EmailPass=addslashes($_REQUEST['EmailPass']);


	
	if (stristr($EmailUser,"'") or stristr($EmailUser," and ")  or stristr($EmailUser," or ") or stristr($EmailPass,"'") or stristr($EmailPass," and ")  or stristr($EmailPass," or "))
	{
		echo Error("Access denied");
		exit;
	}
	

				$Result = SQL("select * from Mail where Email='$EmailUser' and Pass='$EmailPass' and Suspend=0");
				foreach ($Result as $Row)
				{

					$Success=1;
					
					$EmailArray=explode("@",$Row['Email']);
					
					$_SESSION['SessionMailID']=$Row['MailID'];
					$_SESSION['SessionEmail']=$Row['Email'];
					$_SESSION['SessionEmailPass']=$EmailPass;
					$_SESSION['SessionWebsiteUsername']=$Row['Username'];
					$_SESSION['SessionEmailDomain']=$EmailArray[1];
					
					$_SESSION['SessionLng']=$_REQUEST['SessionLng'];
					$_SESSION['SessionTheme']=$_REQUEST['SessionTheme'];
					$_SESSION['SessionAdminView']=$_REQUEST['SessionAdminView'];
					
					setcookie ("CookiesEmail",$Row['Email'],time()+31104000,"/");
					

					setcookie ("CookiesRoundcubeEmail",$Row['Email'],0,"/","");
					setcookie ("CookiesRoundcubePass",$Row['Pass'],0,"/","");

					setcookie ("CookiesRoundcubeEmail",$Row['Email'],0,"/","",true);
					setcookie ("CookiesRoundcubePass",$Row['Pass'],0,"/","",true);

					
					

				}
			



	
	If ($Success!=1)
	{
		echo "The login is invalid.";
		
		$IP = getenv ("REMOTE_ADDR");
		//$X=@SendMail("info@mls.eg","Access Admin Area / Failed","Someone try to access $Domain admin area using this information:<br>EmailUser: {$_REQUEST['SessionEmail']}<br>EmailPass: {$_REQUEST['EmailPass']}<br>IP: $IP","Blackhost CMS","noreply@mlseg.com",1,"UTF-8");
			
		exit;
	}
	
	echo "Success";
	
?>