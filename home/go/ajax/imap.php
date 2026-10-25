<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 


include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";





if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "Sorry, You Are Not Allowed to Access This Page";
	exit;
}

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$IMAPID=$_REQUEST['IMAPID'];
$Value=$_REQUEST['Value'];

if ($IMAPID=="IMAPHostname")
{

	$Value=trim($Value);


	if( preg_match( "/^(?:[-A-Za-z0-9]+\.)+[A-Za-z]{2,12}$/", $Value))
	{
	
	}
	elseif (filter_var($Value, FILTER_VALIDATE_IP)) 
	{
	
	}
	elseif (strtolower($Value)=="domain" or strtolower($Value)=="{domain}" or strtolower($Value)=="[domain]" or strtolower($Value)=="\$domain")
	{
	$Value="[Domain]";
	}
	else
	{
	$Value="localhost";
	}
	
	
	SQL("update Config set IMAPHostname='$Value' where ConfigID=1");

	echo $Value;

}

if ($IMAPID=="IMAPPort")
{

	$Value=intval($Value);

	if($Value==0 or $Value>65535 or $Value<0)
	{
	$Value="143";
	}
	
	SQL("update Config set IMAPPort='$Value' where ConfigID=1");

	if ($Value=="993")
	{
	SQL("update Config set IMAPSecure='SSL' where ConfigID=1");
	}

	echo $Value;

}

if ($IMAPID=="IMAPSecure")
{

	$Value=trim($Value);

	SQL("update Config set IMAPSecure='$Value' where ConfigID=1");

	if ($Value=="None")
	{
	SQL("update Config set IMAPPort='143' where IMAPPort='993' and ConfigID=1");
	}

	if ($Value=="SSL")
	{
	SQL("update Config set IMAPPort='993' where IMAPPort='143' and ConfigID=1");
	}

	if ($Value=="TLS")
	{
	SQL("update Config set IMAPPort='143' where IMAPPort='993' and ConfigID=1");
	}

	echo $Value;

}


if ($IMAPID=="IMAPShortLogin")
{

	$Value=trim($Value);

	if ($Value=="1" or strtolower($Value)=="on" or strtolower($Value)=="true")
	{
	$Value="On";
	}
	else
	{
	$Value="Off";
	}

	SQL("update Config set IMAPShortLogin='$Value' where ConfigID=1");

	echo $Value;

}

?>