<?php



include "navigator.php";
$Buttons="";
include "title.php";

	$Edit=$_REQUEST['Edit'];
	$CurrentDomain=trim($_REQUEST['CurrentDomain']);
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
	
	$ExpiresOn=substr($_REQUEST['ExpiresOn'],6,4)."-".substr($_REQUEST['ExpiresOn'],3,2)."-".substr($_REQUEST['ExpiresOn'],0,2);
	
	$Domains=trim($_REQUEST['Domains']);
	$Domains=strtolower($Domains);

if ($Domains!="" and $Email!="")
{
	
	$DomainsArray=explode(",",$Domains);

	foreach ($DomainsArray as &$Domain) 
	{
		$Domain = preg_replace("/[^a-zA-Z0-9\-\.]/", "", $Domain);
	
		if ($Domain!="")
		{
			
			if ($Username=="")
			{
			$Username=$Domain;
			}

			$Error=SSH ("/usr/bin/sudo /go/create -d $Domain -u $Username -p $Password -e $Email -v $PHPVersion -i $PackageID -q $DiskSpace -t $Bandwidth -l $Inode -f $FTPNo -m $EmailNo -b $DatabaseNo -o $SubDomainNo -a $AliasNo -n $AddonNo -k $Skeleton -s $SSLCertificate -r $SSLRedirect -g $FPM -x $ExpiresOn -h {$_SESSION['SessionUserID']} --norestart",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			
			echo Error("$Error");

			if (stristr($Error,"correct"))
			{
			echo "

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
			<td align='center'>@</td>
			<td align='center'><input type=text value='{$_SERVER['SERVER_ADDR']}' class=InputZC></td>
			
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
			<td align='center'><input type=text value='$Domain' class=InputZC></td>
			
			</table>
			</div>
			";

			}
		}

	}
	
	$Error=SSH ("/usr/bin/sudo /go/fpm",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

exit;
}

	$Domain="";
	$PackageID="";
	$DiskSpace="";
	$Bandwidth="";
	$Inode="";
	$FTPNo=100;
	$EmailNo=100;
	$DatabaseNo=100;
	$SubDomainNo=100;
	$AliasNo=1;
	$AddonNo=0;
	$SSLCertificateChecked="checked";
	$SSLRedirectChecked="checked";
	$FPMChecked="checked";

	$ExpiresOn=date('Y-m-d', strtotime('+1 year'));
	$ExpiresOn=substr($ExpiresOn,8,2)."/".substr($ExpiresOn,5,2)."/".substr($ExpiresOn,0,4);
	
	if ($DiskSpace==0) {$DiskSpace="";}	else {$DiskSpace=intval($DiskSpace)/1048576;}
	if ($Bandwidth==0) {$Bandwidth="";}	else {$Bandwidth=intval($Bandwidth)/1048576;}
	if ($Inode==0) {$Inode="";}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=SiteID value='$SiteID'>

	<input type=hidden name=CurrentDomain value='$Domain'>
	
	<div class='TitleB {$Dir}TitleB'>
	{$LNG['DomainsInformation']}
	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Domains']}<br>
	<textarea type='text' rows=10 name='Domains' maxlength=1000 placeholder='example1.com\nexample2.com\nexample3.com' class='TextArea DivScroll'></textarea>
	</div>
	
	";
	
	if ($Edit!=1)
	{
	echo "
	<div class='DivInput {$Dir}DivInput'>{$LNG['Password']}<br>
	<input type='text' name='Password' id='Password' pattern='^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$' title='Must contain at least one number, one uppercase letter, one lowercase letter, and be at least 8 characters long' autocomplete='new-password' required maxlength=100 class=InputText>
	</div>

	";
	}
	
	echo "
	<div class='DivInput {$Dir}DivInput'>{$LNG['Email']}<br>
	<input type='text' name='Email' id='Email' value='$Email' maxlength=100 class=InputText>
	</div>
	
	
	<div class='DivInput {$Dir}DivInput'>{$LNG['ExpiresOn']}<br>
	<input type='text' name='ExpiresOn' id='ExpiresOn' value='$ExpiresOn' maxlength=100 class=InputText>
	</div>

	<div id=DivPHPVersion class=DivInput>
	<span class=ColonA>{$LNG['PHPVersion']}</span>
	<br>
	";
	
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
	$DefaultPHPVersion=phpversion();
	$DefaultPHPVersion=preg_replace('/\D/', '', $DefaultPHPVersion);
	$DefaultPHPVersion="php".substr($DefaultPHPVersion,0,2);
	}
	
	foreach ($OutputArray as &$PHPVersion) 
	{
	
		$PHPVersion=trim($PHPVersion);
		$ShowPHPVersion=str_replace("php","",$PHPVersion);
		$ShowPHPVersion=str_replace(".","",$ShowPHPVersion);
		
		if ($DefaultPHPVersion==$PHPVersion)
		{
		echo "
		<label class=Label>PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
			<input type='radio' name='PHPVersion' value='$PHPVersion' checked='checked'>
			<span class='Radio'></span>
		</label>
		";
		}
		else
		{
		echo "
		<label class=Label>PHP ".substr($ShowPHPVersion,0,1).".".substr($ShowPHPVersion,1,1)."
			<input type='radio' name='PHPVersion' value='$PHPVersion'>
			<span class='Radio RadioRadius'></span>
		</label>
		";
		}
	}
	
	
		echo "
		<label class=Label onclick=\"Load('php-manager.php')\">{$LNG['InstallAnotherVersion']}
			<input type='radio' name='PHPVersion' value='$PHPVersion'>
			<span class='Radio RadioRadius'></span>
		</label>
		";
	
	echo "
	</div>

	<div <div class='TitleB {$Dir}TitleB'>
	&nbsp;{$LNG['PackageInformation']}
	</div>
	

	<div class='DivInput {$Dir}DivInput'>{$LNG['PackageName']}<br>

		<select id='PackageID' name='PackageID' onchange='PackageInfo()' class=Select>
		<option value='0' selected>Default Package</option>
		";
		
		$Result = SQL("select * from Package where UserID='{$_SESSION['SessionUserID']}' order by Name");
		foreach ($Result as $Row)
		{
			if ($Row['PackageID']==$PackageID)
			{
			echo "<option value='{$Row['PackageID']}' selected>{$Row['Name']}</option>";
			}
			else
			{
			echo "<option value='{$Row['PackageID']}'>{$Row['Name']}</option>";
			}
		}
		
		echo "
		</select>
	
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['DiskSpace']}<br>
	<input type='Text' name='DiskSpace' id='DiskSpace' value='$DiskSpace' placeholder='Unlimited' maxlength=100 class=InputText> MB
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['BandwidthLimit']}<br>
	<input type='Text' name='Bandwidth' id='Bandwidth' value='$Bandwidth' placeholder='Unlimited' maxlength=100 class=InputText> MB
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['InodeLimit']}<br>
	<input type='Text' name='Inode' id='Inode' value='$Bandwidth' placeholder='Unlimited' maxlength=10 class=InputText> Files
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxFTPAccounts']}<br>
	<input type='Text' name='FTPNo' id='FTPNo' value='$FTPNo' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxEmailAccounts']}<br>
	<input type='Text' name='EmailNo' id='EmailNo' value='$EmailNo' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxSQLDatabases']}<br>
	<input type='Text' name='DatabaseNo' id='DatabaseNo' value='$DatabaseNo' maxlength=100 class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxSubDomains']}<br>
	<input type='Text' name='SubDomainNo' id='SubDomainNo' value='$SubDomainNo' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxAliasDomains']}<br>
	<input type='Text' name='AliasNo' id='AliasNo' value='$AliasNo' maxlength=100 class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	{$LNG['MaxAddonDomains']}<br>
	<input type='Text' name='AddonNo' id='AddonNo' value='$AddonNo' maxlength=100 class=InputText>
	</div>
	";
	
	if ($Edit!=1)
	{
	Echo "
	<div class=DivInputB>
	
		<label class=Label>{$LNG['CopySkeletonFilesToHome']}
			<input type='checkbox' name='Skeleton' id='Skeleton' value='y'>
			<span class='Checkbox'></span>
		</label>
	 
	</div>
	";
	}
	
	Echo "
	<div class=DivInputB>
	
		<label class=Label>{$LNG['InstallAnSSLCertificate']}
			<input type='checkbox' name='SSLCertificate' id='SSLCertificate' value='1' $SSLCertificateChecked>
			<span class='Checkbox'></span>
		</label>
		
	</div>

	<div class=DivInputB>
	
		<label class=Label>{$LNG['RedirectHTTPToHTTPS']}
			<input type='checkbox' name='SSLRedirect' id='SSLRedirect' value='1' $SSLRedirectChecked>
			<span class='Checkbox'></span>
		</label>
		
	</div>

	<div class=DivInputB>
	
		<label class=Label>{$LNG['EnablePHPFPM']}
			<input type='checkbox' name='FPM' id='FPM' value='y' $FPMChecked>
			<span class='Checkbox'></span>
		</label>
	
	</div>

	<div id=DivSubmit class=DivSubmit>
	";
	
		if ($Edit==1)
		{
		Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
		}
		else
		{
		Echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
		}
		
	Echo "
	</div>

</form>
";
?>