<?php

include "nav.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=$_REQUEST['Domain'];

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	if ($_SESSION['SessionResellerUsername']=="")
	{
	echo "
	Sorry, You Are Not Allowed to Access This Page
	";
	exit;
	}
}

   
	if ($Edit!=1)
	{
		
		include "search.php";
		
		$Header=DesignCode($Header,"$Control (Header)");
		echo $Header;
		
	}

	
	if ($Edit==1 and $Domain!="")
	{
	$Table="Site";$Field="Domain='$Domain'";
	}
	else
	{
	$Table="Site";$Field="Trash=0";
	}
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";


	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SiteID=$Row['SiteID'];
	$ID=$Row['SiteID'];
	
	$Domain=$Row['Domain'];
	$Username=$Row['Username'];

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}

		$SelectPackage.="<select id='PackageID' name='PackageID' onchange='ModifyPackage()' class=Select><option value='0' selected>Custom</option>";
		$ResultQ = SQL("select * from Package where UserID='{$_SESSION['SessionUserID']}' order by Name");
		foreach ($ResultQ as $RowQ)
		{
			if ($RowQ['PackageID']==$Row['PackageID'])
			{
			$SelectPackage.="<option value='{$RowQ['PackageID']}' selected>{$RowQ['Name']}</option>";
			}
			else
			{
			$SelectPackage.="<option value='{$RowQ['PackageID']}'>{$RowQ['Name']}</option>";
			}
		}
		$SelectPackage.="</select>";

		$SpaceUsed=FormatSize($Row['SpaceUsed']);
		if (intval($Row['DiskSpace'])==0) 
		{
		$DiskSpace=$LNG['Unlimited'];
		}
		else
		{
		$DiskSpace=FormatSize($Row['DiskSpace']);
		}
		
		$BandwidthUsed=FormatSize($Row['BandwidthUsed']);
		if (intval($Row['Bandwidth'])==0) 
		{
		$Bandwidth=$LNG['Unlimited'];
		}
		else
		{
		$Bandwidth=FormatSize($Row['Bandwidth']);
		}

		$InodeUsed=intval($Row['InodeUsed']);
		if (intval($Row['Inode'])==0) 
		{
		$Inode=$LNG['Unlimited'];
		}
		else
		{
		$Inode=$Row['Inode'];
		}

		$FTPNoUsed=RowCount("SELECT * FROM Ftp where Username='$Username'");
		if (intval($Row['FTPNo'])==0)
		{
		$FTPNo=$LNG['Unlimited'];
		}
		elseif ($Row['FTPNo']==-1)
		{
		$FTPNo=$LNG['Disabled'];
		}
		else
		{
		$FTPNo=$Row['FTPNo'];
		}


		$EmailNoUsed=RowCount("SELECT * FROM Mail where Username='$Username'");
		if (intval($Row['EmailNo'])==0)
		{
		$EmailNo=$LNG['Unlimited'];
		}
		elseif ($Row['EmailNo']==-1)
		{
		$EmailNo=$LNG['Disabled'];
		}
		else
		{
		$EmailNo=$Row['EmailNo'];
		}
		
		
		$DatabaseNoUsed=RowCount("SELECT * FROM Mysql where Username='$Username'");
		if (intval($Row['DatabaseNo'])==0)
		{
		$DatabaseNo=$LNG['Unlimited'];
		}
		elseif ($Row['DatabaseNo']==-1)
		{
		$DatabaseNo=$LNG['Disabled'];
		}
		else
		{
		$DatabaseNo=$Row['DatabaseNo'];
		}
		
		$SubDomainNoUsed=RowCount("SELECT * FROM Subdomain where Username='$Username'");
		if (intval($Row['SubDomainNo'])==0)
		{
		$SubDomainNo=$LNG['Unlimited'];
		}
		elseif ($Row['SubDomainNo']==-1)
		{
		$SubDomainNo=$LNG['Disabled'];
		}
		else
		{
		$SubDomainNo=$Row['SubDomainNo'];
		}

		$AliasNoUsed=RowCount("SELECT * FROM Alias where Domain='$Domain'");
		$AliasNo=intval($Row['AliasNo']);
		
		$AddonNoUsed=RowCount("SELECT * FROM Site where Username='$Username' and Owner!=''");
		$AddonNo=intval($Row['AddonNo']);
		
		if (intval($Row['TimeStamp'])>=1)
		{
		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
		}

		

	echo DesignCode($Loop,"$Control (Loop)");

	
	$X++;
	}
	
	
	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;	

	
?>