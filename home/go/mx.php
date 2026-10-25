<?php
include "nav.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Domain']!="")
{
$Domain=ValidateDomain($_REQUEST['Domain']);

$Error=SSH ("dig +noall +answer -t mx $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("<pre>MX Record(s): $Domain\n$Error</pre>");

echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

exit;

}


	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
?>