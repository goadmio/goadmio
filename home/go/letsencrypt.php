<?php
include "navigator.php";
include "no.php";

if ($_SESSION['SessionType'] == "Root")
{
	if ($_REQUEST['Action']!="SSLAll")
	{
	$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=SSLAll&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['InstallSSLCertificateForAllDomains']}</a>";
	}
}

include "title.php";


if ($_REQUEST['Action']=="SSLAll")
{
	if ($_SESSION['SessionType'] == "Root")
	{

	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/ssl all'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo Error("Working on it...");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;
	}
}


if ($_REQUEST['Domain']!="")
{

	if ($DemoPassword!="")
	{
		if (stristr($Domain,"w75.net") or stristr($Domain,"demo."))
		{
		echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
		exit;
		}
	}
	

	$Domain=ValidateDomain($_REQUEST['Domain']);
	$Type=$_REQUEST['Type'];


	include "access.php";

	$ProgressFile="ssl-$Domain.log";
	$Error=SSH ("sudo screen -d -m bash -c '/go/ssl $Domain --progress > /var/log/go/progress/$ProgressFile'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("SSL installation for $Domain is running in the background. You can safely close this page.");
	echo Progress("Installing SSL for $Domain",$ProgressFile);
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}


    
	
	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	";
	
	unset($Domains);
	$Result = SQL("select * from Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
	$Domains[]=$Row['Domain'];
	}
	
	if (is_array($Domains))
	{
		sort($Domains);
	}
	else
	{
		$Domains[]="";
	}
	
	echo "
	<select name='Domain' id='Domain' class=Select>
	";
	
	foreach ($Domains as &$Domain) 
	{
		if ($Domain==$_REQUEST['Domain'])
		{
		echo "<option value='$Domain' selected>$Domain</option>";
		}
		else
		{
		echo "<option value='$Domain'>$Domain</option>";
		}
	}

	echo "
	</select>
	
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['Type']}
	<br>

		<label class=\"radio-enhanced\">
			<input type='radio' name=Type id=Type value='--letsencrypt' checked='checked'>
			<span class=\"radio-custom\"></span>
			<span class=\"radio-label-text\">
			Let's Encrypt
			</span>
		</label>


	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['Install']}' Class=InputButton>
	</div>

	
</form>

";	

?>