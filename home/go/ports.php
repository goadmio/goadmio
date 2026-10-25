<?php
include "nav.php";

include "title.php";

$Error=SSH ("/usr/bin/netstat -tulpn",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword'],60);

if ($DemoPassword!="")
{
	$Error=str_replace("$SSHPort","22",$Error);
}

$Content=DesignCode($Content,"$Control (Content)");
echo $Content;
?>