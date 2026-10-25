<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";





$Domain=ValidateDomain($_REQUEST['Domain']);


if ($Domain!="")
{

	$DefaultDomain="";
	$Sql = "select * from Site where Domain='$Domain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$DefaultDomain=$Row['Domain'];
		$DefaultPHPVersion=trim($Row['PHPVersion']);	
	}
	
	$Output=SSH ("/usr/bin/sudo /go/multiphp Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if (stristr($Output,"|"))
	{
	$OutputArray=explode("|",$Output);
	}
	else
	{
	$OutputArray=$Output;
	}
	
	foreach ($OutputArray as &$PHPVersion) 
	{
		$PHPVersion=trim($PHPVersion);
		$ShowPHPVersion=str_replace("php","",$PHPVersion);
		
		if ($DefaultPHPVersion==$PHPVersion)
		{
		$Radio.="
		<label class=Label>PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
			<input type='radio' name=PHPVersion id=PHPVersion value='$PHPVersion' checked='checked'>
			<span class='Radio'></span>
		</label>
		";
		}
		else
		{
		$Radio.="
		<label class=Label>PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
			<input type='radio' name=PHPVersion id=PHPVersion value='$PHPVersion'>
			<span class='Radio'></span>
		</label>
		";
		}
	}

}

echo $Radio;

?>