<?php
include "nav.php";
$Buttons="";
include "title.php";

	$Error=SSH ("/usr/bin/sudo systemctl status nginx 2>&1",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],60);
		
	$Content=DesignCode($Content,"$Control (Content)");
	echo $Content;

?>