<?php

if ($_REQUEST['DownloadCSR']==1)
{
	include("include/function/function.php");

	$Domain=ValidateDomain($_REQUEST['Domain']);

	$CSR=file_get_contents("/etc/ssl/$Domain/$Domain.csr");

	header("Content-Type: application/octet-stream");
    header("Content-Disposition: attachment; filename=$Domain.csr");

	echo $CSR;

	exit;
}

include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

$Domain=ValidateDomain($_REQUEST['Domain']);

if ($_REQUEST['Certificate']!="")
{
	include "access.php";
	
	$Error=SSH ("chmod 777 /etc/ssl/$Domain && rm -rf /etc/ssl/$Domain/cert.pem && rm -rf /etc/ssl/$Domain/privkey.pem && rm -rf /etc/ssl/$Domain/bundle.pem",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	if (trim($_REQUEST['Certificate'])!="")
	{
	
		$Certificate=$_REQUEST['Certificate'];
		$Error=SSH ("echo '$Certificate' > /etc/ssl/$Domain/cert.pem",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	}
	
	if (trim($_REQUEST['PrivateKey'])!="")
	{
		$PrivateKey=$_REQUEST['PrivateKey'];
		$Error=SSH ("echo '$PrivateKey' > /etc/ssl/$Domain/privkey.pem",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
	if (trim($_REQUEST['Bundle'])!="")
	{
		$Bundle=$_REQUEST['Bundle'];
		$Error=SSH ("echo '$Bundle' > /etc/ssl/$Domain/bundle.pem",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	}

	$Error=SSH ("/usr/bin/sudo /go/openssl $Domain install",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	echo Error("$Error");
	
	exit;
	

}


if ($_REQUEST['Action']=="Delete")
{

	$Error=SSH ("/usr/bin/sudo /go/openssl $Domain delete",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	$Domain="";

}

if ($Domain!="")
{

	$PrivateKey=file_get_contents("/etc/ssl/$Domain/$Domain.key");

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['Domain']}
	<br>
	<input type='text' name='Domain' id='Domain' value='$Domain' maxlength=100 readonly class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['Certificate']}
	<br>
	<textarea type='text' rows=10 name='Certificate' id='Certificate' class='TextArea DivScroll'></textarea>
	</div>

	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['PrivateKey']}
	<br>
	<textarea type='text' rows=10 name='PrivateKey' id='PrivateKey' class='TextArea DivScroll'>$PrivateKey</textarea>
	</div>
	

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['CertificateAuthorityBundle']}
	<br>
	<textarea type='text' rows=10 name='Bundle' id='Bundle' class='TextArea DivScroll'></textarea>
	</div>

	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='{$LNG['Install']}' Class=InputButton>
	</div>

	</form>

	";

}
else
{

    
	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	

	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='50%'>
    <a href=\"javascript:Load('$CurrentFileName?&SortBy=Domain')\">{$LNG['Domain']}</a>
    </TH>



    <TH width='50%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	

	$Table="Site";$Field="Trash=0";
	$DefaultSortBy="Domain";
	$DefaultDirection="ASC";
	include "include/sql.php";


	$X=0;
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {
	$SiteID=$Row['SiteID'];
	$Domain=$Row['Domain'];
		
		if ($X==0)
		{
		echo "<TBODY>";
		}

		if ($X%2==0)
		{
		$TDColor="Td";
		}
		else
		{
		$TDColor="TdB";
		}





    ECHO "
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Email']}'>

    <TD>
    <a href='http://{$Row['Domain']}' target='_blank'>{$Row['Domain']}</a>
    </td>

	";
	
	if (file_exists("/etc/ssl/$Domain/bundle.pem"))
	{
	$SSLInstalled=1;
	}
	else
	{
	$SSLInstalled=0;
	}

	$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);
	
	echo "
	
	<TD align='$OAlign'>
	<a href=\"$CurrentFileName?DownloadCSR=1&Domain={$Row['Domain']}\" class=Action>{$LNG['DownloadCSR']}</a>
	<a href=\"javascript:Load('$CurrentFileName?Domain={$Row['Domain']}&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['InstallSSL']}</a>				
	";

	if ($SSLInstalled==1)
	{
	echo "
	<a href=\"javascript:Load('$CurrentFileName?Action=Delete&Domain={$Row['Domain']}&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Remove SSL</a>
	";
	}
	
	echo "
    </td>
    
	</tr>
	";
	
	$X++;
	}
	
	if ($X!=0)
	{
	echo "</TBODY>";
	}

	echo "
	<TFOOT>



	<th align='$DAlign'>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign'>
	";
			
	include "pages.php";

	echo "
	</th>



	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
	



}





?>