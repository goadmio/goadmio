<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8');

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";


if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{
	echo "Sorry, You Are Not Allowed to Access This Page";
	exit;
}

if (!StartsWith(getcwd(),"/usr/local/goadmio"))
{
	echo "Invalid Blackhost Path";
	exit;
}

$Command=$_REQUEST['Command'];
$Value=$_REQUEST['Value'];

if (stristr($Command,"directoryindex"))
{
$Value=str_replace(" ",",",$Value);
$Value=str_replace(";",",",$Value);

$Array=explode(",",$Value);

	$Value="";
	foreach ($Array as &$File) 
	{
		$File=trim($File);
		if ($File)
		{	
			if ($Value=="")
			{
			$Value=$File;
			}
			else
			{
			$Value.=" ".$File;
			}
		}
	}
	
	$Value=trim($Value);
	if ($Value=="")
	{
	$Value="default.html index.html index.htm index.php go.html";
	}

}
elseif (stristr($Command,"maxkeepaliverequests"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	
	if (trim($Value==""))
	{
	$Value="100";
	}
	else
	{
	$Value=intval($Value);
	}

	if ($Value==0)
	{
	$Value="0";
	}
	elseif ($Value<0)
	{
	$Value="100";
	}
	elseif ($Value>1000)
	{
	$Value="1000";
	}

}
elseif (stristr($Command,"keepalivetimeout"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);

	if (trim($Value==""))
	{
	$Value="5";
	}
	else
	{
	$Value=intval($Value);
	}

	if ($Value<0)
	{
	$Value="5";
	}	
	elseif ($Value>=15)
	{
	$Value="15";
	}
	
}
elseif (stristr($Command,"keepalive"))
{

	if ($Value=="0" or stristr($Value,"o"))
	{
	$Value="Off";
	}
	else
	{
	$Value="On";
	}
}
elseif (stristr($Command,"logrotate"))
{

	$Value=intval($Value);
	
	if ($Value==1)
	{
		SSH ("/usr/bin/sudo /go/logrotate 1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	else
	{
		SSH ("/usr/bin/sudo /go/logrotate 7",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);	
	}
	
}


else
{
exit;
}

$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '$Command $Value'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

if (stristr($Error,"!"))
{
echo $Error;
}
else
{
echo $Value;
}

?>