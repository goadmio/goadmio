<?php
include "nav.php";
$Buttons="

	<a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?ControlID=$ControlID&Action=Google')\" class='ButtonB {$Dir}ButtonB'>Google {$LNG['PublicDNS']}</a>
	<a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?ControlID=$ControlID&Action=OpenDNS')\" class='ButtonB {$Dir}ButtonB'>OpenDNS {$LNG['PublicDNS']}</a>
	<a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?ControlID=$ControlID&Action=Quad9')\" class='ButtonB {$Dir}ButtonB'>Quad9 {$LNG['PublicDNS']}</a>
	<a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?ControlID=$ControlID&Action=Cloudflare')\" class='ButtonB {$Dir}ButtonB'>Cloudflare {$LNG['PublicDNS']}</a>
	<a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?ControlID=$ControlID&Action=Default')\" class='ButtonB {$Dir}ButtonB'>{$LNG['DataCenterDNS']}</a>
";
include "title.php";


$PrimaryIP=ValidateIP($_REQUEST['PrimaryIP']);
$SecondaryIP=ValidateIP($_REQUEST['SecondaryIP']);
$TertiaryIP=ValidateIP($_REQUEST['TertiaryIP']);
$QuaternaryIP=ValidateIP($_REQUEST['QuaternaryIP']);

if ($Action=="Default")
{
$Error=SSH ("cp /etc/resolv.bak /etc/resolv.conf",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("Your resolvers have been successfully configured.");		
}

if ($Action=="Google")
{
$Error=SSH ("/usr/bin/sudo /go/resolver",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("$Error");

echo "<table cellpadding=0 cellspacing=0 width='100%'><td height=9 width='100%'></td></table>";
}

if ($Action=="OpenDNS")
{
$Error=SSH ("/usr/bin/sudo /go/resolver OpenDNS",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("$Error");

echo "<table cellpadding=0 cellspacing=0 width='100%'><td height=9 width='100%'></td></table>";
}


if ($Action=="Quad9")
{
$Error=SSH ("/usr/bin/sudo /go/resolver Quad9",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("$Error");

echo "<table cellpadding=0 cellspacing=0 width='100%'><td height=9 width='100%'></td></table>";
}

if ($Action=="Cloudflare")
{
$Error=SSH ("/usr/bin/sudo /go/resolver Cloudflare",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
echo Error("$Error");

echo "<table cellpadding=0 cellspacing=0 width='100%'><td height=9 width='100%'></td></table>";
}



if ($PrimaryIP!="")
{

	$Error=SSH ("/usr/bin/sudo /go/resolver $PrimaryIP $SecondaryIP $TertiaryIP $QuaternaryIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");
}
	$String = file_get_contents("/etc/resolv.conf");
    $Lines = explode("\n", $String);

	foreach ($Lines as $Line) 
	{
		$Line = trim($Line);
		
		if (strpos($Line, 'nameserver') === 0) 
		{
			$Parts = preg_split('/\s+/', $Line);
			
			if (isset($Parts[1])) 
			{
			$ResolverArray[] = $Parts[1];
			}
		}
	}

	$PrimaryIP=$ResolverArray[0];
	$SecondaryIP=$ResolverArray[1];
	$TertiaryIP=$ResolverArray[2];
	$QuaternaryIP=$ResolverArray[3];

	if ($PrimaryIP!="")
	{
		$PrimaryInfo=SSH ("/usr/bin/sudo /go/resolver $PrimaryIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$PrimaryArray=explode("|",$PrimaryInfo);
	}
	
	if ($SecondaryIP!="")
	{
		$SecondaryInfo=SSH ("/usr/bin/sudo /go/resolver $SecondaryIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$SecondaryArray=explode("|",$SecondaryInfo);
	}
	
	if ($TertiaryIP!="")
	{
		$TertiaryInfo=SSH ("/usr/bin/sudo /go/resolver $TertiaryIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$TertiaryArray=explode("|",$TertiaryInfo);
	}
	
	
	if ($QuaternaryIP!="")
	{
		$QuaternaryInfo=SSH ("/usr/bin/sudo /go/resolver $QuaternaryIP",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$QuaternaryArray=explode("|",$QuaternaryInfo);
	}
	
	
	if ($PrimaryArray[0]!="") {$PrimaryFlag="<img src='image/flag/24x24/".strtolower($PrimaryArray[0]).".png' title='{$PrimaryArray[0]}' style='vertical-align:middle;padding:5px'> {$PrimaryArray[1]}";}
	if ($SecondaryArray[0]!="") {$SecondaryFlag="<img src='image/flag/24x24/".strtolower($SecondaryArray[0]).".png' title='{$SecondaryArray[0]}' style='vertical-align:middle;padding:5px'> {$SecondaryArray[1]}";}
	if ($TertiaryArray[0]!="") {$TertiaryFlag="<img src='image/flag/24x24/".strtolower($TertiaryArray[0]).".png' title='{$TertiaryArray[0]}' style='vertical-align:middle;padding:5px'> {$TertiaryArray[1]}";}
	if ($QuaternaryArray[0]!="") {$QuaternaryFlag="<img src='image/flag/24x24/".strtolower($QuaternaryArray[0]).".png' title='{$QuaternaryArray[0]}' style='vertical-align:middle;padding:5px'> {$QuaternaryArray[1]}";}

	$PrimaryFlag=str_ireplace("Contabo GmbH","Blackhost",$PrimaryFlag);
	$PrimaryFlag=str_ireplace("Contabo","Blackhost",$PrimaryFlag);
	
	$SecondaryFlag=str_ireplace("Contabo GmbH","Blackhost",$SecondaryFlag);
	$SecondaryFlag=str_ireplace("Contabo","Blackhost",$SecondaryFlag);
	
	$TertiaryFlag=str_ireplace("Contabo GmbH","Blackhost",$TertiaryFlag);
	$TertiaryFlag=str_ireplace("Contabo","Blackhost",$TertiaryFlag);
	
	$QuaternaryFlag=str_ireplace("Contabo GmbH","Blackhost",$QuaternaryFlag);
	$QuaternaryFlag=str_ireplace("Contabo","Blackhost",$QuaternaryFlag);
	
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;


?>