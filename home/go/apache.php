<?php

include "nav.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=RestoreApacheConfiguration&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
include "title.php";

	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
		$ApacheLogRotate=$Row['ApacheLogRotate'];
		if ($ApacheLogRotate==1)
		{
		$CheckedLogRotateDaily="checked";
		}
		else
		{
		$CheckedLogRotateWeekly="checked";
		}
		
	}
		

if ($_REQUEST['Action']=="RestoreApacheConfiguration")
{
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/directoryindex --noreload && /go/maxkeepaliverequests --noreload && /go/keepalivetimeout --noreload && /go/keepalive'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error ("Restore default, Please wait...");
	
exit;
}

$OS=trim(file_get_contents("/usr/local/goadmio/linux/os.db"));

if ($OS=="Red Hat" OR $OS=="CentOS" OR $OS=="Fedora" OR $OS=="AlmaLinux" OR $OS=="Rocky" OR $OS=="Arch")
{
	$APACHE="/etc/httpd/conf/httpd.conf";
}
elseif ($OS=="Debian" OR $OS=="Ubuntu")
{
	$APACHE="/etc/apache2/apache2.conf";
}

if (file_exists($APACHE)) 
{
	$CONF=file_get_contents($APACHE);

	if (preg_match_all('/^\s*DirectoryIndex\s+(.+)$/m', $CONF, $Matches)) 
	{
		foreach ($Matches[1] as $Index => $Value) 
		{
			$Files = preg_split('/\s+/',trim($Value));
		}

		$DirectoryIndex=implode(' ', $Files);
	}
		
	if (trim($DirectoryIndex)=="")
	{
	
		if (file_exists("/etc/apache2/mods-enabled/dir.conf")) 
		{
		
			$DIRCONF=file_get_contents("/etc/apache2/mods-enabled/dir.conf");
		
			if (preg_match_all('/^\s*DirectoryIndex\s+(.+)$/m', $DIRCONF, $Matches)) 
			{
				foreach ($Matches[1] as $Index => $Value) 
				{
					$Files = preg_split('/\s+/',trim($Value));
				}

				$DirectoryIndex=implode(' ', $Files);
			}
		
		}
		
	}

	if (preg_match('/^\s*KeepAlive\s+(\S+)/m',$CONF,$Matches)) 
	{
	$KeepAlive=$Matches[1];
	}
	
	if (trim($KeepAlive)=="")
	{
	$KeepAlive="On";
	SSH ("/usr/bin/sudo /go/keepalive $KeepAlive",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
	
	if (preg_match('/^\s*KeepAliveTimeout\s+(\S+)/m',$CONF,$Matches)) 
	{
	$KeepAliveTimeout=$Matches[1];
	}
	
	if (trim($KeepAliveTimeout)=="")
	{
	$KeepAliveTimeout=5;
	SSH ("/usr/bin/sudo /go/keepalivetimeout $KeepAliveTimeout",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
	if (preg_match('/^\s*MaxKeepAliveRequests\s+(\S+)/m',$CONF,$Matches)) 
	{
	$MaxKeepAliveRequests=$Matches[1];
	}
	
	if (trim($MaxKeepAliveRequests)=="")
	{
	$MaxKeepAliveRequests=100;
	SSH ("/usr/bin/sudo /go/maxkeepaliverequests $MaxKeepAliveRequests",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}	
else
{
echo "Cannot access $APACHE: No such file.";
exit;
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;

?>