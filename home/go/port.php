<?php
include "nav.php";
$Buttons="";
include "title.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	Echo "
	Sorry, You Are Not Allowed to Access This Page	
	";

exit;
}

if ($_REQUEST['PORT']!="")
{

	if ($DemoPassword!="")
	{
	echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
	exit;
	}

	$PORT=intval($_REQUEST['PORT']);
	if ($PORT==0)
	{
	$PORT=22;
	}

	$DROPBEARPORT=intval($_REQUEST['DROPBEARPORT']);
	if ($DROPBEARPORT==0)
	{
	$DROPBEARPORT=33;
	}

	// Change SHELL in BOX Port
	$Result = SQL("select * from Config where ConfigID=1");
	foreach ($Result as $Row)
	{
		$SSH=$Row['SSH'];
	}
	
	if ($SSH=="") {$SSH="Black";}
	
	$Error=SSH ("/usr/bin/sudo /go/ssh $SSH {$_SERVER['SERVER_ADDR']} $PORT {$_SERVER['HTTP_HOST']} $DBPassword",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	// Change SSH Port
	$Error=SSH ("/usr/bin/sudo /go/port $PORT",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	
	SSH ("/usr/bin/sudo /go/dropbear $DROPBEARPORT",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	exit;

}
	
	$Hostname=gethostname();
		

	$Result = SQL("select SSHPort from Config where ConfigID=1");
	foreach ($Result as $Row)
	{	
		$SSHPort=$Row['SSHPort'];
	}
		
	// if demo mode do not display true SSH Port
	if ($DemoPassword!="")
	{
	$SSHPort="22";
	}
	
	$DROPBEARPORT=SSH ("/usr/bin/sudo /go/dropbear PORT",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$DROPBEARPORT=trim($DROPBEARPORT);

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>