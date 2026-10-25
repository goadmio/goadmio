<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();
header('Content-Type: text/html; charset=UTF-8'); 

include "/usr/local/goadmio/include/config/config.php";
include "/usr/local/goadmio/home/go/include/function/function.php";

$Service=$_REQUEST['Service'];

// Input ID
$ID=$_REQUEST['ID'];

$SiteID=intval($_REQUEST['SiteID']);
$Value=$_REQUEST['Value'];
$Value=str_replace('"','',$Value);
$Value=str_replace("'","",$Value);

	if ($SiteID>=1)
	{
		$Result = SQL("select Domain from Site where SiteID='$SiteID'");
		foreach ($Result as $Row)
		{
		$Domain=$Row['Domain'];
		}
		
	}

	include "/usr/local/goadmio/home/go/access.php";

if ($Service=="OpenBasedir" and $SiteID!="")
{
	if (!file_exists($Value))
	{
	$Value="";
	}
	
	if ($_SESSION['SessionSSHUsername']=="root" or $_SESSION['SessionSSHUsername']==$SSHUsername)
	{
	SQL("UPDATE Site set OpenBasedir='$Value' where SiteID='$SiteID'");
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/conf $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
}
elseif ($Service=="DisableFunctions" and $SiteID!="")
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
	
	if ($_SESSION['SessionSSHUsername']=="root" or $_SESSION['SessionSSHUsername']==$SSHUsername)
	{
	SQL("UPDATE Site set DisableFunctions='$Value' where SiteID='$SiteID'");
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/conf $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
}
elseif ($Service=="SMTPHost" and $SiteID!="")
{
	$Value=trim($Value);
	
	if (stristr($Value,"@"))
	{
		$Value="Invalid SMTP Hostname";
	}
	elseif (stristr($Value,".") OR $Value=="")
	{
		SQL("UPDATE Site set SMTPHost='$Value',SMTPStatus='-1' where SiteID='$SiteID'");

		if (stristr($Domain,"."))
		{
		SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}
	}
	else
	{
		$Value="Invalid SMTP Hostname";
	}
	
}
elseif ($Service=="SMTPUser" and $SiteID!="")
{
	$Value=trim($Value);
	SQL("UPDATE Site set SMTPUser='$Value',SMTPStatus='-1' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="SMTPPass" and $SiteID!="")
{
	$Value=trim($Value);
	SQL("UPDATE Site set SMTPPass='$Value',SMTPStatus='-1' where SiteID='$SiteID'");

	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

}
elseif ($Service=="SMTPPort" and $SiteID!="")
{
	$Value=trim($Value);
	
	if ($Value=="")
	{
	$Value="587";
	}

	SQL("UPDATE Site set SMTPPort='$Value',SMTPStatus='-1' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="SMTPActive" and $SiteID!="")
{
	$Value=trim($Value);
	
	if ($Value=="0" or $Value=="off" or $Value=="false")
	{
	$Value="0";
	}
	else
	{
	$Value="1";
	}

	SQL("UPDATE Site set SMTPActive='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="RoundcubeSMTPHost" and $SiteID!="")
{

	$Value=trim($Value);

	if (stristr($Value,"@"))
	{
		$Value="Invalid SMTP Hostname";
	}
	elseif (stristr($Value,".") OR $Value=="")
	{
		SQL("UPDATE Site set RoundcubeSMTPHost='$Value' where SiteID='$SiteID'");
		
		if (stristr($Domain,"."))
		{
		SSH ("/usr/bin/sudo /go/roundcubecustomsmtp $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		}
	}
	else
	{
		$Value="Invalid SMTP Hostname";
	}

}
elseif ($Service=="RoundcubeSMTPUser" and $SiteID!="")
{
	$Value=trim($Value);
	SQL("UPDATE Site set RoundcubeSMTPUser='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo /go/roundcubecustomsmtp $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="RoundcubeSMTPPass" and $SiteID!="")
{
	$Value=trim($Value);
	SQL("UPDATE Site set RoundcubeSMTPPass='$Value' where SiteID='$SiteID'");

	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo /go/roundcubecustomsmtp $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

}
elseif ($Service=="RoundcubeSMTPPort" and $SiteID!="")
{
	$Value=trim($Value);
	
	if ($Value=="")
	{
	$Value="587";
	}

	SQL("UPDATE Site set RoundcubeSMTPPort='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo /go/roundcubecustomsmtp $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="RoundcubeSMTPActive" and $SiteID!="")
{
	$Value=trim($Value);
	
	if ($Value=="0" or $Value=="off" or $Value=="false")
	{
	$Value="0";
	}
	else
	{
	$Value="1";
	}

	SQL("UPDATE Site set RoundcubeSMTPActive='$Value' where SiteID='$SiteID'");

	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo /go/roundcubecustomsmtp $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="MailTTL" and $Value!="" and $SiteID!="")
{
	$Value=intval($Value);
	if ($Value<1 and $Value!=0) {$Value="1";}
	if ($Value>2557) {$Value="2557";}
	
	SQL("UPDATE Site set MailTTL='$Value' where SiteID='$SiteID'");
}
elseif ($Service=="CacheTTL" and $SiteID!="")
{
	$Value=intval($Value);
	SQL("UPDATE Site set CacheTTL='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cache $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="CacheLength" and $SiteID!="")
{
	$Value=intval($Value);
	SQL("UPDATE Site set CacheLength='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cache $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="CacheExclude" and $SiteID!="")
{
	$Value=trim($Value);
	SQL("UPDATE Site set CacheExclude='$Value' where SiteID='$SiteID'");

	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cache $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}

}
elseif ($Service=="CacheActive" and $SiteID!="")
{
	$Value=trim($Value);
	
	if ($Value=="0" or $Value=="off" or $Value=="false")
	{
	$Value="0";
	}
	else
	{
	$Value="1";
	}

	SQL("UPDATE Site set CacheActive='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/cache $Domain'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="PostfwdDomainLimit" and $SiteID!="")
{
	$Value=intval($Value);
	
	SQL("UPDATE Site set PostfwdDomainLimit='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}
elseif ($Service=="PostfwdUserLimit" and $SiteID!="")
{
	$Value=intval($Value);
	
	SQL("UPDATE Site set PostfwdUserLimit='$Value' where SiteID='$SiteID'");
	
	if (stristr($Domain,"."))
	{
	SSH ("/usr/bin/sudo screen -d -m bash -c '/go/vmail'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	}
	
}

echo $Value;

?>