<?php
include "nav.php";
include "no.php";
$Buttons="";
include "title.php";

	if ($_REQUEST['Timezone']=="")
	{
		echo "
		<div class=NavigatorInfo id=DivCurrentTime>
		{$LNG['CurrentTime']}: $CurrentTime
		</div>
		";
	}


$Domain=ValidateDomain($_REQUEST['Domain']);
$Timezone=$_REQUEST['Timezone'];


if ($_REQUEST['Timezone']!="")
{		

include "access.php";

$Domain=ValidateDomain($_REQUEST['Domain']);

		SQL("update Site set Timezone='$Timezone' where Domain='$Domain'");
		$Error=SSH ("/usr/bin/sudo /go/php-fpm $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		echo Error("$Domain timezone has been set to $Timezone.");
		
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;	
}

		unset($Domains);
		$Sql = "select * from Site where Trash=0 $SearchSql";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
		
		if (is_array($Domains))
		{
			sort($Domains);

			$SelectDomain="<select name='Domain' id='Domain' onchange='CurrentTimezone()' class=Select>";
			$CurrentDomain="";
			foreach ($Domains as $Domain) 
			{
				if ($CurrentDomain=="")
				{
				$CurrentDomain=$Domain;
				}

				$SelectDomain.="<option value='$Domain'>$Domain</option>";
			}
			$SelectDomain.="</select>";
			
		}
		
	$Sql = "select * from Site where Domain='$CurrentDomain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		$Timezone=trim($Row['Timezone']);
	}
	
	date_default_timezone_set($Timezone);
	
	$Checked=$Timezone;
	$Checked=str_replace("/","",$Checked);
	$Checked=str_replace("-","",$Checked);
	$Checked=str_replace(" ","",$Checked);

	$$Checked="selected";		
		
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
		
?>