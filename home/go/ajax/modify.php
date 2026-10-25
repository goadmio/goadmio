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

// Input ID
$ID=$_REQUEST['ID'];

$SiteID=$_REQUEST['SiteID'];
$Value=$_REQUEST['Value'];

if (stristr($ID,"DiskSpace"))
{
	
	$Value=intval($Value);
	
	$DiskSpace=$Value*1048576;
	SQL("UPDATE Site set DiskSpace='$DiskSpace' where SiteID='$SiteID'");
	if ($DiskSpace==0) 
	{
		$DiskSpace="Unlimited";
	}
	else
	{
		$DiskSpace=FormatSize($DiskSpace);
	}
	echo $DiskSpace;
	
}

if (stristr($ID,"Bandwidth"))
{
	
	$Value=intval($Value);
	
	$Bandwidth=$Value*1048576;
	SQL("UPDATE Site set Bandwidth='$Bandwidth' where SiteID='$SiteID'");
	if ($Bandwidth==0) 
	{
		$Bandwidth="Unlimited";
	}
	else
	{
		$Bandwidth=FormatSize($Bandwidth);
	}
	echo $Bandwidth;
	
}

if (stristr($ID,"Inode"))
{
	$Value=intval($Value);
	
	$Inode=$Value;
	SQL("UPDATE Site set Inode='$Inode' where SiteID='$SiteID'");
	if ($Inode==0) 
	{
		$Inode="Unlimited";
	}
	else
	{
		$Inode=$Inode;
	}
	echo $Inode;
	
}

if (stristr($ID,"FTPNo"))
{
	$Value=intval($Value);
	
	$FTPNo=intval($Value);
	SQL("UPDATE Site set FTPNo='$FTPNo' where SiteID='$SiteID'");
	if ($FTPNo==0) 
	{
		$FTPNo="Unlimited";
	}
	elseif ($FTPNo==-1) 
	{
		$FTPNo="Disabled";
	}
	echo $FTPNo;
	
}

if (stristr($ID,"EmailNo"))
{
	$Value=intval($Value);
	
	$EmailNo=intval($Value);
	SQL("UPDATE Site set EmailNo='$EmailNo' where SiteID='$SiteID'");
	if ($EmailNo==0) 
	{
		$EmailNo="Unlimited";
	}
	elseif ($EmailNo==-1) 
	{
		$EmailNo="Disabled";
	}
	echo $EmailNo;
	
}

if (stristr($ID,"DatabaseNo"))
{
	$Value=intval($Value);
	
	$DatabaseNo=intval($Value);
	SQL("UPDATE Site set DatabaseNo='$DatabaseNo' where SiteID='$SiteID'");
	if ($DatabaseNo==0) 
	{
		$DatabaseNo="Unlimited";
	}
	elseif ($DatabaseNo==-1) 
	{
		$DatabaseNo="Disabled";
	}
	echo $DatabaseNo;
	
}

if (stristr($ID,"SubDomainNo"))
{
	$Value=intval($Value);
	
	$SubDomainNo=intval($Value);
	SQL("UPDATE Site set SubDomainNo='$SubDomainNo' where SiteID='$SiteID'");
	if ($SubDomainNo==0) 
	{
		$SubDomainNo="Unlimited";
	}
	elseif ($SubDomainNo==-1) 
	{
		$SubDomainNo="Disabled";
	}
	echo $SubDomainNo;
	
}

if (stristr($ID,"AliasNo"))
{
	$Value=intval($Value);
	
	$AliasNo=intval($Value);
	SQL("UPDATE Site set AliasNo='$AliasNo' where SiteID='$SiteID'");
	if ($AliasNo<=0) 
	{
		$AliasNo="Disabled";
	}
	echo $AliasNo;
	
}

if (stristr($ID,"AddonNo"))
{
	$Value=intval($Value);
	
	$AddonNo=intval($Value);
	SQL("UPDATE Site set AddonNo='$AddonNo' where SiteID='$SiteID'");
	if ($AddonNo<=0) 
	{
		$AddonNo="Disabled";
	}
	echo $AddonNo;
	
}

?>