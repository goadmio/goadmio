<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "Sorry, You Are Not Allowed to Access This Page";
	exit;
}

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid GoAdmio Path";
	exit;
}

$ProgressFile=$_REQUEST['ProgressFile'];

if (file_exists("/var/log/go/progress/$ProgressFile"))
{
	
	$Lines = file("/var/log/go/progress/$ProgressFile", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
	
	$MatchingLines = preg_grep('/\.\.\.$/', $Lines);
	$Message = end($MatchingLines);
	
	$MatchingLines = preg_grep('/^\d{1,3}$/', $Lines);
	$P = end($MatchingLines);
	
	if (empty($Lines)) 
	{
		echo "0|$Message";
	}
	else
	{
		$P=intval($P);
		
		if (intval($P)>=0 and intval($P)<=100)
		{
		echo "$P|$Message";
		}
		else
		{
		echo "0|$Message";
		}
	}
}
else
{
echo "0|Progress Failed";
}
