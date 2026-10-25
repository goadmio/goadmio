<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


$Domain=ValidateDomain($_REQUEST['Domain']);


if ($Domain!="")
{

	echo "
	<div class=DivInfo>
	<h1>$Domain</h1>	
	</div>
	";

	$SPF=SSH ("dig +noall +answer -t txt $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	$Valid=0;
	if (stristr($SPF,"v=spf1") and stristr($SPF,"ip4:{$_SERVER['SERVER_ADDR']}") and (stristr($SPF,"-all") or stristr($SPF,"~all")))
	{
	$Valid=1;
	}

	if ($Valid==0)
	{
	
	echo "
	<div class=DivInfo>
	<h1>We could not find a SPF record</h1>	
	<b>Please Add TXT Record:</b>
	</div>
	
	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
	<th width=15% align='center'>Type</th>
	<th width=15% align='center'>Host</th>
	<th width=70% align='center'>TXT Value</th>

	</tr>

	</THEAD>

	<tr>

	<td align='center' class=Td>TXT</td>
	<td align='center' class=Td>@</td>
	<td align='center' class=Td><input type=text value='v=spf1 +a +mx ip4:{$_SERVER['SERVER_ADDR']} ~all' class=InputZC></td>
	
	</table>
	</div>
	";
	}
	else
	{
	echo "
	<div class=DivInfo>
	<img src='image/true.svg' style='width:32px;height:32px;vertical-align:middle;padding:5px'> SPF PASS with IP {$_SERVER['SERVER_ADDR']}.
	</div>
	";
	}
	
	
	// DKIM

	$DKIM=SSH ("dig +noall +answer -t txt dkim._domainkey.$Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$DKIMArray=explode("p=",$DKIM);	
	$DKIMCode=$DKIMArray[1];
	$DKIMCode=str_replace(' ','',$DKIMCode);
	$DKIMCode=str_replace('"','',$DKIMCode);

	$DNS=SSH ("/usr/bin/sudo /go/dkim $Domain dns",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	$DNSArray=explode("p=",$DNS);	
	$DNSCode=$DNSArray[1];
	$DNSCode=str_replace(' ','',$DNSCode);
	$DNSCode=str_replace('"','',$DNSCode);


	$Valid=0;
	if (stristr($DKIM,"v=DKIM1") and stristr($DKIM,"k=rsa"))
	{

		if ($DNSCode=="" and $DKIMCode!="")
		{
		$Valid=-1;
		
		// Generate new DKIM record
		if ($DNSCode=="")
		{
		echo "$DNSCode | Generate new DKIM record<br>";
		SSH ("/usr/bin/sudo /go/dkim $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}

		// Get DKIM record
		$DNS=SSH ("/usr/bin/sudo /go/dkim $Domain dns",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		}
		elseif ($DKIMCode==$DNSCode)
		{
		$Valid=1;
		}
		else
		{
		# DNS not match
		$Valid=-1;
		}
	}



	if ($Valid==0)
	{
		// Generate new DKIM record
		if (trim($DNSCode)=="")
		{
		echo "$DNSCode | Generate new DKIM record<br>";
		SSH ("/usr/bin/sudo /go/dkim $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}

		// Get DKIM record
		$DNS=SSH ("/usr/bin/sudo /go/dkim $Domain dns",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		echo "
		<div class=DivInfo>
		<h1>We could not find a DKIM record</h1>
		<b>Please Add TXT Record:</b>
		</div>
		
		<div class=DivTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th width=15% align='center'>Type</th>
		<th width=15% align='center'>Host</th>
		<th width=70% align='center'>TXT Value</th>
		
		</tr>
		
		</THEAD>
		
		<tr>

		<td align='center' class=Td>TXT</td>
		<td align='center' class=Td>dkim._domainkey.$Domain</td>
		<td align='center' class=Td><input type=text value='$DNS' class=InputZC></td>
		
		</table>
		";
	}
	elseif ($Valid==-1)
	{

	echo "
	<div class=DivInfo>
	<h1>DKIM record already exists but is not valid</h1>

	<b>Please UPDATE TXT Record:</b>
	</div>
	
	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
	<th width=15% align='center'>Type</th>
	<th width=15% align='center'>Host</th>
	<th width=70% align='center'>TXT Value</th>

	</tr>

	</THEAD>

	<tr>

	<td align='center' class=Td>TXT</td>
	<td align='center' class=Td>dkim._domainkey.$Domain</td>
	<td align='center' class=Td><input type=text value='$DNS' class=InputZC></td>
	
	</table>
	</div>
	";
	}
	else
	{
	echo "
	<div class=DivInfo>
	<img src='image/true.svg' style='width:32px;height:32px;vertical-align:middle;padding:5px'> DKIM PASS with domain $Domain.
	</div>
	";
	}
	
	
}


?>