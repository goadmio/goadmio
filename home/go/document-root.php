<?php

include "nav.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Domain']!="")
{
	$Domain=ValidateDomain($_REQUEST['Domain']);
	$DocumentRoot=ValidateDirectory($_REQUEST['DocumentRoot']);
	$DocumentRoot=trim($DocumentRoot,"/");
	
	include "access.php";
	
	SQL("UPDATE Site SET DocumentRoot='$DocumentRoot' where Domain='$Domain'");
	
	$Result = SQL("select PHPVersion from Site where Domain='$Domain'");
	foreach ($Result as $Row)
	{
		$PHPVersion=$Row['PHPVersion'];
	}
	
	$Error=SSH ("/usr/bin/sudo /go/apache $Domain && /go/nginx $Domain && /go/web",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Document Root Changed Successfully");
	
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
	
	$SelectDomain.="<select name='Domain' id='Domain' onchange=\"GetDocumentRoot()\" class=Select>";
	
	for ($E=0;$E<count($Account['Domain']);$E++)
	{
		if ($Account['Domain'][$E]==$_REQUEST['Domain'])
		{
			$SelectDomain.="<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]}</option>";
		}
		else
		{
			$SelectDomain.="<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]}</option>";
		}
	}
	
	$SelectDomain.="</select>";
	
}
else
{
	echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
	exit;
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;

?>