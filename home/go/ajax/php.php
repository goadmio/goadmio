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

$Command=$_REQUEST['Command'];
$Value=trim($_REQUEST['Value']);

if (stristr($Command,"/memorylimit"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);
	
	if ($Value<=0)
	{
		$Value="-1";
	}
	elseif ($Value>0 and $Value<=32)
	{
		$Value="32M";
	}
	elseif ($Value>0 and $Value<=512)
	{
		$Value="{$Value}M";
	}
	
	if ($Value>512)
	{
		$Value="512M";
	}
	
}
elseif (stristr($Command,"/disablefunctions"))
{

	if ($Value=="")
	{
	$Value="exec,mail,passthru,pcntl_exec,popen,proc_close,proc_get_status,proc_open,proc_terminate,system";
	}
	
	$Value=str_replace(" ",",",$Value);
	$Value=str_replace(";",",",$Value);
	
	$Array=explode(",",$Value);
	
	if (is_array($Array))
	{
		sort ($Array);
		$Array = array_unique($Array);
		
		$Disabled = ini_get('disable_functions');
		
		$Value="";
		foreach ($Array as &$Function) 
		{
			
			if (function_exists("$Function") or stristr(",$Disabled,",",$Function,"))
			{
				
				if ($Value=="")
				{
					$Value=$Function;
				}
				else
				{
					$Value.=",".$Function;
				}
				
			}	
		}
	}
	elseif (function_exists("$Value"))
	{
		
	}
	else
	{
		$Value="";
	}
	
}
elseif (stristr($Command,"/maxexecutiontime"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);

	if ($Value==0)
	{
		$Value="600";
	}
	elseif ($Value<15)
	{
		$Value="30";
	}
	elseif ($Value>1800)
	{
		$Value="1800";
	}
	else
	{
		$Value=trim($Value);
	}
	
}
elseif (stristr($Command,"/maxinputtime"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);

	if ($Value==0)
	{
		$Value="600";
	}
	elseif ($Value<0)
	{
		$Value="-1";
	}
	elseif ($Value<30)
	{
		$Value="60";
	}
	
}
elseif (stristr($Command,"/maxinputvars"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);
	
	if ($Value<3000)
	{
		$Value=3000;
	}
	
}
elseif (stristr($Command,"/postmaxsize"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);

	if ($Value<=0)
	{
		$Value="64M";
	}
	else
	{
		$Value="{$Value}M";
	}
	
}
elseif (stristr($Command,"/uploadmaxfilesize"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);
	
	if ($Value<=0)
	{
		$Value="64M";
	}
	else
	{
		$Value="{$Value}M";
	}
	
	
}
elseif (stristr($Command,"/sessiongcmaxlifetime"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);
	
	if ($Value<=0)
	{
		$Value="28800";
	}
}
elseif (stristr($Command,"/errorreporting"))
{
	$Value=intval($Value);

	if ($Value != "0" && $Value != "1" && $Value != "2" && $Value != "4" && $Value != "8" && $Value != "16" && $Value != "32" && $Value != "64" && $Value != "128" && $Value != "256" && $Value != "512" && $Value != "1024" && $Value != "2048" && $Value != "4096" && $Value != "8192" && $Value != "16384" && $Value != "32767" && $Value != "22527" && $Value != "24575" && $Value != "30711" && $Value != "32759" && $Value != "34815" && $Value != "6143" && $Value != "341" && $Value != "5" && $Value != "7" && $Value != "3")
	{
	$Value=5;
	}


}
elseif (stristr($Command,"/allowurlfopen") or stristr($Command,"/zliboutputcompression") or stristr($Command,"/displayerrors") or stristr($Command,"/fileuploads"))
{
	
	if ($Value=="0" or stristr($Value,"f") or stristr($Value,"off"))
	{
		$Value="Off";
	}
	else
	{
		$Value="On";
	}
}
elseif (stristr($Command,"/allowurlinclude") or stristr($Command,"/displaystartuperrors"))
{
	
	if ($Value=="1" or stristr($Value,"n"))
	{
		$Value="On";
	}
	else
	{
		$Value="Off";
	}
}
elseif (stristr($Command,"/maxfileuploads"))
{
	$Value=preg_replace("/[^0-9\-]/","", $Value);
	$Value=intval($Value);
	
	if ($Value<=0)
	{
		$Value="100";
	}
}
else
{
	exit;
}

if (trim($Value)!="")
{
	if (stristr($Value,"|"))
	{
		$Value=str_replace("|","VerticalBar",$Value);
	}
	
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '$Command $Value'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}

if (stristr($Error,"!"))
{
	echo $Error;
}
else
{
	echo $Value;
}

?>