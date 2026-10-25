<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Date=date ("Y-m-d");

$Restore=intval($_REQUEST['Restore']);

$Domain=ValidateDomain($_REQUEST['Domain']);

$Type=trim($_REQUEST['Type']);

$BackupID=trim($_REQUEST['BackupID']);


if ($Action=="Snapshot")
{
	include "access.php";
	
	if (file_exists("/var/log/go/snapshot/$Domain-$Date.log"))
	{
	echo Error("Snapshot for Domain $Domain ($Date) Already Exists");		
	}
	else
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/snapshot $Domain > /var/log/go/snapshot/$Domain-$Date.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Creating snapshot for domain $Domain...");
	}
	
}

if ($Restore!=0)
{
	include "access.php";

	If ($Restore==1 and $Step==1)
	{
		
		echo "
		<div class=DivXTable>
		";

			$List=SSH ("/usr/bin/sudo /go/snapshot $Domain --list",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
			$ListArray=explode("\n",$List);

			echo "
			<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

			<THEAD>
			
			<tr>

			<th colspan=2 width='100%' height=40>Restore $Type Backup ($Domain)</th>
			
			</THEAD>
				
			<TBODY>
			";

			$X=0;
			foreach ($ListArray as $Value) 
			{
				if (stristr($Value,"|"))
				{
					$BackupArray=explode("|",$Value);
					$BackupID=$BackupArray[0];
					$BackupDate=date("D j M Y g:i a", $BackupArray[2]);
					
					if ($X%2==0)
					{
					$TDColor="Td";
					}
					else
					{
					$TDColor="TdB";
					}
					
					echo "
					<tr class='$TDColor'>

					<TD align='middle'>$BackupDate</TD>
					<TD align='middle'><a href='#' onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=2&Domain=$Domain&Type=$Type&BackupID=$BackupID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Snapshot</a></TD>
					";
					
					$X++;
					
				}
				
			}

		echo "
			</TBODY>
			</TABLE>
		
		</div>
		";
		
	}

	If ($Restore==1 and $Step==2)
	{
		
		if ($BackupID!="")
		{
			if ($Type=="Mail")
			{
			SSH ("/usr/bin/sudo screen -d -m bash -c '/go/snapshot /home/$Domain/mail $BackupID > /var/log/go/snapshot/$Domain-$Type.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			elseif ($Type=="www")
			{
			SSH ("/usr/bin/sudo screen -d -m bash -c '/go/snapshot /home/$Domain/www $BackupID > /var/log/go/snapshot/$Domain-$Type.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			elseif ($Type=="Database")
			{
			SSH ("/usr/bin/sudo screen -d -m bash -c '/go/snapshot $Domain restore $BackupID --database > /var/log/go/snapshot/$Domain-$Type.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			else
			{
			SSH ("/usr/bin/sudo screen -d -m bash -c '/go/snapshot $Domain restore $BackupID > /var/log/go/snapshot/$Domain-$Type.log'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			}
			
			echo Error("Restore $Type Backup ($Domain) in Progress.");
		}
	}
	
}


	include "search.php";
	
    Echo "
	<form name=CheckForm id=CheckForm action='$CurrentFileName'>
	<input type=hidden name=Action id=Action>
	
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

	<THEAD>
	
	<tr>
	
    <TH align='$DAlign' width='30%'>
    {$LNG['Domain']}
    </TH>
	
    <TH width='70%'>
 
    </TH>
	
	</tr>
	
	</THEAD>
	
	";
	
	
	$List=SSH ("/usr/bin/sudo /go/snapshot list",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	$ListArray=explode("\n",$List);

	$X=0;
	foreach ($ListArray as $Domain)
	{
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
	<tr id='TR{$ID}' class='$TDColor' divid=Find find='$Domain'>

    <TD>
    $Domain
    </td>

	<TD align='$OAlign'>
	<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Action=Snapshot&Step=1&Domain=$Domain&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Create Snapshot</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=1&Domain=$Domain&Type=Full&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Account (Full Backup)</a>
	<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=1&Domain=$Domain&Type=www&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore www</a>
	<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=1&Domain=$Domain&Type=Mail&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Mail</a>
	<a href=\"#\" onclick=\"this.textContent='Please Wait...';Load('$CurrentFileName?Restore=1&Step=1&Domain=$Domain&Type=Database&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>Restore Databases</a>
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

	<tr class=TdDown>

	<th align='$DAlign' colspan=6>
	Showing $X of $RowsNo records.
	</th>

	</tr>

	</TFOOT>

	</TABLE>
	</div>
	</form>
	";
	
	// include "pages.php";
	

?>