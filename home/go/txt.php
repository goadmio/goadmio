<?php
include "nav.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Domain']!="")
{
	if (stristr($_REQUEST['Domain'],"_"))
	{
	// dkim._domainkey
	$Domain=trim($_REQUEST['Domain']);
	}
	else
	{
	$Domain=ValidateDomain($_REQUEST['Domain']);
	}

	$Domain=strtolower($Domain);

	$Error=SSH ("dig +noall +answer -t txt $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("<pre>TXT Record(s): $Domain\n$Error</pre>");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}




	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
?>