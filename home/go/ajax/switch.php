<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";

$Username=$_REQUEST['Username'];
$Password=$_REQUEST['Password'];

if ($DemoPassword!="")
{
	$Password=$DemoPassword;
}

if (stristr($Username,"'") or stristr($Username," and ")  or stristr($Username," or ") or stristr($Password,"'") or stristr($Password," and ")  or stristr($Password," or "))
{
	echo Error("Access denied");
	exit;
}


if ($_SESSION['SessionSwitchUsername']=="root")
{
	if ($Username=="root")
	{
		$Result = SQL("select * from User where UserID=1");
		foreach ($Result as $Row)
		{
			
			$_SESSION['SessionUserID']=$Row['UserID'];
			$_SESSION['SessionUsername']=$Row['Username'];
			$_SESSION['SessionSwitchUsername']=$Row['Username'];
			$_SESSION['SessionFullName']=$Row['FullName'];
			
			$_SESSION['SessionPassword']=$_SESSION['SessionSwitchPassword'];
			$_SESSION['SessionSSHPassword']=$_SESSION['SessionSwitchPassword'];
			
			$_SESSION['SessionUserGroup']=$Row['UserGroup'];
			echo "1";
		}
	
	}
	else
	{

		$Result = SQL("select * from Site where Username='$Username'");
		foreach ($Result as $Row)
		{
			$Success=1;
			
			$SessionAdminDomain=$_SERVER['HTTP_HOST'];
			$SessionAdminDomain=str_replace("www.","",$SessionAdminDomain);
			
			$_SESSION['SessionType']="Website";
			$_SESSION['SessionUsername']=$Row['Username'];
			$_SESSION['SessionDomain']=$Row['Domain'];
			$_SESSION['SessionFullName']=$Row['FullName'];
			
			$_SESSION['SessionPassword']=$Row['Password'];
			$_SESSION['SessionSalt']=$Row['Salt'];
			
			$_SESSION['SessionUserGroup']=5;
			
			echo "1";
			
		}
		
	}

}
else
{
// Reseller

	if (!stristr($Username,"."))
	{
		$Result = SQL("select * from User where UserID='{$_SESSION['SessionUserID']}'");
		foreach ($Result as $Row)
		{
		
			$_SESSION['SessionType']="Reseller";
			
			$SessionAdminDomain=$_SERVER['HTTP_HOST'];
			$SessionAdminDomain=str_replace("www.","",$SessionAdminDomain);
			
			$_SESSION['SessionUserID']=$Row['UserID'];
			$_SESSION['SessionUsername']=$Row['Username'];
			$_SESSION['SessionSwitchUsername']=$Row['Username'];
			$_SESSION['SessionFullName']=$Row['FullName'];
			$_SESSION['SessionSubReseller']=$Row['SubReseller'];
			
			$_SESSION['SessionUserGroup']=$Row['UserGroup'];
			
			$_SESSION['SessionResellerUsername']=$Row['Username'];

			$_SESSION['SessionPassword']=$_SESSION['SessionResellerPassword'];
			
			echo "1";	
		}
	}
	else
	{
		$Result = SQL("select * from Site where Username='$Username' and UserID='{$_SESSION['SessionUserID']}'");
		foreach ($Result as $Row)
		{
			$Success=1;
			
			$SessionAdminDomain=$_SERVER['HTTP_HOST'];
			$SessionAdminDomain=str_replace("www.","",$SessionAdminDomain);
			
			$_SESSION['SessionType']="Website";
			$_SESSION['SessionUsername']=$Row['Username'];
			$_SESSION['SessionDomain']=$Row['Domain'];
			$_SESSION['SessionFullName']=$Row['FullName'];
			
			$_SESSION['SessionPassword']=$Row['Password'];
			$_SESSION['SessionSalt']=$Row['Salt'];
			
			$_SESSION['SessionUserGroup']=5;
			
			echo "1";	
		}	
	}
}

?>