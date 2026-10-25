<?php

include "nav.php";
$Buttons="";
include "title.php";

if ($Action=="R")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 ~ /^R/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Running Processes:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="S")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 ~ /^S/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Sleeping Processes:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Z")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 !~ /Z/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Zombie (Finished, Waiting for Parent):</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="D")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 !~ /D/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Uninterruptible Sleep (Disk I/O):</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="T")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 !~ /T/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Stopped (Suspended):</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="I")
{
	$Error=SSH ("/usr/bin/ps aux | awk '$8 !~ /I/'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Idle Kernel Thread:</u></b><br><pre>$Error</pre>";
}
else
{
	// All running processes 
	$Error=SSH ("/usr/bin/ps aux",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>All Processes:</u></b><br><pre>$Error</pre>";
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;

?>