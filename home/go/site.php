<?php
include "nav.php";
$Buttons="";

include "title.php";

if ($_SESSION['SessionUserID']>1)
{
	include "include/remain.php";
		
	echo "
	<div class=UnderTitle>
	Accounts : $RemainAccounts / $TotalAccounts
	</div>
	";
	
	if ($RemainAccounts<=0)
	{
	exit;
	}
	
}

	$Edit=$_REQUEST['Edit'];
	$CurrentDomain=trim($_REQUEST['CurrentDomain']);
	$CurrentUsername=trim($_REQUEST['CurrentUsername']);
	$Password=ValidatePassword($_REQUEST['Password']);
	$Email=trim($_REQUEST['Email']);
	$PHPVersion=ValidateVersion($_REQUEST['PHPVersion']);
	$PackageID=intval($_REQUEST['PackageID']);
	$DiskSpace=intval($_REQUEST['DiskSpace']);
	$Bandwidth=intval($_REQUEST['Bandwidth']);
	$Inode=intval($_REQUEST['Inode']);
	$FTPNo=intval($_REQUEST['FTPNo']);
	$EmailNo=intval($_REQUEST['EmailNo']);
	$DatabaseNo=intval($_REQUEST['DatabaseNo']);
	$SubDomainNo=intval($_REQUEST['SubDomainNo']);
	$AliasNo=intval($_REQUEST['AliasNo']);
	$AddonNo=intval($_REQUEST['AddonNo']);
	$Skeleton=trim($_REQUEST['Skeleton']); if ($Skeleton=="") {$Skeleton="n";}
	$SSLCertificate=intval($_REQUEST['SSLCertificate']); 
	$SSLRedirect=intval($_REQUEST['SSLRedirect']); 
	$FPM=intval($_REQUEST['FPM']);
	
	$ExpiresOn=substr($_REQUEST['ExpiresOn'],6,4)."-".substr($_REQUEST['ExpiresOn'],3,2)."-".substr($_REQUEST['ExpiresOn'],0,2);
	
	$Domain=ValidateDomain($_REQUEST['Domain']);
	$Username=ValidateUsername($_REQUEST['Username']);

	if (StartsWith($Domain,"www."))
	{
	$Domain = substr($Domain, 4);
	}

