</TD><?php
include "nav.php";
include "no.php";
$Buttons="";
include "title.php";


if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

$Name=ValidateDatabaseName($_REQUEST['Name']);
$Username=ValidateUsername($_REQUEST['Username']);
$Password=ValidatePassword($_REQUEST['Password']);
$Database=ValidateDirectory($_REQUEST['Database']);


if ($_REQUEST['Username']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);
include "access.php";

	if (file_exists($Database))
	{
	$Error=SSH ("/usr/bin/sudo /go/sql $Domain $Name $Username $Password $Database",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");	
	}
	else
	{
	echo Error("SQL File $Database not Exists.");
	}

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}


$Result = SQL("select * from Site where Trash=0 $SearchSql order by Domain LIMIT 1");
foreach ($Result as $Row)
{

	$Database="/home/{$Row['Domain']}/www/";
	$WWWPath="/home/{$Row['Domain']}/www";

}


$SelectDomain.="<select name='Domain' class=Select>";

$Result = SQL("select * from Site where Trash=0 $SearchSql order by Domain");
foreach ($Result as $Row)
{
	if ($Row['Domain']==$Domain)
	{
	$SelectDomain.="<option value='{$Row['Domain']}' selected>{$Row['Domain']}</option>";
	}
	else
	{
	$SelectDomain.="<option value='{$Row['Domain']}'>{$Row['Domain']}</option>";
	}
}

$SelectDomain.="</select>";


$Content=DesignCode($Content,"ROOT Content");
echo $Content;




?>