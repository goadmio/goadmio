<?php
include "nav.php";
$Buttons="";
include "title.php";

if ($_SESSION['SessionType']!="Root")
{
	Echo "
	Sorry, You Are Not Allowed to Access This Page	
	";

exit;
}

if ($DemoPassword!="")
{
echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
exit;
}

if ($_REQUEST['Delete']==1)
{
	$IP=trim($_REQUEST['IP']);

	if (filter_var($IP, FILTER_VALIDATE_IP))
	{
		$Error=SSH ("/usr/bin/sudo /go/permitrootlogin $IP --delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$Error=Error($Error);
	}
	else
	{
		$Error="Invalid IP \"$IP\"";
		$Error=Error($Error);
	}

}
elseif (stristr($_REQUEST['IP'],"."))
{

	$IP=trim($_REQUEST['IP']);

	if (filter_var($IP, FILTER_VALIDATE_IP))
	{
		$Error=SSH ("/usr/bin/sudo /go/permitrootlogin $IP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$Error=Error($Error);
	}
	else
	{
		$Error="Invalid IP \"$IP\"";
		$Error=Error($Error);
	}

}
elseif ($_REQUEST['PORT']!="")
{
	if ($DemoPassword!="")
	{
	echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	}

	$PORT=intval($_REQUEST['PORT']);
	if ($PORT==0)
	{
	$PORT=22;
	}

	// Change SSH Port
	$Error=SSH ("/usr/bin/sudo /go/port $PORT",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

	exit;

}
elseif ($_REQUEST['DROPBEARPORT']!="")
{

	if ($DemoPassword!="")
	{
	echo Error($LNG['ThisFunctionalityNotAvailableDemoMode']);
	exit;
	}

	$DROPBEARPORT=intval($_REQUEST['DROPBEARPORT']);
	if ($DROPBEARPORT==0)
	{
	$DROPBEARPORT=22222;
	}
	
	$Error=SSH ("/usr/bin/sudo /go/dropbear $DROPBEARPORT",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error($Error);
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");

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





	include "search.php";

	$Header=DesignCode($Header,"$Control (Header)");
	echo $Header;
	

	$Table="SSH";
	$Field="Directive='PermitRootLogin'";
	$DefaultSortBy="TimeStamp";
	$DefaultDirection="DESC";
	include "include/sql.php";

	$X=0;
    $Result = SQL($SQL);
    foreach ($Result as $Row)
    {
		$SSHID=$Row['SSHID'];
		$ID=$Row['SSHID'];

		$IP=$Row['IP'];
		$Directive=$Row['Directive'];
		$Value=$Row['Value'];
		
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