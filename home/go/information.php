<?php

include "nav.php";
$Buttons="";
include "title.php";

if ($Action=="Kernel")
{
	$Error=SSH ("inxi -S -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Kernel and Distribution Information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Model")
{
	$Error=SSH ("inxi -M -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Laptop or PC Model Information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="CPU")
{
	$Error=SSH ("inxi -C -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>CPU and CPU Speed Information:</u></b><br><pre>$Error</pre>";
	
	$Error=SSH ("lscpu",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	
	$ErrorArray=explode("Flags:",$Error);
	$Error=$ErrorArray[0];
	
	$Error=htmlspecialchars($Error);
	$Error="<b><u>CPU hardware information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Graphic")
{
	$Error=SSH ("inxi -G -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Graphic Card Information:</u></b><br><pre>$Error</pre>";
	
}
elseif ($Action=="Audio")
{
	$Error=SSH ("inxi -A -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Audio/Sound Card Information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Network")
{
	$Error=SSH ("inxi -N -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Network Card Information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Harddisk")
{
	$Error=SSH ("inxi -D -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Hard Disk Information:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Partition")
{
	$Error=SSH ("inxi -P -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Hard Disk Partition Details:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="TotalMemoryUsage")
{
	$Error=SSH ("inxi -I -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Monitor Linux Processes Memory Usage:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="TopMemoryUsage")
{
	$Error=SSH ("inxi -t m -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Monitoring (TOP 5) Processes by Memory Usage:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="TopCPUUsage")
{
	$Error=SSH ("inxi -t c -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Monitoring (TOP 5) Processes by CPU Usage:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="CPUTemperature")
{
	$Error=SSH ("inxi -s -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Monitor Linux CPU Temperature and Fan Speed:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="Weather")
{
	$Error=SSH ("inxi -w -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Find Weather Report in Linux:</u></b><br><pre>$Error</pre>";
}				
elseif ($Action=="NetworkInterfaces")
{
	$Error=SSH ("inxi -Nni -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Monitor Linux Network Interfaces:</u></b><br><pre>$Error</pre>";
}
elseif ($Action=="RAID")
{
	$Error=SSH ("inxi -R -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>Display RAID Details:</u></b><br><pre>$Error</pre>";
}
else
{
	$Error=SSH ("inxi -c 0",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);
	$Error="<b><u>System Information:</u></b><br><pre>$Error</pre>";
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;

?>