<?php
include "nav.php";
$Buttons="";
include "title.php";

$AliasID=$_REQUEST['AliasID'];
$RedirectUrl=trim($_REQUEST['RedirectUrl']);
$Directory=ValidateDirectory($_REQUEST['Directory']);

$AliasDomain=ValidateDomain($_REQUEST['AliasDomain']);
$AliasDomain=strtolower($AliasDomain);

$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);

If ($Delete==1 and $Step==1)
{

	echo Error("Delete \"$AliasDomain\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&AliasDomain={$_REQUEST['AliasDomain']}&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");

	exit;
	
}

if ($Delete==1 and $Step==2)
{

	$Error=SSH ("/usr/bin/sudo /go/alias $AliasDomain AnyDomain delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	
	exit;
}

if ($_REQUEST['AliasDomain']!="")
{

	$Result = SQL("select AliasNo from Site where Domain=?", [$Domain]);
	foreach ($Result as $Row)
	{
		if ($Row['AliasNo']==-1)
		{
		echo "<div class='UnderTitle'>This feature has been disabled by your administrator.</div>";
		exit;
		}
	
	}
		
	include "access.php";
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/alias $AliasDomain $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("The alias domain $AliasDomain is currently being created for the primary domain $Domain.");
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}


	
	include "include/select/domain.php";

	echo DesignCode($Content,"$Control (Content)");

	if($Edit!=1)
	{
	
		include "search.php";

		echo DesignCode($Header,"$Control (Header)");

		$Table="Alias";$Field="Trash=0";
		$DefaultSortBy="AliasDomain";
		$DefaultDirection="ASC";
		include "include/sql.php";	

		$X=0;
		$Result = SQL($SQL);
		foreach ($Result as $Row)
		{
			if ($X%2==0) {$TDColor="Td";} else {$TDColor="TdB";}
			
			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);

			echo DesignCode($Loop,"$Control (Loop)");

		$X++;
		}
		
		$Footer=DesignCode($Footer,"$Control (Footer)");
		echo $Footer;

	}

?>