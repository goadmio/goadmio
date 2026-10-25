<?php
header('Content-Type: text/html; charset=UTF-8');
include("include/function/function.php");
include "/usr/local/goadmio/include/config/config.php";


include "/usr/local/goadmio/include/config/config.php";

$MobileApiID=intval($_REQUEST['MobileApiID']);
$ApiKey=$_REQUEST['ApiKey'];
$Start=intval($_REQUEST['Start']);
$Limit=intval($_REQUEST['Limit']);
$DESC=intval($_REQUEST['DESC']);
$OrderBy=$_REQUEST['OrderBy'];

$ApiKey=preg_replace("/[^A-Za-z0-9\_]/","", $ApiKey);
$OrderBy=preg_replace("/[^A-Za-z0-9\_]/","", $OrderBy);

$ApiExists=0;
$Sql = "select * from MobileApi where MobileApiID='$MobileApiID' and ApiKey='$ApiKey'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$ApiExists=1;

	$Name=$Row['Name'];
	$TableName=$Row['TableName'];
	$Columns=$Row['Columns'];
	$ApiKey=$Row['ApiKey'];
	$Domain=$Row['Domain'];
}

if ($ApiExists==0)
{
echo "Invalid API Key";
exit;
}

IF ($Name=="go")
{
exit;
}

$Owner=0;
$Sql = "select * from Mysql where Name='$Name' and Domain='$Domain'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
$Owner=1;
}

if ($Owner==0)
{
echo "Invalid Database Owner.";
exit;
}

$DBHost="localhost";
$DBName="$Name";
$DBUser="root";

$Options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false,];
$DSN = "mysql:host=$DBHost;dbname=$DBName;charset=utf8mb4;port=3306";
try 
{
     $PDO = new PDO($DSN, $DBUser, $DBPass, $Options);
} 
catch (PDOException $E) 
{
	echo $E->getMessage();
	exit;
}

if ($Columns=="" or $Columns=="all")
{
$Columns="*";
}


if ($OrderBy!="")
{
	if ($DESC==1)
	{
	$OrderBySQL="order by $OrderBy DESC";
	}
	else
	{
	$OrderBySQL="order by $OrderBy";
	}
}

if ($Start==0 and $Limit>=1)
{
$Sql = "select $Columns from $Name.$TableName $OrderBySQL limit $Limit";
}
elseif ($Start>=1 and $Limit>=1)
{
$Sql = "select $Columns from $Name.$TableName $OrderBySQL limit $Start,$Limit";
}
else
{
$Sql = "select $Columns from $Name.$TableName $OrderBySQL";
}

$Result = MariaDBSQL($Sql);
foreach ($Result as $Row)
{
    $Array[] = $Row;
}

echo json_encode($Array);

?>