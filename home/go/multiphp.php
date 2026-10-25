<?php
include "nav.php";
$Buttons="";
include "title.php";

$SiteID=intval($_REQUEST['SiteID']);
$Domain=ValidateDomain($_REQUEST['Domain']);

if ($_REQUEST['PHPVersion']!="")
{
$Username=ValidateUsername($_REQUEST['Username']);
$Domain=ValidateDomain($_REQUEST['Domain']);
$PHPVersion=ValidateVersion($_REQUEST['PHPVersion'],"Invalid PHP Version.");

include "access.php";

	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/multiphp $Domain $PHPVersion'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("PHP Version for $Domain changed to $PHPVersion");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;

}


	if ($Action=="Enable")
	{
		SQL("UPDATE Site set FPM='1' where Domain='$Domain'");
	
		$Error=SSH ("/usr/bin/sudo /go/apache $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	
	if ($Action=="Disable")
	{
		SQL("UPDATE Site set FPM='0' where Domain='$Domain'");
	
		$Error=SSH ("/usr/bin/sudo /go/apache $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");
	}
	

    
	include "search.php";
	
	$Header=DesignCode($Header,"$Control (Header)");
	echo $Header;
	
	$Output=SSH ("/usr/bin/sudo /go/multiphp Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if (stristr($Output,"|"))
	{
	$OutputArray=explode("|",$Output);
	}
	else
	{
	$OutputArray[]=$Output;
	}
	
	$Table="Site";$Field="Trash=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";


	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SiteID=$Row['SiteID'];
	
	$ID=$Row['SiteID'];
	
	$Username=$Row['Username'];
	$Domain=$Row['Domain'];
	$FPM=$Row['FPM'];

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}
		
		if ($FPM==1)
		{
		$FPMStatusCode="✔";
		}
		else
		{
		$FPMStatusCode="✖";
		}
		

		if ($FPM==1)
		{	
		$FPMCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Disable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox' checked>
		<span></span>
		</label>
		";
		}
		else
		{
		$FPMCode="
		<label class='CheckboxToggle' onclick=\"Load('$CurrentFileName?Action=Enable&Domain=$Domain&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
		<input type='checkbox'>
		<span></span>
		</label>
		";
		}
				
		$SelectVersion="";
		if ($FPM==1)
		{
			foreach ($OutputArray as &$PHPVersion) 
			{
				$PHPVersion=trim($PHPVersion);
				$ShowPHPVersion=str_replace("php","",$PHPVersion);
				$ShowPHPVersion=str_replace(".","",$ShowPHPVersion);

				$Version=substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1);

				if ($Row['PHPVersion']==$PHPVersion)
				{
				$SelectVersion.="
				<label class=\"radio-enhanced\">
					<input type='radio' name=PHPVersion{$SiteID} id=PHPVersion{$SiteID} value='$PHPVersion' checked='checked'>
					<span class=\"radio-custom\"></span>
					<span class=\"radio-label-text\">
					PHP $Version
					</span>
				</label>
				";
				}
				else
				{
				$SelectVersion.="
				<label class=\"radio-enhanced\">
					<input type='radio' name=PHPVersion{$SiteID} id=PHPVersion{$SiteID} value='$PHPVersion' onclick=\"Load('$CurrentFileName?Username=$Username&Domain=$Domain&PHPVersion=$PHPVersion&SiteID=$SiteID&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\">
					<span class=\"radio-custom\"></span>
					<span class=\"radio-label-text\">
					PHP $Version
					</span>
				</label>
				";
				}
							
			}

		}
	
		echo DesignCode($Loop,"$Control (Loop)");
	
		$X++;
	}
	

	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;


	
?>