<?php

include "nav.php";
$Buttons="";
include "title.php";

$GithubID=intval($_REQUEST['GithubID']);

$ScriptFile=$_REQUEST['ScriptFile'];
$Name=$_REQUEST['Name'];
$User=ValidateUsername($_REQUEST['User']);
$Pass=ValidatePassword($_REQUEST['Pass']);
$Directory=$_REQUEST['Directory'];
$Home=$_REQUEST['Home'];
$ScriptID=$_REQUEST['ScriptID'];

$DomainArray=explode("/",$Directory);
$Domain=$DomainArray[2];

if ($_REQUEST['Directory']!="")
{
	$Result = SQL("select Username from Site where Domain='$Domain'");
	foreach ($Result as $Row)
	{
	$Username=$Row['Username'];
	}

	include "access.php";

	if (file_exists($Directory))
	{
		if (trim($Domain)=="") {echo "Invalid Domain: $Domain";exit;}
		if (trim($ScriptFile)=="") {echo "Invalid Script File: $ScriptFile";exit;}
		if (trim($Directory)=="") {echo "Invalid Directory: $Directory";exit;}
		if (trim($Name)=="") {echo "Invalid Datanase Name: $Name";exit;}
		if (trim($User)=="") {echo "Invalid Datanase User: $User";exit;}
		if (trim($Pass)=="") {echo "Invalid Datanase Pass: $Pass";exit;}
		if (trim($ScriptID)=="") {echo "Invalid Script ID: $ScriptID";exit;}

		$Error=SSH ("/usr/bin/sudo /go/script $Domain $ScriptFile $Directory $Name $User $Pass $ScriptID",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		echo Error("$Error");
	
		exit;
		
	}
	else
	{
	echo Error("Directory $Directory not Exists.");
	}

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}



	$Result = SQL("select * from Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
	$Account['Domain'][]=$Row['Domain'];
	$Account['Username'][]=$Row['Username'];
	}
	
	if (is_array($Account['Domain']))
	{
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);
		
		$SelectDomain="<select name='WWWPath' id='WWWPath' onchange='Folder();MySQL();' class=Select>";
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($DefaultDomain=="")
			{
			$DefaultDomain=$Account['Domain'][$E];
			}
		
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			$SelectDomain.="<option value='/home/{$Account['Domain'][$E]}/www' selected>{$Account['Domain'][$E]}</option>";
			}
			else
			{
			$SelectDomain.="<option value='/home/{$Account['Domain'][$E]}/www'>{$Account['Domain'][$E]}</option>";
			}
		}
		
		$SelectDomain.="</select>";
		
		$DefaultDomainArray=explode(".",$DefaultDomain);
		
		$SelectVersion="<select name='ScriptID' id='ScriptID' class=Select>";
		$Result = SQL("select * from Script where ScriptFile='$ScriptFile' order by ScriptID");
		foreach ($Result as $Row)
		{
			if ($Row['ScriptID']==$ScriptID)
			{
			$SelectVersion.="<option value='{$Row['ScriptID']}' selected>{$Row['ScriptVersion']} ({$Row['ScriptLanguage']})</option>";
			}
			else
			{
			$SelectVersion.="<option value='{$Row['ScriptID']}'>{$Row['ScriptVersion']} ({$Row['ScriptLanguage']})</option>";
			}
		}
		
		$SelectVersion.="</select>";
		
		$Name=$DefaultDomainArray[0]."_".$ScriptFile;
		$Name=str_replace("-","",$Name);
		
		$User=$DefaultDomainArray[0]."_".$ScriptFile;
		$User=str_replace("-","",$User);
		
		$Content=DesignCode($Content,"$Control (Content)");
		echo $Content;

	}
	else
	{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}
	



?>