if ($Domain!="" and $Email!="")
{

	if ($Username=="")
	{
	$Username=$Domain;
	}

	$UserID=$_SESSION['SessionUserID'];
	$Error=SSH ("/usr/bin/sudo /go/create --domain '$Domain' --username '$Username' --password '$Password' --documentroot '$DocumentRoot' --fullname '$FullName' --mobile '$Mobile' --email '$Email' --packageid '$PackageID' --diskspace '$DiskSpace' --bandwidth '$Bandwidth' --inode '$Inode' --ftpno '$FTPNo' --emailno '$EmailNo' --databaseno '$DatabaseNo' --subdomainno '$SubDomainNo' --aliasno '$AliasNo' --addonno '$AddonNo' --shell '$Shell' --jailedshell '$JailedShell' --timezone '$Timezone' --permission '$Permission' --description '$Description' --phpversion '$PHPVersion' --smtphost '$SMTPHost' --smtpuser '$SMTPUser' --smtppass '$SMTPPass' --smtpport '$SMTPPort' --sslcertificate '$SSLCertificate' --sslredirect '$SSLRedirect' --bot '$Bot' --proxy '$Proxy' --ftpstatus '$FTPStatus' --ftpupload '$FTPUpload' --ftpdownload '$FTPDownload' --ftpdelete '$FTPDelete' --backup '$Backup' --backupstamp '$BackupStamp' --expireson '$ExpiresOn' --domainexpireson '$DomainExpiresOn' --mailttl '$MailTTL' --browsercachettl '$BrowserCacheTTL' --apiignore '$APIIgnore' --userid '$UserID' --owner '$Owner' --timestamp '$TimeStamp' --skeleton '$Skeleton'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("$Error");

	if (stristr($Error,"correct"))
	{
	// Default PHPVersion as Last Website
	SQL("UPDATE Config set PHPVersion='$PHPVersion'");
	
	echo "

	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>

	<tr>	
	
	<th align='center' width='15%'>Type</th>
	<th align='center' width='15%'>Host</th>
	<th align='center' width='70%'>Value</th>
	
	</tr>
	
	</THEAD>
	
	<tr class=Td>

	<td align='center'>A</td>
	<td align='center'>@</td>
	<td align='center'><input type=text value='{$_SERVER['SERVER_ADDR']}' class=InputZ></td>
	
	</table>
	</div>
	
	<br>
	

	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>

	<tr>	
	
	<th align='center' width=15%>Type</th>
	<th align='center' width=15%>Host</th>
	<th align='center' width=70%>Value</th>
	
	</tr>
	
	</THEAD>
	
	<tr class=Td>

	<td align='center'>A</td>
	<td align='center'>*</td>
	<td align='center'><input type=text value='{$_SERVER['SERVER_ADDR']}' class=InputZ></td>
	
	</table>
	</div>
	
	
	<br>

	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>
	<THEAD>

	<tr>	
	
	<TH width=15% align='center'>Type</TH>
	<TH width=15% align='center'>Host</TH>
	<TH width=70% align='center'>Value</TH>
	
	</tr>

	</THEAD>
	
	<tr class=Td>

	<td align='center'>CNAME</td>
	<td align='center'>www.$Domain</td>
	<td align='center'><input type=text value='$Domain' class=InputZ></td>
	
	</table>
	</div>
	
	<br>

	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>
	<THEAD>

	<tr>	
	
	<TH width=15% align='center'>Type</TH>
	<TH width=15% align='center'>Host</TH>
	<TH width=70% align='center'>Value</TH>
	
	</tr>

	</THEAD>
	
	<tr class=Td>

	<td align='center'>CNAME</td>
	<td align='center'>webmail.$Domain</td>
	<td align='center'><input type=text value='$Domain' class=InputZ></td>
	
	</table>
	</div>

	<br>

	<div class=DivTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>
	<THEAD>

	<tr>	
	
	<TH width=15% align='center'>Type</TH>
	<TH width=15% align='center'>Host</TH>
	<TH width=70% align='center'>Value</TH>
	
	</tr>

	</THEAD>
	
	<tr class=Td>

	<td align='center'>CNAME</td>
	<td align='center'>go.$Domain</td>
	<td align='center'><input type=text value='$Domain' class=InputZ></td>
	
	</table>
	</div>
	
	
	";
	}

exit;
}

	$Domain="";
	$Username="";
	$PackageID="";
	$DiskSpace="";
	$Bandwidth="";
	$Inode=0;
	$FTPNo=100;
	$EmailNo=100;
	$DatabaseNo=100;
	$SubDomainNo=100;
	$AliasNo=1;
	$AddonNo=0;
	$SSLCertificateChecked="checked";
	$SSLRedirectChecked="checked";
	$FPMChecked="checked";

	if($Edit==1)
	{
	
	}
	else
	{
	$ExpiresOn=date('Y-m-d', strtotime('+1 year'));
	$ExpiresOn=substr($ExpiresOn,8,2)."/".substr($ExpiresOn,5,2)."/".substr($ExpiresOn,0,4);
	
	$AdminEmailEvent="onfocusout='AdminEmail()'";
	}

	if ($DiskSpace==0) {$DiskSpace="";}	else {$DiskSpace=intval($DiskSpace)/1048576;}
	if ($Bandwidth==0) {$Bandwidth="";}	else {$Bandwidth=intval($Bandwidth)/1048576;}

		$Output=SSH ("/usr/bin/sudo /go/multiphp Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		if (stristr($Output,"|"))
		{
		$OutputArray=explode("|",$Output);
		}
		else
		{
		$OutputArray[]=$Output;
		}
		
		if ($DefaultPHPVersion=="")
		{

			$Result = SQL("select PHPVersion from Config");
			foreach ($Result as $Row)
			{
			$DefaultPHPVersion=$Row['PHPVersion'];
			}
			
			if ($DefaultPHPVersion=="")
			{
			$DefaultPHPVersion=phpversion();
			}
			
			$DefaultPHPVersion=str_replace("php","",$DefaultPHPVersion);
			$DefaultPHPVersion=str_replace(".","",$DefaultPHPVersion);
			$DefaultPHPVersion=substr($DefaultPHPVersion,0,2);
		
		}
		
		foreach ($OutputArray as &$PHPVersion) 
		{
		
			$PHPVersion=trim($PHPVersion);
			$ShowPHPVersion=str_replace("php","",$PHPVersion);
			$ShowPHPVersion=str_replace(".","",$ShowPHPVersion);
			
			
			if (stristr($ShowPHPVersion,$DefaultPHPVersion))
			{
			$SelectPHPVersion.="
			<label class=\"radio-enhanced\">
				<input type='radio' name='PHPVersion' value='$PHPVersion' checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
				</span>
			</label>
			";
			}
			else
			{
			$SelectPHPVersion.="
			<label class=\"radio-enhanced\">
				<input type='radio' name='PHPVersion' value='$PHPVersion'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
				</span>
			</label>
			";
			}
		
		}
	
		$SelectPHPVersion.="
		<label class=\"radio-enhanced\"  >
			<input type='radio' name='PHPVersion' value='Install' onclick=\"Load('php-manager.php')\">
			<span class=\"radio-custom\"></span>
			<span class=\"radio-label-text\">
			{$LNG['InstallAnotherVersion']}
			</span>
		</label>
		";

		$SelectPackage.="<select id='PackageID' name='PackageID' onchange='PackageInfo()' class=Select><option value='0' selected>Default Package</option>";
		$Result = SQL("select * from Package where UserID='{$_SESSION['SessionUserID']}' order by Name");
		foreach ($Result as $Row)
		{
			if ($Row['PackageID']==$PackageID)
			{
			$SelectPackage.="<option value='{$Row['PackageID']}' selected>{$Row['Name']}</option>";
			}
			else
			{
			$SelectPackage.="<option value='{$Row['PackageID']}'>{$Row['Name']}</option>";
			}
		}
		$SelectPackage.="</select>";


	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>