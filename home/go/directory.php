<?php
include "nav.php";
include "no.php";
$Buttons="";
include "title.php";


if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}


if ($_REQUEST['User']!="")
{
$Name=trim($_REQUEST['Name']);
$Directory=trim($_REQUEST['Directory']);
$User=trim($_REQUEST['User']);
$Password=trim($_REQUEST['Password']);

$DirectoryArray=explode("/",$Directory);
$Domain=$DirectoryArray[2];

$Result = SQL("select Username from Site where Domain='$Domain'");
foreach ($Result as $Row)
{
$Username=$Row['Username'];
}

include "access.php";

	if (file_exists($Directory))
	{
		if ($Action=="Delete")
		{
		$Error=SSH ("/usr/bin/sudo /go/directory $Username $Directory delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");	
		}
		else
		{
		$Error=SSH ("/usr/bin/sudo /go/directory $Username $Directory $User $Password",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("$Error");			
		}
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
	
	$SelectDomain="<select name='WWWPath' id='WWWPath' onchange='Folder()' class=Select>";
	for ($E=0;$E<count($Account['Domain']);$E++)
	{
	
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
}

$Content=DesignCode($Content,"ROOT Content");
echo $Content;


include "search.php";
		
$Header=DesignCode($Header,"$Control (Header)");
echo $Header;

$Table="Directory";$Field="DirectoryID>=1";
$DefaultSortBy="Directory";
$DefaultDirection="ASC";
include "include/sql.php";

$X=0;		
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	
	$Directory=$Row['Directory'];
	
	if ($X==0)
	{
	echo "<TBODY>";
	}

	if ($X%2==0)
	{
	$TDColor="Td";
	}
	else
	{
	$TDColor="TdB";
	}
	
	$SerialNo=(($Page-1)*$PageNo)+($X+1);

	$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

	echo DesignCode($Loop,"$Control (Loop)");
	
	
$X++;
}
		
$Footer=DesignCode($Footer,"$Control (Footer)");
echo $Footer;





?>