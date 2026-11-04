<?php
include "nav.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Action']=="Export")
{
header("Content-Disposition: attachment; filename=parked-domain.txt");
header("Pragma: no-cache");
header("Expires: 0");

	$Result = SQL("select * from Site where SiteID>=1 order by Domain ASC");
	foreach ($Result as $Row)
	{
	echo "{$Row['Domain']}\n";
	}

	exit;
}

if ($_REQUEST['Domain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);
$Domain=strtolower($Domain);


		$Error=SSH ("dig +noall +answer -t cname $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("<pre>CNAME Record(s): $Domain\n$Error</pre>");
		
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		
exit;

}



	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

	


?>