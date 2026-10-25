<?php



include "nav.php";
if ($_SESSION['SessionType'] == "Root")
{
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Repair&Name=all')\" class='ButtonB {$Dir}ButtonB'>Repair All</a>";
}
include "title.php";


$Name=$_REQUEST['Name'];

$UserNo=RowCount("select * from Mysql where MysqlID>=1");
    
If ($Action=="Repair")
{
	
	$Error=SSH ("/usr/bin/sudo /go/repair $Name $DBPassword",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	if ($Name=="all")
	{
	echo Error("Repair All MySQL Databases Running in background");
	}
	else
	{	
	echo Error("Repairing MySQL Database $Name{$Error}");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;
}
	

	include "search.php";

	$Header=DesignCode($Header,"$Control (Header)");
	echo $Header;
	

	$Table="Mysql";$Field="MysqlID>=1";
	$DefaultSortBy="Name";
	$DefaultDirection="ASC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
		$Name=$Row['Name'];

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}
		
		$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

		echo DesignCode($Loop,"$Control (Loop)");

	
		$X++;
	}
	
	$Footer=DesignCode($Footer,"$Control (Footer)");
	echo $Footer;


?>