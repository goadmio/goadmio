<?php

include "nav.php";
$Buttons="";
include "title.php";

$NS1=$_REQUEST['NS1'];
$NS2=$_REQUEST['NS2'];
$NS3=$_REQUEST['NS3'];
$NS4=$_REQUEST['NS4'];


	if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{

		Echo "
		Sorry, You Are Not Allowed to Access This Page
		";

		exit;
	}


if ($_REQUEST['NS1']!="")
{
	$Error=SSH ("/usr/bin/sudo /go/nameservers $NS1 $NS2 $NS3 $NS4",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$Error=Error($Error);
}

	$Nameservers=SSH ("/usr/bin/sudo /go/nameservers return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$NameserversArray=explode("|",$Nameservers);
	
	$NS1=$NameserversArray[0];
	$NS2=$NameserversArray[1];
	$NS3=$NameserversArray[2];
	$NS4=$NameserversArray[3];

	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>