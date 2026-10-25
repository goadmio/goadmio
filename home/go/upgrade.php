<?php
include "nav.php";
$Buttons="";

$Result = SQL("select * from Config");
foreach ($Result as $Row)
{
$Version=intval($Row['Version']);
$InstallDate=date("D j M Y g:i a", $Row['InstallStamp']);
}

$Latest=intval(file_get_contents("https://download.goadmio.com/home/go/update/latest.txt"));
$NewVersion=Version($Latest);

include "title.php";

	if ($Version!=$Latest)
	{
		echo "<div class=NavigatorInfo id=Update><img src='theme/{$_SESSION['SessionTheme']}/image/update.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['ANewVersion']} v{$NewVersion} {$LNG['IsAvailable']}. <a href='javascript:Update();' class=Action>{$LNG['UpdateNow']}</a></div>";
	}
	else
	{
		
		echo "<div class=NavigatorInfo id=Update><img src='theme/{$_SESSION['SessionTheme']}/image/update.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'> GoAdmio v{$NewVersion} (Already Up to Date)</div>";
		
	}

$AdminEmail=$_REQUEST['AdminEmail'];
$QueueNo=intval($_REQUEST['QueueNo']);
$SSHAlert=intval($_REQUEST['SSHAlert']);

	if ($_SESSION['SessionType']!="Root")
	{
		echo "Sorry, You Are Not Allowed to Access This Page";
		exit;
	}


	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>