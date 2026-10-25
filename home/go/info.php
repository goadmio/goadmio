<?php

	if (!function_exists('SQL')) 
	{
	echo "SQL() function does NOT exist";
	exit;
	}

	if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
	{
		$PHPVersion=phpversion();
	}
	else
	{
		$Result=SQL("select * from Site where Domain='{$_SESSION['SessionDomain']}'");
		foreach ($Result as $Row)
		{	
			$ExpiresOn = date("D j M Y", strtotime($Row['ExpiresOn']));
			$DomainExpiresOn = date("D j M Y", strtotime($Row['DomainExpiresOn']));

			$AddonNo=$Row['AddonNo'];
			if ($AddonNo<0) {$AddonNo=0;}

			$AliasNo=$Row['AliasNo'];
			if ($AliasNo<0) {$AliasNo=0;}

			$SubDomainNo=$Row['SubDomainNo'];

			$EmailNo=$Row['EmailNo'];
			$FTPNo=$Row['FTPNo'];
			$DatabaseNo=$Row['DatabaseNo'];
			$PHPVersion=$Row['PHPVersion'];

			$SpaceUsed=FormatSize($Row['SpaceUsed']);
			$MailSpaceUsed=FormatSize($Row['MailSpaceUsed']);
			
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

			$InodeUsed=$Row['InodeUsed'];
			
			if ($Row['Inode']==0) 
			{
			$Inode="Unlimited";
			
			$InodePercent=1;
			}
			else
			{
			$Inode=$Row['Inode'];
			
			$InodePercent=floor($Row['InodeUsed']*100/$Row['Inode']); ;
			}
			
		}
	}
		
	$Emails=RowCount("select * from Mail where Domain='{$_SESSION['SessionDomain']}'");
	$Emails=intval($Emails);
	$Addons=RowCount("select * from Site where Domain='{$_SESSION['SessionDomain']}'  and Owner!=''");
	$Addons=intval($Addons);
	$SubDomaons=RowCount("select * from Subdomain where Domain='{$_SESSION['SessionDomain']}'");
	$SubDomaons=intval($SubDomaons);
	$Aliases=RowCount("select * from Alias where Domain='{$_SESSION['SessionDomain']}'");
	$Aliases=intval($Aliases);
	$FTPs=RowCount("select * from Ftp where Domain='{$_SESSION['SessionDomain']}'");
	$FTPs=intval($FTPs);
	$Databases=RowCount("select * from Mysql where Domain='{$_SESSION['SessionDomain']}'");
	$Databases=intval($Databases);

	$Sql = "select sum(Size) as MySQLSize from Mysql where Domain='{$_SESSION['SessionDomain']}'";
    $Result = SQL($Sql);
    foreach ($Result as $Row)
    {	
		$MySQLSize=FormatSize($Row['MySQLSize']);
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
	
	if (strlen($Hostname)>30)
	{
	$Hostname=substr($Hostname,0,27)."...";
	}
	
echo "
<div style='overflow-y: auto; overflow-x: hidden; height: 100%; max-height: calc(100vh - 60px);'>

	<div class='DivView'>

		<div class='ViewTitle'>
		General Information
		</div>
		
		<div class='ViewA'>
		Current User
		<span class='ViewB'>{$_SESSION['SessionUsername']}</span>
		</div>
		
		";
		
		if ($_SESSION['SessionType']=="Website" and $_SESSION['SessionUsername']!="root")
		{

			echo "
			<div class='ViewA'>
			Primary Domain
			<span class='ViewB'>{$_SESSION['SessionDomain']}</span>
			</div>

			<div class='ViewA'>
			Home Directory
			<span class='ViewB'>/home/{$_SESSION['SessionDomain']}</span>
			</div>
			

			<div class='ViewA'>
			Hosting Expires On
			<span class='ViewB'>$ExpiresOn</span>
			</div>

			";
			
			if (!stristr($DomainExpiresOn,"1970"))
			{
			echo "
			<div class='ViewA'>
			Domain Expires On
			<span class='ViewB'>$DomainExpiresOn</span>
			</div>
			";
			}
			
			
			echo "
			<div class='ViewA'>
			Shared IP Address
			<span class='ViewB'>$IPv4</span>
			</div>
			";

			if ($StorageType!="")
			{
			echo "
			<div class='ViewA'>
			Storage Type
			<span class='ViewB'>$StorageType</span>
			</div>
			";
			}

			echo "
			<div class='ViewA'>
			Disk Usage
			<span class='ViewB'>$SpaceUsed / $DiskSpace</span>
			</div>

			<div class='ViewA'>
			Bandwidth
			<span class='ViewB'>$BandwidthUsed / $Bandwidth</span>
			</div>
			";

			if ($InodeUsed!=0)
			{
			echo "
			<div class='ViewA'>
			Inode
			<span class='ViewB'>$InodeUsed / $Inode Files</span>
			</div>
			";
			}


			echo "
			<div class='ViewA'>
			Email Disk Usage
			<span class='ViewB'>$MailSpaceUsed</span>
			</div>	


			<div class='ViewA'>
			Database Disk Usage
			<span class='ViewB'>$MySQLSize</span>
			</div>	

			<div class='ViewA'>
			Addon Domains
			<span class='ViewB'>$Addons / $AddonNo</span>
			</div>
			
			<div class='ViewA'>
			Subdomains
			<span class='ViewB'>$SubDomaons / $SubDomainNo</span>
			</div>

			<div class='ViewA'>
			Alias Domains
			<span class='ViewB'>$Aliases / $AliasNo</span>
			</div>
			
			<div class='ViewA'>
			FTP Accounts
			<span class='ViewB'>$FTPs / $FTPNo</span>
			</div>

			<div class='ViewA'>
			Email Accounts
			<span class='ViewB'>$Emails / $EmailNo</span>
			</div>
			
			<div class='ViewA'>
			MariaDB Databases
			<span class='ViewB'>$Databases / $DatabaseNo</span>
			</div>
			";
		}
		
		echo "
		
			<div class='ViewA'>
			PHP Version
			<span class='ViewB'>$PHPVersion</span>
			</div>	
		
		<div class='ViewTitle'>Server Information</div>

		";
		
		if ($Virtualization!="")
		{
		echo "
		<div class='ViewA'>
		Virtualization
		<span class='ViewB'>$Virtualization</span>
		</div>
		";
		}
		
		
		if ($Hostname!="")
		{
		echo "
		<div class='ViewA' title='$HostnameTitle'>
		Hostname
		<span class='ViewB'>$Hostname</span>
		</div>	
		";
		}
		
		echo "
		<div class='ViewA'>
		Web Server
		<span class='ViewB'>$WS</span>
		</div>	

		";
		
		if ($WS=="Apache")
		{
		echo "
		<div class='ViewA'>
		Apache Version
		<span class='ViewB'>$WSVersion</span>
		</div>
		";
		}

		if ($WS=="NGINX")
		{
			if ($WSVersion!="")
			{
			echo "
			<div class='ViewA'>
			NGINX Version
			<span class='ViewB'>$WSVersion</span>
			</div>
			";
			}
		}
		
		echo "
		<div class='ViewA'>
		MariaDB Version
		<span class='ViewB'>$MariaDBVersion</span>
		</div>	
		";

		if ($PostgreSQLVersion!="")
		{
		echo "
		<div class='ViewA'>
		PostgreSQL Version
		<span class='ViewB'>$PostgreSQLVersion</span>
		</div>	
		";
		}
		
		echo "
		<div class='ViewA'>
		SQLite Version
		<span class='ViewB'>$SQLiteVersion</span>
		</div>	
		
		
		
		<div class='ViewA'>
		Operating System
		<span class='ViewB'>$OS $OSVersion</span>
		</div>	
		";

		if (in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
		{
		echo "
		<div class='ViewA'>
		Disk Usage
		<span class='ViewB'>{$ServerDiskUsed} / {$ServerDiskSpace}</span>
		</div>	
		";
		}

		echo "
		<div class='ViewA'>
		Server Load
		<span class='ViewB'>$CoresUsed</span>
		</div>
		
		<div class='ViewA'>
		Memory Used
		<span class='ViewB'>{$MemoryPercent}%</span>
		</div>

		<div class='ViewA'>
		Processor
		<span class='ViewB'>$Processor</span>
		</div>

		";

		echo "
		<div class='ViewA'>
		Architecture
		<span class='ViewB'>$Architecture</span>
		</div>	
		
		<div class='ViewA'>
		Kernel Version
		<span class='ViewB'>$KernelVersion</span>
		</div>	

		
	</div>	

</div>	
";
	

?>