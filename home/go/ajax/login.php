<?php
session_start();

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

$SessionDir=session_save_path();
if (!is_dir("$SessionDir"))
{
//	echo "Session Directory \"$SessionDir\" not Exists.";
//	exit;
}

$UserID=$_REQUEST['UserID'];

$Admin=$_REQUEST['Admin'];
$Logout=$_REQUEST['Logout'];
$Action=$_REQUEST['Action'];
$SessionLng=$_REQUEST['SessionLng'];
$SessionTheme=$_REQUEST['SessionTheme'];
$SessionAdminView=$_REQUEST['SessionAdminView'];

setcookie ("CookiesLng",$SessionLng,time()+31104000,"/");
setcookie ("CookiesTheme",$SessionTheme,time()+31104000,"/");
setcookie ("CookiesAdminView",$SessionAdminView,time()+31104000,"/");

if ($CookiesPassword=="deleted") {$CookiesPassword="";}

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/home/go/include/function/sendmail.php");
include("/usr/local/goadmio/home/go/include/function/advertise.php");
include("/usr/local/goadmio/include/config/config.php");

if (file_exists("vendor/autoload.php"))
{
require "vendor/autoload.php";
}

use Sonata\GoogleAuthenticator\GoogleAuthenticator;
use Sonata\GoogleAuthenticator\GoogleQrUrl;
if (class_exists(GoogleAuthenticator::class)) 
{
    $ga = new GoogleAuthenticator();
} 

	$Username=ValidateUsername($_REQUEST['Username']);
	$Password=$_REQUEST['Password'];
	$Code=ValidateUsername($_REQUEST['Code']);

	if ($Username=="root" and $DemoPassword!="")
	{
	$Password=$DemoPassword;
	}
	
	if (stristr($Username,"'") or stristr($Username," and ")  or stristr($Username," or ") or stristr($Password,"'") or stristr($Password," and ")  or stristr($Password," or "))
	{
		echo Error("Access denied");
		exit;
	}
	
	$Result = SQL("select Username from Site where Username='$Username'");
	foreach ($Result as $Row)
	{
	$SiteExists=1;
	}
	
	$Result = SQL("select * from Auth where AuthUser='$Username'");
	foreach ($Result as $Row)
	{
	$AuthUser=$Row['AuthUser'];
	$AuthSecret=$Row['AuthSecret'];
	}
	
	if ($AuthUser!="" and $AuthSecret!="")
	{
	
		if (trim($Code)=="")
		{
			echo "Please enter Google Authenticator code!";
			exit;
		}
		
		

		if (!$ga->checkCode($AuthSecret,$Code))
		{
			echo "Invalid or expired Google Authenticator code!";
			exit;
		}
	}
	
	$_SESSION['SessionControlFile']="";
	
	if ($Username=="root" or $Username=="go" or $Username=="admin")
	{

		if (CheckPassword($Username,$Password))
		{
			SQL("UPDATE User SET Username='$Username',Password='".md5($Password)."' where UserID=1");
			
			$Result = SQL("select * from User where UserID=1");
			foreach ($Result as $Row) {
				$Success = 1;
				
				$_SESSION['SessionType'] = "Root";
				$_SESSION['SkipContact'] = 1;
				
				$SessionAdminDomain = $_SERVER['HTTP_HOST'];
				$SessionAdminDomain = str_replace("www.","",$SessionAdminDomain);
				
				$_SESSION['SessionUserID'] = $Row['UserID'];
				$_SESSION['SessionUsername'] = $Row['Username'];
				$_SESSION['SessionSwitchUsername'] = $Row['Username'];
				$_SESSION['SessionFullName'] = $Row['FullName'];
				
				$_SESSION['SessionPassword'] = $Password;
				$_SESSION['SessionSwitchPassword'] = $Password;
				
				$_SESSION['SessionLng'] = $_REQUEST['SessionLng'];
				
				if ($_REQUEST['SessionTheme'] == "light") {
					$_SESSION['SessionTheme'] = "light";
				} else {
					$_SESSION['SessionTheme'] = "dark";
				}
				
				$_SESSION['SessionAdminView'] = $_REQUEST['SessionAdminView'];
				$_SESSION['SessionUserGroup'] = $Row['UserGroup'];
				
				setcookie("CookiesUsername", $Row['Username'], time()+31104000, "/");
				
				SQL("UPDATE Config SET LoginNo=LoginNo+1 where ConfigID=1");
				
				$IP = ClientIP();
				if (filter_var($IP, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
					$Error = SSH("/usr/bin/sudo screen -d -m bash -c '/go/admin $IP'", $Username, $Password, 3600);
				}
			}
		}
	

	}
	elseif ($SiteExists==1)
	{

		if (CheckPassword($Username,$Password) or CheckPassword("root",$Password))	
		{
		
			$Password=md5($Password);
			SQL("UPDATE Site SET Password='$Password' where Username='$Username'");
		
			$Result=SQL("select * from Site where Username='$Username'");
			foreach ($Result as $Row)
			{
				$Success=1;

				$ResultQ=SQL("select ControlFile from Package where PackageID='{$Row['PackageID']}'");
				foreach ($ResultQ as $RowQ)
				{
				$_SESSION['SessionControlFile']=$RowQ['ControlFile'];
				}
				
				$SessionAdminDomain=$_SERVER['HTTP_HOST'];
				$SessionAdminDomain=str_replace("www.","",$SessionAdminDomain);
				
				$_SESSION['SessionType']="Website";
				$_SESSION['SessionUsername']=$Row['Username'];
				$_SESSION['SessionDomain']=$Row['Domain'];
				$_SESSION['SessionFullName']=$Row['FullName'];
				
				$_SESSION['SessionPassword']=$Row['Password'];
				$_SESSION['SessionSalt']=$Row['Salt'];
				
				$_SESSION['SessionUserGroup']=5;
				
				$_SESSION['SessionLng']=$_REQUEST['SessionLng'];
				$_SESSION['SessionTheme']=$_REQUEST['SessionTheme'];
				$_SESSION['SessionAdminView']=$_REQUEST['SessionAdminView'];
				
				setcookie ("CookiesUsername",$Row['Username'],time()+31104000,"/");
				
			}
		}	
		
		
	}
	else
	{
	
		if (StartsWith(getcwd(),"/usr/local/goadmio"))
		{
		// Reseller
	
			$Password=md5($Password);
			$Result = SQL("select * from User where Username='$Username' and Password='$Password'");
			foreach ($Result as $Row)
			{

				$Success=1;
				
				$_SESSION['SessionType']="Reseller";
				$_SESSION['SkipContact']=1;
				
				$SessionAdminDomain=$_SERVER['HTTP_HOST'];
				$SessionAdminDomain=str_replace("www.","",$SessionAdminDomain);
				
				$_SESSION['SessionUserID']=$Row['UserID'];
				$_SESSION['SessionUsername']=$Row['Username'];
				$_SESSION['SessionSwitchUsername']=$Row['Username'];
				$_SESSION['SessionFullName']=$Row['FullName'];
				$_SESSION['SessionSubReseller']=$Row['SubReseller'];
				
				$_SESSION['SessionUserGroup']=$Row['UserGroup'];
				
				$_SESSION['SessionResellerUsername']=$Row['Username'];

				$_SESSION['SessionPassword']=$Password;
				$_SESSION['SessionResellerPassword']=$Password;
				
				$_SESSION['SessionLng']=$_REQUEST['SessionLng'];
				$_SESSION['SessionTheme']=$_REQUEST['SessionTheme'];
				$_SESSION['SessionAdminView']=$_REQUEST['SessionAdminView'];
				
				setcookie ("CookiesUsername",$Row['Username'],time()+31104000,"/");
				

			
				
			}
			

		}
		
	}
	
	
	If ($Success!=1)
	{
		echo "The login is invalid.";
		
		$IP = getenv ("REMOTE_ADDR");
		//$X=@SendMail("info@mls.eg","Access Admin Area / Failed","Someone try to access $Domain admin area using this information:<br>Username: {$_REQUEST['SessionUsername']}<br>Password: {$_REQUEST['Password']}<br>IP: $IP","Blackhost CMS","noreply@mlseg.com",1,"UTF-8");
			
		exit;
	}
	
	echo "Success";
	
?>