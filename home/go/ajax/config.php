<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";

$Result = SQL("select * from Config");
foreach ($Result as $Row)
{	
	$IPv4=$Row['IPv4'];
	$IPv6=$Row['IPv6'];
}

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "Sorry, You Are Not Allowed to Access This Page";
	exit;
}

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid GoAdmio Path";
	exit;
}

// Input ID
$ID=$_REQUEST['ID'];
$Value=$_REQUEST['Value'];
$Value=str_replace('"','',$Value);
$Value=str_replace("'","",$Value);

if ($ID=="MemoryLimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<5) {$Value="5";}
	if ($Value>100) {$Value="100";}
	
	SQL("UPDATE Config set MemoryLimit='$Value'");
	
	SSH ("/usr/bin/sudo /go/slice",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}

if ($ID=="CPULimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<5) {$Value="5";}
	if ($Value>100) {$Value="100";}
	
	SQL("UPDATE Config set CPULimit='$Value'");
	
	SSH ("/usr/bin/sudo /go/slice",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="MAX_USER_CONNECTIONS" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="0";}
	if ($Value>155) {$Value="0";}
	
	SQL("UPDATE MariaDB set MAX_USER_CONNECTIONS='$Value' where MariaDBID='1'");
	
	SSH ("/usr/bin/sudo /go/slice",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="MAX_QUESTIONS" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="0";}
	if ($Value>100000) {$Value="0";}
	
	SQL("UPDATE MariaDB set MAX_QUESTIONS='$Value' where MariaDBID='1'");
	
	SSH ("/usr/bin/sudo /go/slice",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="MAX_UPDATES" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="0";}
	if ($Value>10000) {$Value="0";}
	
	SQL("UPDATE MariaDB set MAX_UPDATES='$Value' where MariaDBID='1'");
	
	SSH ("/usr/bin/sudo /go/slice",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="MyNetworks")
{

	if ($DemoPassword!="")
	{
	$Value="";
	}
	else
	{
	$Value=trim($Value);
	}
	
	SQL("UPDATE Config set MyNetworks='$Value'");
	SSH ("postconf -e 'mynetworks = 127.0.0.0/8 [::1]/128 $IPv4 $Value' && systemctl restart postfix",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			
}	

if ($ID=="ServerLimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="1000";}
	if ($Value>100000000) {$Value="100000000";}
	
	SQL("UPDATE Config set ServerLimit='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}	

if ($ID=="DomainLimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="250";}
	if ($Value>100000000) {$Value="100000000";}
	
	SQL("UPDATE Config set DomainLimit='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="ExternalLimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="500";}
	if ($Value>100000000) {$Value="100000000";}
	
	SQL("UPDATE Config set ExternalLimit='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="UserLimit" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="100";}
	if ($Value>100000000) {$Value="1000000";}
	
	SQL("UPDATE Config set UserLimit='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="SMTPDelay" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="0";}
	if ($Value>60) {$Value="60";}
	
	SQL("UPDATE Config set SMTPDelay='$Value'");
	
	SSH ("postconf -e 'default_destination_rate_delay = {$Value}s' && systemctl restart postfix",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
}

if ($ID=="QueueNo" and $Value!="")
{
	$Value=intval($Value);
	if ($Value<0) {$Value="0";}
	if ($Value>1000000) {$Value="1000000";}
	
	SQL("UPDATE Config set QueueNo='$Value'");
	
}


if ($ID=="CloudflareAccountID")
{
SQL("UPDATE Config SET CloudflareAccountID='$Value'");
}

if ($ID=="CloudflareAPIToken")
{
SQL("UPDATE Config SET CloudflareAPIToken='$Value'");
}



if ($ID=="ResellerclubIP")
{
SQL("UPDATE Config SET ResellerclubIP='$Value'");
}

if ($ID=="ResellerclubUserID")
{
SQL("UPDATE Config SET ResellerclubUserID='$Value'");
}

if ($ID=="ResellerclubAPIKey")
{
SQL("UPDATE Config SET ResellerclubAPIKey='$Value'");
}

if ($ID=="DynadotIP")
{
SQL("UPDATE Config SET DynadotIP='$Value'");
}

if ($ID=="DynadotAPIKey")
{
SQL("UPDATE Config SET DynadotAPIKey='$Value'");
}


if ($ID=="SpaceshipAPIKey")
{
SQL("UPDATE Config SET SpaceshipAPIKey='$Value'");
}

if ($ID=="SpaceshipAPISecret")
{
SQL("UPDATE Config SET SpaceshipAPISecret='$Value'");
}


// Brevo 
if ($ID=="BrevoAPIKey")
{
	$Value=trim($Value);

	SQL("update Config set BrevoAPIKey='$Value'");

	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/brevo config'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


if ($ID=="ForwardEmailAPIToken")
{
	$Value=trim($Value);

	SQL("update Config set ForwardEmailAPIToken='$Value'");

}


if ($ID=="RoundcubeSMTPHost")
{

	$Value=trim($Value);
	
	SQL("update Config set RoundcubeSMTPHost='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/roundcubeglobalsmtp'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}

if ($ID=="RoundcubeSMTPPort")
{

	$Value=intval($Value);

	if ($Value==0 or $Value>65535 or $Value<0)
	{
	$Value="587";
	}
	
	SQL("update Config set RoundcubeSMTPPort='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/roundcubeglobalsmtp'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}

if ($ID=="RoundcubeSMTPUser")
{

	$Value=trim($Value);

	SQL("update Config set RoundcubeSMTPUser='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/roundcubeglobalsmtp'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}

if ($ID=="RoundcubeSMTPPass")
{

	$Value=trim($Value);

	SQL("update Config set RoundcubeSMTPPass='$Value'");
	
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/roundcubeglobalsmtp'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


echo $Value;

?>