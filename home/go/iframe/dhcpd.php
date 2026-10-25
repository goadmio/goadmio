<?php
session_start();

include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

$ServerIP=$_REQUEST['ServerIP'];

header("Content-Type: text/plain");
header("Content-Disposition: attachment; filename=dhcpd.conf");
header("Pragma: no-cache");
header("Expires: 0");

$Sql = "select * from Server where ServerIP='$ServerIP'";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
$Subnet=$Row['Subnet'];
$CIDR=$Row['CIDR'];
}

$IPArray=explode(".",$Subnet);
$A=$IPArray[0];
$B=$IPArray[1];
$C=$IPArray[2];
$D=$IPArray[3];
$Gateway="$A.$B.$C.".($D+1);

if ($CIDR=="32") {$Netmask="255.255.255.255";}
if ($CIDR=="31") {$Netmask="255.255.255.254";}
if ($CIDR=="30") {$Netmask="255.255.255.252";}
if ($CIDR=="29") {$Netmask="255.255.255.248";}
if ($CIDR=="28") {$Netmask="255.255.255.240";}
if ($CIDR=="27") {$Netmask="255.255.255.224";}
if ($CIDR=="26") {$Netmask="255.255.255.192";}
if ($CIDR=="25") {$Netmask="255.255.255.128";}
if ($CIDR=="24") {$Netmask="255.255.255.0";}
if ($CIDR=="23") {$Netmask="255.255.254.0";}
if ($CIDR=="22") {$Netmask="255.255.252.0";}
if ($CIDR=="21") {$Netmask="255.255.248.0";}
if ($CIDR=="20") {$Netmask="255.255.240.0";}


echo "subnet $Subnet netmask $Netmask {\n";
echo "authoritative;\n";
echo "default-lease-time 21600000;\n";
echo "max-lease-time 432000000;\n";
echo "}\n";
echo "\n";
echo "\n";

$Sql = "select * from VPS where ServerIP='$ServerIP' order by ID";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
$ID=$Row['ID'];
$IP=$Row['IP'];
$MAC=$Row['MAC'];


	echo "host VM{$ID} {\n";
	echo "hardware ethernet $MAC;\n";
	echo "option routers $Gateway;\n";
	echo "option subnet-mask $Netmask;\n";
	echo "fixed-address $IP;\n";
	echo "}\n";
	echo "\n";

	
}


?>