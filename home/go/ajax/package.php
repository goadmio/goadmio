<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$PackageID=intval($_REQUEST['PackageID']);


if ($PackageID!="")
{

	$Result=SQL("select * from Package where PackageID='$PackageID'");
	foreach ($Result as $Row)
	{ 
		$DiskSpace=intval($Row['DiskSpace'])/1048576;
		$Bandwidth=intval($Row['Bandwidth'])/1048576;
		$Inode=$Row['Inode'];
		$FTPNo=$Row['FTPNo'];
		$EmailNo=$Row['EmailNo'];
		$DatabaseNo=$Row['DatabaseNo'];
		$SubDomainNo=$Row['SubDomainNo'];
		$AliasNo=$Row['AliasNo'];
		$AddonNo=$Row['AddonNo'];


		echo "$DiskSpace|$Bandwidth|$Inode|$FTPNo|$EmailNo|$DatabaseNo|$SubDomainNo|$AliasNo|$AddonNo";

	}

}

?>