<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$ServerIP=ValidateUsername($_REQUEST['ServerIP']);

$Result = SQL("SELECT DiskType FROM Server where ServerIP='$ServerIP'");
foreach ($Result as $Row)
{
$DiskType=$Row['DiskType'];
}


$Result = SQL("SELECT * FROM Plan where DiskType='$DiskType' order by DiskType,DiskSpace");
foreach ($Result as $Row)
{
$Plan['PlanID'][]=$Row['PlanID'];
$Plan['PlanName'][]=$Row['PlanName'];
$Plan['DiskType'][]=$Row['DiskType'];
$Plan['DiskSpace'][]=$Row['DiskSpace'];
$Plan['Cores'][]=$Row['Cores'];
$Plan['Memory'][]=$Row['Memory'];
$Plan['Price'][]=$Row['Price'];
}


echo "
<select name='Plan' id='Plan' class=Select onchange='SetPlan()'>
<option value='' selected>Select Plan</option>
";

for ($E=0;$E<count($Plan['PlanID']);$E++)
{
	if ($Plan['PlanName'][$E]==$PlanName)
	{
	echo "<option value='{$Plan['PlanID'][$E]}|{$Plan['PlanName'][$E]}|{$Plan['DiskType'][$E]}|{$Plan['DiskSpace'][$E]}|{$Plan['Cores'][$E]}|{$Plan['Memory'][$E]}|{$Plan['Price'][$E]}' selected>{$Plan['PlanName'][$E]}</option>";
	}
	else
	{
	echo "<option value='{$Plan['PlanID'][$E]}|{$Plan['PlanName'][$E]}|{$Plan['DiskType'][$E]}|{$Plan['DiskSpace'][$E]}|{$Plan['Cores'][$E]}|{$Plan['Memory'][$E]}|{$Plan['Price'][$E]}'>{$Plan['PlanName'][$E]}</option>";
	}
}

echo "
</select>
";


?>