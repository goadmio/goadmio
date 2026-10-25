<?php
include "navigator.php";

	if ($_REQUEST['EnableIPv6']==1)
	{
	SSH ("/usr/bin/sudo /go/ipv6",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

	if ($_REQUEST['DisableIPv6']==1)
	{
	SSH ("/usr/bin/sudo /go/ipv6 --disable",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

	$ServerInfo=SSH ("/usr/bin/sudo /go/serverinfo",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],60);
	$ServerInfoArray=explode("|",$ServerInfo);
	$ServerDiskSpace=$ServerInfoArray[0];
	$ServerDiskUsed=$ServerInfoArray[1];
	$ServerDiskPercent=$ServerInfoArray[2];
	$Memory=$ServerInfoArray[3];
	$MemoryUsed=$ServerInfoArray[4];
	$MemoryPercent=$ServerInfoArray[5];
	$Swap=$ServerInfoArray[6];
	$Swappiness=$ServerInfoArray[7];
	$Cores=$ServerInfoArray[8];
	$Threads=$ServerInfoArray[9];
	$CoresUsed=$ServerInfoArray[10];
	$CoresPercent=$ServerInfoArray[11];
	$IPv4=$ServerInfoArray[12];
	$IPv6=$ServerInfoArray[13];
	$Hostname=$ServerInfoArray[14];
	$OS=trim($ServerInfoArray[15]);
	$OSVersion=trim($ServerInfoArray[16]);
	$WS=trim($ServerInfoArray[17]);
	$WSVersion=trim($ServerInfoArray[18]);
	$Machine=trim($ServerInfoArray[19]);
	$MariaDBVersion=$ServerInfoArray[20];
	$PostgreSQLVersion=$ServerInfoArray[21];
	$SQLiteVersion=$ServerInfoArray[22];
	$Architecture=$ServerInfoArray[23];
	$KernelVersion=trim($ServerInfoArray[24]);
	$Processor=trim($ServerInfoArray[25]);
	$StorageType=trim($ServerInfoArray[26]);
	$RAMType=trim($ServerInfoArray[27]);
	
$Buttons="";

$Category=$_REQUEST['Category'];
$ControlMenu=$_REQUEST['ControlMenu'];



if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	$Latest=0;
	if ($_SESSION['SessionLatest']!=1)
	{
	$_SESSION['SessionLatest']=1;
	$Latest=intval(Content("https://download.goadmio.com/home/go/update/latest.txt",3));
	}

	if ($Version!=$Latest and $Latest!=0)
	{
		$NewVersion=Version($Latest);
		if (stristr($NewVersion,"."))
		{
		echo "<div class=NavigatorInfo id=Update><img src='theme/{$_SESSION['SessionTheme']}/image/update.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>{$LNG['ANewVersion']} $NewVersion {$LNG['IsAvailable']}. <a href='javascript:Update();' class=Action>{$LNG['UpdateNow']}</a></div>";
		}
	}
	elseif ($_SESSION['SessionTIP']!=1)
	{
		$_SESSION['SessionTIP']=1;

		$TIP=SSH ("/usr/bin/sudo /go/tip",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		$TIP=str_replace("\n","",$TIP);
		$TIP=str_replace("\r","",$TIP);
		
		if ($TIP!="")
		{
		
			if (stristr($TIP,"Hostname is not valid"))
			{
			$TIP=Lang($TIP).". <a href=\"javascript:Load('hostname.php')\" class=Action>{$LNG['SetupHostname']}</a>";
			}
			elseif (stristr($TIP,"Not Resolving To"))
			{
			$TIP=Lang($TIP).". <a href=\"javascript:Load('hostname.php')\" class=Action>{$LNG['CorrectHostname']}</a>";
			}
			elseif (stristr($TIP,"Enter administrator email"))
			{
			$TIP=Lang($TIP).". <a href=\"javascript:Load('basic.php')\" class=Action>{$LNG['BasicGoAdmioSetup']}</a>";
			}
			elseif (stristr($TIP,"Nameserver") and $CloudflareAccountID=="")
			{
			$TIP="{$LNG['ConfigureNameserversOrSetUpCloudflareAPI']}. <a href=\"javascript:Load('nameservers.php')\" class=Action>{$LNG['SetupNameservers']}</a> <a href=\"javascript:Load('cloudflare.php')\" class=Action>{$LNG['CloudflareAPI']}</a>";
			}
			elseif (stristr($TIP,"Schedule") and stristr($TIP,"password"))
			{										
			$TIP=Lang($TIP).". <a href=\"javascript:Load('schedule.php')\" class=Action>{$LNG['CorrectRemoteServerInfo']}</a>";
			}
			elseif (stristr($TIP,"Schedule") and stristr($TIP,"daily"))
			{										
			$TIP=Lang($TIP).". <a href=\"javascript:Load('schedule.php')\" class=Action>{$LNG['CreateScheduledBackup']}</a>";
			}

			echo "<div class=NavigatorInfo id=Update><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>$TIP</div>";		
		}
	
	
	}

	if ($IPv6=="")
	{
		if ($_REQUEST['EnableIPv6']==1)
		{
		$ShowIPv6="Wait up to 3 minutes to activate IPv6";
		}
		else
		{
		$ShowIPv6="<span onclick=\"Load('home.php?EnableIPv6=1')\" style='cursor:pointer'>Enable IPv6</span>";
		}
	}
	else
	{
	$ShowIPv6="<span title='Click to Copy' onclick=\"Copy('$IPv6')\">IPv6: $IPv6</span> | <span onclick=\"Load('home.php?DisableIPv6=1')\" style='cursor:pointer'>Disable IPv6</span>";
	}

	echo "<div class=UNavigator>Hostname: $Hostname &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; OS: $OS $OSVersion &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Web Server: $WS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span title='Click to Copy' onclick=\"Copy('$IPv4')\">IPv4: $IPv4</span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $ShowIPv6</div>";		
	


}

if ($_SESSION['SessionType']=="Root")
{
$ServiceSql="Service!=4";
$SortBy="Sort";
}
elseif ($_SESSION['SessionType']=="Reseller")
{
    $ServiceSql="Service in (2,3)";
	$SortBy="Sort";
}
elseif ($_SESSION['SessionType']=="Website")
{
    $ServiceSql="Service>=3";
	$SortBy="Priority,Sort";
}

if ($_SESSION['SessionView']!="User" and $_SESSION['SessionView']!="Mobile")
{

	echo "
	<div class=DivIcon>
	";

	$X=0;
	
	$Result = SQL("select * from Control where $ServiceSql group by ControlMenu order by $SortBy");
	foreach ($Result as $Row)
	{
	$X++;


		$ControlMenu=$LNG[$Row['ControlMenu']];
		$ControlMenuImage=$Row['ControlMenuImage'];

		echo "
			<a href='javascript:Load(\"category.php?ControlMenu={$Row['ControlMenu']}\")' class='Main {$Dir}Main'>
				<div class='Icon'>
					<img src='theme/{$_SESSION['SessionTheme']}/svg/$ControlMenuImage' alt='$ControlMenu'>
				</div>
				<span>$ControlMenu</span>
			</a>
		";
		
	}

	echo "
	</div>
	";
}
else
{

	require "cp.php";

}




if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	echo "
	<div class=DivChart>
	
		<div class=Chart title='$HardDiskInfo'> 
		
		<span class=ChartTitle>{$LNG['DiskUsage']}</span>
		<br>
			<center>
			<div class='progress-circle progress-$ServerDiskPercent'><span>$ServerDiskPercent</span></div>  
			<br>
			{$ServerDiskUsed}B / {$ServerDiskSpace}B $StorageType
			</center>
		</div>

		<div class=Chart title='Swap: $Swap\nSwappiness: $Swappiness'> 
		
		<span class=ChartTitle>{$LNG['MemoryUsage']}</span>
		<br>
			<center>
		
			<div class='progress-circle progress-$MemoryPercent'><span>$MemoryPercent</span></div>
		  
			<br>
		  
			{$MemoryUsed}GB / {$Memory}GB $RAMType
			
			</center>
		  
		</div>
		
		
		
		<div class=Chart> 
		
		<span class=ChartTitle>{$LNG['ServerLoad']}</span>
		<br>
			<center>
		
			<div class='progress-circle progress-$CoresPercent'><span>$CoresPercent</span></div>  
		  
			<br>
			$CoresUsed / $Threads ($Cores Cores / $Threads Threads)
			</center>
		  
		</div>
	
	</div>
	";
	
}
elseif ($_SESSION['SessionType']=="Website")
{
    $Result = SQL("select * from Site where Username='{$_SESSION['SessionUsername']}'",60);
    foreach ($Result as $Row)
    {	
		$ExpiresOn = date("D j M Y", strtotime($Row['ExpiresOn']));
		$DomainExpiresOn = date("D j M Y", strtotime($Row['DomainExpiresOn']));

		$AddonNo=$Row['AddonNo'];
		$SubDomainNo=$Row['SubDomainNo'];
		$AliasNo=$Row['AliasNo'];
		$EmailNo=$Row['EmailNo'];
		$FTPNo=$Row['FTPNo'];
		$DatabaseNo=$Row['DatabaseNo'];
		$PHPVersion=$Row['PHPVersion'];


		$SpaceUsed=FormatSize($Row['SpaceUsed']);
		
		if ($Row['DiskSpace']==0) 
		{
		$DiskSpace="Unlimited";
		
		$DiskSpacePercent=1;
		}
		else
		{
		$DiskSpace=FormatSize($Row['DiskSpace']);
		
		$DiskSpacePercent=floor($Row['SpaceUsed']*100/$Row['DiskSpace']); 
		}
		
			
		$BandwidthUsed=FormatSize($Row['BandwidthUsed']);
		
		if ($Row['Bandwidth']==0) 
		{
		$Bandwidth="Unlimited";
		
		$BandwidthPercent=1;
		}
		else
		{
		$Bandwidth=FormatSize($Row['Bandwidth']);
		
		$BandwidthPercent=floor($Row['BandwidthUsed']*100/$Row['Bandwidth']); ;
		}
		
		

	}
	
	$Emails=RowCount("select * from Mail where Username='{$_SESSION['SessionUsername']}'");
	$Addons=RowCount("select * from Site where Username='{$_SESSION['SessionUsername']}' and Owner!=''");
	$SubDomaons=RowCount("select * from Subdomain where Username='{$_SESSION['SessionUsername']}'");
	$Aliases=RowCount("select * from Alias where Username='{$_SESSION['SessionUsername']}'");
	$FTPs=RowCount("select * from Ftp where Username='{$_SESSION['SessionUsername']}'");
	$Databases=RowCount("select * from Mysql where Username='{$_SESSION['SessionUsername']}'");

    $Result = SQL("select sum(Size) as MySQLSize from Mysql where Username='{$_SESSION['SessionUsername']}'");
    foreach ($Result as $Row)
    {	
		$MySQLSize=FormatSize($Row['MySQLSize']);
	}
	

	$ShowDomain=$_SESSION['SessionDomain'];
	$ShowDomainTitle=$ShowDomain;
	if (strlen($ShowDomain)>20)
	{
	$ShowDomain=substr($ShowDomain,0,20)."...";
	}
	
	$HomeDirectory="/home/{$_SESSION['SessionDomain']}";
	$HomeDirectoryTitle=$HomeDirectory;
	if (strlen($HomeDirectory)>20)
	{
	$HomeDirectory=substr($HomeDirectory,0,20)."...";
	}
	
	echo "
	<div class=DivChart>
	
		<div class=Chart> 
		
		<span class=ChartTitle>{$LNG['DiskUsage']}</span>
		<br>
			<center>
			<div class='progress-circle progress-$DiskSpacePercent'><span>$DiskSpacePercent</span></div>  
			<br>
			$SpaceUsed / $DiskSpace
			</center>
		  
		</div>



		<div class=Chart> 
		
		<span class=ChartTitle>Bandwidth</span>
		<br>
			<center>
		
			<div class='progress-circle progress-$BandwidthPercent'><span>$BandwidthPercent</span></div>  
		  
			<br>
		  
			$BandwidthUsed / $Bandwidth
			
			</center>
		  
		</div>
		
	
	</div>
	";

}

?>