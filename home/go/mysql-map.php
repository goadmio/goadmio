<?php

include "navigator.php";
$Buttons="";
include "title.php";

try {
    $pdo = new PDO("mysql:host=$DBHost;dbname=mysql;charset=utf8", $DBUser, $DBPass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);
} catch (PDOException $e) {
    // Silently fail like the original mysqli code
}

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

	Echo "
	Sorry, You Are Not Allowed to Access This Page
	";

exit;
}

$DatabaseName=ValidateDatabaseName($_REQUEST['DatabaseName']);
$PHPMyAdmin=intval($_REQUEST['PHPMyAdmin']);
$ChangeOwner=intval($_REQUEST['ChangeOwner']);

$Domain=ValidateDomain($_REQUEST['Domain']);
$Username=ValidateUsername($_REQUEST['Username']);

if ($PHPMyAdmin==1)
{

	$Result = SQL("select * from Mysql where MysqlID='$MysqlID'");
	foreach ($Result as $Row)
	{
	setcookie ("CookiesMySQLUsername",$Row[User],time() + (86400 * 30), "/");
	setcookie ("CookiesMySQLPassword",$Row[Pass],time() + (86400 * 30), "/");

	header("Location: /phpmyadmin");
	}

exit;
}


If ($Action=="ListOwner")
{
	echo "
	<div class='DivInput {$Dir}DivInput'>Select a New Owner ($DatabaseName):<br>
	";

		$Result = SQL("select * from Site where SiteID>=1");
		foreach ($Result as $Row)
		{
			
			if ($Domain==$Row['Domain'])
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' checked='checked'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				{$Row['Domain']}
				</span>
			</label>
			";
			}
			else
			{
			echo "
			<label class=\"radio-enhanced\">
				<input type='radio' onclick='Load(\"$CurrentFileName?ChangeOwner=1&Domain={$Row['Domain']}&Username={$Row['Username']}&DatabaseName=$DatabaseName&Page=$Page\")'>
				<span class=\"radio-custom\"></span>
				<span class=\"radio-label-text\">
				{$Row['Domain']}
				</span>
			</label>
			";
			}
		
		}
	
}
	
