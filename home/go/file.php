<?php
include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";

if ($DBHost=="")
{
echo "Database connection failed";
exit;
}

$Action=trim($_REQUEST['Action']);

// header("Content-Type: text/html; charset=UTF-8");
header("Content-Type: text/plain; charset=UTF-8");

$IP=trim($_REQUEST['IP']);
$ServerIP=trim($_REQUEST['ServerIP']);
$Type=trim($_REQUEST['Type']);
$From=intval($_REQUEST['From']);
$Limit=intval($_REQUEST['Limit']);

if ($Limit==0)
{
$Limit=5000;
}

$Hostname=trim($_REQUEST['Hostname']);
$Name=trim($_REQUEST['Name']);
$Value=trim($_REQUEST['Value']);
$Password=trim($_REQUEST['Password']);

if ($Action=="Requests")
{
    $Result = SQL("SELECT Requests FROM Config where ConfigID=1");
    foreach ($Result as $Row)
    {
		echo $Row['Requests'];
	}

exit;
}





if ($Action=="Blacklist")
{

	if ($Type=="")
	{
    $Result = SQL("SELECT * FROM Blacklist where Visits>=5 ORDER BY SubnetNo DESC,Visits DESC LIMIT $From,$Limit");
	}
	else
	{
    $Result = SQL("SELECT * FROM Blacklist where Type='$Type' and Visits>=5 ORDER BY SubnetNo DESC,Visits DESC LIMIT $From,$Limit");
	}
    foreach ($Result as $Row)
    {
		if ($Row['SubnetNo']>=256)
		{
		echo $Row['Subnet']."\n";
		}
		else
		{
		echo $Row['IP']."\n";
		}
	}

exit;
}

if ($Action=="Unblock")
{

	if (filter_var($IP,FILTER_VALIDATE_IP)) 
	{
		
		$IPArray = explode(".", $IP);

		$IP8 ="{$IPArray[0]}.0.0.0/%";
		$IP16="{$IPArray[0]}.{$IPArray[1]}.0.0/%";
		$IP24="{$IPArray[0]}.{$IPArray[1]}.{$IPArray[2]}.0/%";

		SQL("DELETE FROM Blacklist WHERE IP='$IP'");
		
		if (stristr($IP,"."))
		{
			SQL("DELETE FROM Blacklist WHERE SubnetNo>=256 and (Subnet LIKE '$IP8' or Subnet LIKE '$IP16' or Subnet LIKE '$IP24')");
		}
		
		
	}
	
	exit;
}

if ($IP!="" and $Hostname!="" and $ServerIP!="" and $Type!="")
{
	if (filter_var($IP, FILTER_VALIDATE_IP)) 
	{
		// Subnet /24
		$Subnet=preg_replace('/\.[0-9]+$/', '.0/24', $IP);
		$SubnetNo=SQL("SELECT count(*) FROM Blacklist WHERE Subnet='$Subnet'");
		$TimeStamp=time();

		$SubnetExists=SQL("SELECT count(*) FROM Blacklist WHERE Subnet='$Subnet' and SubnetNo=256");
		if ($SubnetExists==0)
		{
			if ($SubnetNo>=5)
			{
			$SubnetNo="256";
			SQL("DELETE FROM Blacklist where Subnet='$Subnet'");	
			}
			
			SQL("INSERT OR IGNORE INTO Blacklist (IP,Subnet,SubnetNo,Hostname,ServerIP,Type,Visits,TimeStamp) VALUES ('$IP','$Subnet','$SubnetNo','$Hostname','$ServerIP','$Type','5','$TimeStamp')");
		
		}
		else
		{
			SQL("UPDATE Blacklist SET Visits=Visits+1,TimeStamp='$TimeStamp' where Subnet='$Subnet'");
		}
		
		SQL("UPDATE Blacklist SET Visits=Visits+1,TimeStamp='$TimeStamp' where IP='$IP'");	

		// Subnet /16
		$PartArray=explode('.', $IP);
		$PartIP=$PartArray[0].".".$PartArray[1].".";

		$Subnet=preg_replace('/^(\d+\.\d+)\.\d+\.\d+$/', '$1.0.0/16', $IP);
		$DatacenterSubnetNo=SQL("SELECT count(*) FROM Datacenter WHERE Subnet='$Subnet'");
		$TimeStamp=time();
		
		$SubnetExists=SQL("SELECT count(*) FROM Blacklist WHERE Subnet like '$PartIP%' and Subnet like '%/24'");
		
		if ($DatacenterSubnetNo>=1 and $SubnetExists>=10)
		{
			$SubnetNo="65536";
			SQL("DELETE FROM Blacklist where IP like '$PartIP%'");	
			SQL("INSERT OR IGNORE INTO Blacklist (IP,Subnet,SubnetNo,Hostname,ServerIP,Type,Visits,TimeStamp) VALUES ('$IP','$Subnet','$SubnetNo','$Hostname','$ServerIP','$Type','5','$TimeStamp')");
		}

	}
	
	exit;
}

if ($Value!="" and $Password!="")
{
// Save

	$Sql = "Delete from File where Hostname='$Hostname' and Name='$Name'";
	$Result = SQL($Sql);

	$TimeStamp=time();
	$Sql = "INSERT INTO File (Hostname,Name,Value,Password,TimeStamp) VALUES ('$Hostname','$Name','$Value','$Password','$TimeStamp')";
	$Result = SQL($Sql);

}
elseif ($Password!="")
{
// Open

    $Result = SQL("SELECT * FROM File where Hostname='$Hostname' and Name='$Name' and Password='$Password' ORDER BY FileID DESC LIMIT 1");
    foreach ($Result as $Row)
    {
		echo $Row['Value'];
	}

}

?>