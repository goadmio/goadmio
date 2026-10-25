<?php

include "navigator.php";
$Buttons="
<a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['Refresh']}</a>
<a href='$CurrentFileName?Action=Export&Service=$Service&ControlID=$ControlID&CTabNo=$CTabNo' target='_blank' class='ButtonB {$Dir}ButtonB'>{$LNG['ExportExcel']}</a>
";
include "title.php";

if ($_REQUEST['Action']=="Export")
{
	header("Content-Type: application/vnd.ms-excel");
	header("Content-Disposition: attachment; filename=ServiceStatus.xls");
	header("Pragma: no-cache");
	header("Expires: 0");


	echo "
	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">

	<table width=100% border=1>
	<tr bgcolor='#000000' style='color:#FFFFFF'>
	<td>{$LNG['Service']}</td>
	<td>{$LNG['Status']}</td>
	<td>{$LNG['Description']}</td>
	";
	
	$X=0;
	$Sql = "select * from Status where StatusID>=1 order by Sort";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$X++;

		if ($X%2==0)
		{
		$TDColor="#CCCCCC";
		}
		else
		{
		$TDColor="#FFFFFF";
		}
		
		if (stristr($Row['Status'],"failed"))
		{
		$TDColor="#ffe1e1";
		}
		elseif (stristr($Row['Status'],"exited"))
		{
		$TDColor="#A0A0FF";
		}
		
		$Status=$Row['Status'];
		if (stristr($Status,"running"))
		{
		$Status="Up";
		}
		elseif (stristr($Status,"exited"))
		{
		$Status="Exited";
		}
		elseif (stristr($Status,"failed"))
		{
		$Status="Failed";
		}
		
		Echo "
		<TR bgcolor='$TDColor'>		
		<TD>{$Row['Service']}</TD>
		<TD>{$Status}</TD>
		<TD>{$Row['Description']}</TD>
		";
	}
	
exit;
}
	
	$Error=SSH ("/usr/bin/sudo /go/status",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],600);

	if (time() - 600 > $_SESSION['StatusStamp']) 
	{
		$_SESSION['StatusStamp'] = time();
		
		SQL("UPDATE Status SET Sort='1' where Service like '%httpd%'");
		SQL("UPDATE Status SET Sort='2' where Service like '%named%'");
		SQL("UPDATE Status SET Sort='3' where Service like '%mariadb%'");
		SQL("UPDATE Status SET Sort='4' where Service like '%mysql%'");
		SQL("UPDATE Status SET Sort='5' where Service like '%ftp%'");
		SQL("UPDATE Status SET Sort='6' where Service like '%sshd%'");
		SQL("UPDATE Status SET Sort='7' where Service='NetworkManager'");
		SQL("UPDATE Status SET Sort='8' where Service like '%postfix%'");
		SQL("UPDATE Status SET Sort='9' where Service like '%dovecot%'");
		SQL("UPDATE Status SET Sort='10' where Service like '%crond%'");
		SQL("UPDATE Status SET Sort='11' where Service like '%firewalld%'");
		SQL("UPDATE Status SET Sort='12' where Service like '%memcached%'");
		SQL("UPDATE Status SET Sort='13' where Service like '%saslauthd%'");
		SQL("UPDATE Status SET Sort='14' where Service like '%shellinaboxd%'");
	}

	$DisableSearch=1;
	include "search.php";

	Echo "
	
		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' nowrap>
		{$LNG['Service']}
		</th>

		<th align='$DAlign' nowrap>
		{$LNG['Status']}
		</th>

		<th align='$DAlign' nowrap>
		{$LNG['Description']}
		</th>
		
		<th align='$DAlign' nowrap>
		
		</th>
		
		</THEAD>
		
		";

		if ($SortBy=="")
		{
			$SortBy="Sort";
		}
		
		if ($Direction=="")
		{
			$Direction="ASC";
		}
		
		if ($Page=="")
		{
			$Page=1;
		}

		$X=0;
		$Sql = "select * from Status where StatusID>=1 order by $SortBy $Direction";
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			if ($x%2==0)
			{
			$TDColor="TdB";
			}
			else
			{
			$TDColor="Td";
			}
			
			if (stristr($Row['Status'],"failed"))
			{
			$TDColor="TdEr";
			}
			elseif (stristr($Row['Status'],"exited"))
			{
			$TDColor="TdInfo";
			}
			
			$Status=$Row['Status'];
			if (stristr($Status,"running"))
			{
			$Status="Up";
			}
			elseif (stristr($Status,"exited"))
			{
			$Status="Exited";
			}
			elseif (stristr($Status,"failed"))
			{
			$Status="Failed";
			}
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Service']}-{$Row['Status']}-{$Row['Description']}' class='$TDColor'>

			<TD>{$Row['Service']}</TD>
			<TD nowrap>{$Status}</TD>
			<TD>{$Row['Description']}</TD>
			<TD align='$OAlign'>
			";

			if ($Status=="Failed")
			{
				if ($Row['Service']=="postfix" or $Row['Service']=="dovecot")
				{
				echo "<a href=\"javascript:Load('$CurrentFileName?Fix=1&Service={$Row['Service']}&SortBy=$SortBy&SortDir=$SortDir&ControlID=$ControlID&Page=$Page','$ControlID')\" class=Action>Fix</a>";
				}
			}
			

			if ($Status=="Failed" and $Row['Service']=="named")
			{
			
				$NS1=SSH ("head -n 1 /etc/nameservers",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

				if (trim($NS1)=="")
				{
				echo "<a href=\"javascript:Load('nameservers.php','0')\" class=Action>Fix</a>";
				}
				else
				{
				echo "<a href=\"javascript:Load('$CurrentFileName?Fix=1&Service={$Row['Service']}&SortBy=$SortBy&SortDir=$SortDir&ControlID=$ControlID&Page=$Page','$ControlID')\" class=Action>Fix</a>";
				}
			}
			

			
			echo "
			</TD>
			";
			
		$X++;
		}
		
		echo "
	
		</TABLE>
		
		</div>
		";
		
	
	
?>