if ($ChangeOwner==1)
{
	$Exists=0;
	$Result = SQL("select MysqlID from Mysql where Name='$DatabaseName'");
	foreach ($Result as $Row)
	{
	$Exists=1;
	}

	if ($Exists==0)
	{
	$TimeStamp=time();
	SQL("INSERT OR IGNORE INTO Mysql (Domain,Username,Name,User,Pass,TimeStamp) VALUES ('$Domain','$Username','$DatabaseName','$DatabaseName','$Pass','$TimeStamp')");	
	}
	else
	{
		if ($Domain=="" OR $Username=="")
		{
		echo Error("Invalid Domain ($Domain) or Username ($Username)");
		}
		else
		{
		$Sql = "UPDATE Mysql set Domain='$Domain',Username='$Username' where Name='$DatabaseName'";
		$Result = SQL($Sql);
		}
	}
	
	$Error=SSH ("/usr/bin/sudo /go/phpmyadmin $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	

}

	
    $RecordsNo = $pdo->query("SELECT table_schema AS DatabaseName, SUM(data_length + index_length) AS DatabaseSize FROM information_schema.TABLES where table_schema not in ('mysql','information_schema','performance_schema','horde','roundcube','sys') GROUP BY table_schema")->rowCount();

	include "search.php";
	
	Echo "
	<div class=DivXTable>
	<table cellPadding='8' cellSpacing=0 width='100%' class=Table>

	<THEAD>
	
	<tr>
	
	<th align='$DAlign' width='38%'>
	<a href=\"javascript:Load('$CurrentFileName?SortBy=DatabaseName')\">{$LNG['DatabaseName']}</a>
	</th>
	
	<th align='$DAlign' width='10%'>
	<a href=\"javascript:Load('$CurrentFileName?SortBy=data_length')\">{$LNG['Size']}</a>
	</th>
	
	<th align='$DAlign' width='20%'>
	{$LNG['Owner']}
	</th>
	
	<th width='30%'>

	</th>
	

	</THEAD>

	";

	if ($SortBy=="")
	{
		$SortBy="DatabaseName";
	}
	
	if ($Direction=="")
	{
		$Direction="ASC";
	}
	
	if ($Page=="")
	{
		$Page=1;
	}

	$FilterSql=str_replace("\'","'",$FilterSql);

	$FromRecord=($Page-1)*$PageNo;

	if ($FilterSql!="")
	{
		$Sql = "SELECT table_schema AS DatabaseName, SUM(data_length + index_length) AS DatabaseSize FROM information_schema.TABLES where table_schema not in ('mysql','information_schema','performance_schema','horde','roundcube','sys') GROUP BY table_schema order by $SortBy $SortDir LIMIT $FromRecord,$PageNo";
		$RowsNo = $pdo->query("SELECT table_schema AS DatabaseName, SUM(data_length + index_length) AS DatabaseSize FROM information_schema.TABLES where table_schema not in ('mysql','information_schema','performance_schema','horde','roundcube','sys') GROUP BY table_schema")->rowCount();
	}
	elseif ($SearchFor=="")
	{
		$Sql = "SELECT table_schema AS DatabaseName, SUM(data_length + index_length) AS DatabaseSize FROM information_schema.TABLES where table_schema not in ('mysql','information_schema','performance_schema','horde','roundcube','sys') GROUP BY table_schema order by $SortBy $SortDir LIMIT $FromRecord,$PageNo";
		$RowsNo = $pdo->query("SELECT table_schema AS DatabaseName, SUM(data_length + index_length) AS DatabaseSize FROM information_schema.TABLES where table_schema not in ('mysql','information_schema','performance_schema','horde','roundcube','sys') GROUP BY table_schema")->rowCount();
	}


	$X=0;
	$Result = $pdo->query($Sql);
	while ($Row = $Result->fetch(PDO::FETCH_ASSOC))
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
		
		$SerialNo=(($Page-1)*$PageNo)+($X+1);
		
		$DatabaseSize=FormatSize($Row['DatabaseSize']);

		$Owner="root";
		$ResultQ = SQL("select * from Mysql where Name='{$Row['DatabaseName']}'");
		foreach ($ResultQ as $RowQ)
		{
			$Domain=$RowQ['Domain'];
			$Username=$RowQ['Username'];
			
			$Owner="{$Domain} ($Username)";
		}
		
		if ($Owner=="root")
		{
			$Name=$Row['DatabaseName'];
			$Name=strstr($Name,"_",true);
				
			$SiteNo=0;
			$ResultQ = SQL("select * from Site where Domain like '{$Name}%' or Username like '{$Name}%'");
			foreach ($ResultQ as $RowQ)
			{
				$SiteNo++;
			
				$Domain=$RowQ['Domain'];
				$Username=$RowQ['Username'];
			}
			
			if ($SiteNo==0)
			{
				// Another AI
				$Len = strlen($Name);
				for ($N = 1; $N < $Len; $N++) 
				{
					$SmartName=substr($Name, 0, $N) . "-" . substr($Name, $N);
							
					$ResultQ = SQL("select * from Site where Domain like '{$SmartName}%' or Username like '{$SmartName}%'");
					foreach ($ResultQ as $RowQ)
					{
						$SiteNo++;
					
						$Domain=$RowQ['Domain'];
						$Username=$RowQ['Username'];
					}
					
					if ($SiteNo==1)
					{
					break;
					}
				}
			
			}

			if ($SiteNo==1)
			{
				$TimeStamp=time();
				$MysqlID=SQL("INSERT OR IGNORE INTO Mysql (Domain,Username,Name,User,Pass,TimeStamp) VALUES ('$Domain','$Username','{$Row['DatabaseName']}','{$Row['DatabaseName']}','$Pass','$TimeStamp')");	
				
				if ($MysqlID>=1)
				{
				$Owner="{$Domain} ($Username)";
				}
			}

		}
		

		echo "
		
		<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['DatabaseName']}-$Username'>

		<TD align='$DAlign'><a href=\"javascript:Load('$CurrentFileName?Action=ListOwner&DatabaseName={$Row['DatabaseName']}&Username=$Username&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" target='_blank'>{$Row['DatabaseName']}</a></TD>

		<TD align='$DAlign'>{$DatabaseSize}</TD>
		
		<TD align='$DAlign'>$Owner</TD>

		<TD align='$OAlign'>
		
		<a href=\"javascript:Load('$CurrentFileName?Action=ListOwner&DatabaseName={$Row['DatabaseName']}&Domain=$Domain&Username=$Username&ControlID=$ControlID&Page=$Page&ScrollTo=TR{$ID}')\" class=Action>{$LNG['ChangeOwner']}</a>

		</TD>
		";
		
	$X++;
	}
	
	if ($X!=0)
	{
	echo "</TBODY>";
	}

	echo "
	<TFOOT>

	<tr>


	<th align='$DAlign' colspan=3>
	Showing $X of $RowsNo records.
	</th>
	
	<th align='$OAlign' colspan=3>
	";
			
	include "pages.php";

	echo "
	</th>

	</tr>

	</TFOOT>

	</TABLE>
	</div>
	";
	
?>