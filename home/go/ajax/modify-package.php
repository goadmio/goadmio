<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$PackageID=intval($_REQUEST['PackageID']);
$Domain=trim($_REQUEST['Domain']);

if ($Domain!="")
{


	$Result=SQL("select * from Package where PackageID='$PackageID'");
	foreach ($Result as $Row)
	{ 

		$DiskSpace=$Row['DiskSpace'];
		$Bandwidth=$Row['Bandwidth'];
		$Inode=$Row['Inode'];
		$FTPNo=$Row['FTPNo'];
		$EmailNo=$Row['EmailNo'];
		$DatabaseNo=$Row['DatabaseNo'];
		$SubDomainNo=$Row['SubDomainNo'];
		$AliasNo=$Row['AliasNo'];
		$AddonNo=$Row['AddonNo'];

	}

	if ($PackageID==0)
	{
	SQL("UPDATE Site SET PackageID='$PackageID' where Domain='$Domain'");
	}
	else
	{
	SQL("UPDATE Site SET PackageID='$PackageID',DiskSpace='$DiskSpace',Bandwidth='$Bandwidth',Inode='$Inode',FTPNo='$FTPNo',EmailNo='$EmailNo',DatabaseNo='$DatabaseNo',SubDomainNo='$SubDomainNo',AliasNo='$AliasNo',AddonNo='$AddonNo' where PackageID='$PackageID' or Domain='$Domain'");
	}

	echo $Domain;

}

?>