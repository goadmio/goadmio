<?php
include "nav.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=RestorePHPConfiguration&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
include "title.php";

if ($_REQUEST['Action']=="RestorePHPConfiguration")
{

	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/phpini restore'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	echo Error ("Restore default, Please wait...");
	
exit;
}

	if (file_exists("/etc/php.ini"))
	{
	$Data = parse_ini_file("/etc/php.ini");
	}
	else
	{
		// Debian
		$Part = explode(".",phpversion());
		$Version = $Part[0] . "." . $Part[1];
	
		$Data = parse_ini_file("/etc/php/$Version/fpm/php.ini");
	}

	$MemoryLimit=$Data['memory_limit'];
	$DisableFunctions=$Data['disable_functions'];
	$MaxExecutionTime=$Data['max_execution_time'];
	$MaxInputTime=$Data['max_input_time'];
	$MaxInputVars=$Data['max_input_vars'];
	$PostMaxSize=$Data['post_max_size'];
	$UploadMaxFilesize=$Data['upload_max_filesize'];
	$MaxFileUploads=$Data['max_file_uploads'];
	$SessionGcMaxlifetime=$Data['session.gc_maxlifetime'];
	
	$AllowUrlFopen=$Data['allow_url_fopen'];
	if ($AllowUrlFopen==1)
	{
	$AllowUrlFopen="On";
	}
	elseif ($AllowUrlFopen=="")
	{
	$AllowUrlFopen="Off";
	}
	
	$AllowUrlInclude=$Data['allow_url_include'];
	if ($AllowUrlInclude==1)
	{
	$AllowUrlInclude="On";
	}
	elseif ($AllowUrlInclude=="")
	{
	$AllowUrlInclude="Off";
	}
	
	$DisplayErrors=$Data['display_errors'];
	if ($DisplayErrors==1)
	{
	$DisplayErrors="On";
	}
	elseif ($DisplayErrors=="")
	{
	$DisplayErrors="Off";
	}
	
	$ErrorReporting=$Data['error_reporting'];
	
	$DisplayStartupErrors=$Data['display_startup_errors'];
	if ($DisplayStartupErrors==1)
	{
	$DisplayStartupErrors="On";
	}
	elseif ($DisplayStartupErrors=="")
	{
	$DisplayStartupErrors="Off";
	}
	
	$FileUploads=$Data['file_uploads'];
	if ($FileUploads==1)
	{
	$FileUploads="On";
	}
	elseif ($FileUploads=="")
	{
	$FileUploads="Off";
	}
	
	$ZlibOutputCompression=$Data['zlib.output_compression'];
	if ($ZlibOutputCompression==1)
	{
	$ZlibOutputCompression="On";
	}
	elseif ($ZlibOutputCompression=="")
	{
	$ZlibOutputCompression="Off";
	}
			
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;


?>