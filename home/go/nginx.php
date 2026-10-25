<?php
include "navigator.php";
$Buttons="";
include "title.php";

if ($_REQUEST['Action']=="RestoreNGINXConfiguration")
{

	$OS=trim(file_get_contents("/usr/local/goadmio/linux/os.db"));
	$Error=SSH ("yes|cp -rf /etc/nginx/nginx.bak /etc/nginx/nginx.conf && /go/web",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo Error ("Restore default, Please wait...");
	
exit;
}

		$index = SSH ("/usr/bin/sudo /go/directoryindex Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
						
		$keepalive_timeout = SSH ("/usr/bin/sudo /go/keepalive_timeout Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		if (trim($keepalive_timeout)=="")
		{
		$keepalive_timeout=65;
		SSH ("/usr/bin/sudo /go/keepalive_timeout $keepalive_timeout",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}

		$gzip = SSH ("/usr/bin/sudo /go/gzip Return",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		if (trim($gzip)=="")
		{
		// 
		$gzip="on";
		SSH ("/usr/bin/sudo /go/gzip $gzip",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}
		
		Echo "
		<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
		<input type=hidden name=Edit value='$Edit'>

	
		<div class='DivInput {$Dir}DivInput'>keepalive_timeout<br>	
		<input type='text' value='$keepalive_timeout' id='keepalive_timeout' onchange=\"NGINX('/go/keepalive_timeout',encodeURI(document.getElementById('keepalive_timeout').value),'keepalive_timeout')\" class=InputText>
		</div>
	
		<div class='DivInput {$Dir}DivInput'>gzip<br>
		<input type='text' value='$gzip' id='gzip' onchange=\"NGINX('/go/gzip',encodeURI(document.getElementById('gzip').value),'gzip')\" class=InputText>
		</div>
		
		</form>
	

";


?>