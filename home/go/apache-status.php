<?php
include "nav.php";
$Buttons="";
include "title.php";

	$OS=trim(file_get_contents("/usr/local/goadmio/linux/os.db"));
	if ($OS=="CentOS" or $OS=="Fedora" or $OS=="AlmaLinux" or $OS=="Rocky" or $OS=="RockyLinux")
	{
		$Error=SSH ("/usr/bin/sudo systemctl status httpd 2>&1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],60);
	}
	else
	{
		$Error=SSH ("/usr/bin/sudo systemctl status apache2 2>&1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],60);
	}
		
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;
?>